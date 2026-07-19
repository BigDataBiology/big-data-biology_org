#!/usr/bin/env python3
"""Check references (links & images) in the site's Markdown files.

This is a best-effort static checker for the elm-pages site. It reproduces the
site's routing from the filesystem and verifies that every internal link and
local image/asset referenced from Markdown actually resolves.

What it checks
--------------
* Internal routes: ``/person/<slug>``, ``/paper/<slug>`` (incl. ``aliases``),
  ``/project/<slug>``, ``/software/...``, blog date URLs, and generic content
  pages (``content/**/*.md``). Listing pages (``/people``, ``/papers`` ...).
* Local assets: ``/images/...``, ``/assets/...`` and any link ending in a file
  extension -> must exist under ``public/``.
* Insecure ``http://`` links (reported as warnings; HTTPS is preferred).
* Optionally (``--external``) that external URLs respond, over the network.

It is intentionally forgiving: things it cannot resolve confidently (e.g. some
relative links) are reported as warnings, not errors. It is *not* a substitute
for a real build, but it catches the common mistakes (wrong slug, ``/projects/``
vs ``/project/``, moved images, dead ``http://`` embeds).

Usage
-----
    python3 check-references.py                 # check the standard content dirs
    python3 check-references.py --external       # also verify external URLs
    python3 check-references.py --root /path/to/repo
    python3 check-references.py --include-readme # also scan README.md files

Exit code is non-zero if any errors (not warnings) are found, so it can be used
in CI.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from urllib.parse import unquote, urlsplit

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Directories whose Markdown files render into pages we want to check.
CONTENT_ROOTS = ["content", "papers", "people", "projects"]

# Where public assets live (served from the site root).
PUBLIC_DIR = "public"

# Routes that exist but are not derived from a Markdown file (Elm-only pages).
# Derived routes from dist/ (if present) are added on top of these.
EXTRA_ROUTES = {
    "/",
    "/index",
    "/people",
    "/papers",
    "/software",
    "/software/macrel",
    "/software/ngbuilder",
    "/software/ng-builder",
    "/blog",
}

# Prefixes that are always local static assets (checked against PUBLIC_DIR).
ASSET_PREFIXES = ("/images/", "/assets/", "/public/", "/static/")

SKIP_SCHEMES = ("mailto:", "tel:", "data:", "javascript:", "ftp:")

# ---------------------------------------------------------------------------
# Reference extraction
# ---------------------------------------------------------------------------

# Inline images/links: capture the whole (...) destination, incl. spaces.
INLINE_RE = re.compile(r"!?\[[^\]]*\]\(([^)]*)\)")
# Reference-style definitions:  [id]: url "title"
REFDEF_RE = re.compile(r'^\s{0,3}\[[^\]]+\]:\s*(\S.*?)\s*$')
# HTML attributes: href="..." / src="..."
HTML_ATTR_RE = re.compile(r"""(?:href|src)\s*=\s*["']([^"']+)["']""")

BASEURL_RE = re.compile(r"\{\{\s*site\.baseurl\s*\}\}")
# A link destination optionally followed by a "title" or 'title'.
DEST_TITLE_RE = re.compile(r'^(.*?)(?:\s+["\'][^"\']*["\'])?$')


def parse_destination(inner: str) -> str:
    """Extract the URL from a Markdown link destination, dropping an optional
    title. Handles ``<url>`` and ``url "title"``; keeps spaces in bare URLs so
    unencoded-space assets can be detected."""
    inner = inner.strip()
    if inner.startswith("<"):
        return inner[1:].split(">", 1)[0].strip()
    m = DEST_TITLE_RE.match(inner)
    return (m.group(1) if m else inner).strip()


def strip_frontmatter(text: str) -> tuple[str, int]:
    """Remove a leading YAML front-matter block. Returns (body, lines_removed)."""
    if text.startswith("---"):
        m = re.match(r"^---\r?\n.*?\r?\n---\r?\n", text, re.DOTALL)
        if m:
            removed = m.group(0).count("\n")
            return text[m.end():], removed
    return text, 0


def extract_references(path: str):
    """Yield (line_number, raw_url) for every reference found in a Markdown file."""
    with open(path, encoding="utf-8") as fh:
        raw = fh.read()
    body, offset = strip_frontmatter(raw)
    body = BASEURL_RE.sub("", body)
    for i, line in enumerate(body.splitlines(), start=1 + offset):
        for m in INLINE_RE.finditer(line):
            url = parse_destination(m.group(1))
            if url:
                yield i, url
        for rx in (REFDEF_RE, HTML_ATTR_RE):
            for m in rx.finditer(line):
                url = m.group(1).strip().rstrip(">")
                if url:
                    yield i, url


# ---------------------------------------------------------------------------
# Building the set of valid routes / assets
# ---------------------------------------------------------------------------

def norm_route(route: str) -> str:
    """Normalise a route for comparison: lowercase, single leading slash, no
    trailing slash (except the root)."""
    route = "/" + route.strip("/")
    return route.lower() if route != "/" else "/"


def md_files(root: str):
    for dirpath, _dirs, files in os.walk(root):
        for f in files:
            if f.endswith(".md") and f != "README.md":
                yield os.path.join(dirpath, f)


def load_yaml_field_list(path: str, field: str):
    """Very small YAML helper: read a top-level list field from front matter.

    Only handles the ``field:\n  - a\n  - b`` form (enough for ``aliases``)."""
    out = []
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    fm, _ = None, None
    m = re.match(r"^---\r?\n(.*?)\r?\n---", text, re.DOTALL)
    if not m:
        return out
    fm = m.group(1)
    fm_lines = fm.splitlines()
    for idx, line in enumerate(fm_lines):
        if re.match(rf"^{re.escape(field)}\s*:", line):
            # inline list form: field: [a, b]
            inline = line.split(":", 1)[1].strip()
            if inline.startswith("["):
                inner = inline.strip("[]")
                out += [x.strip().strip("\"'") for x in inner.split(",") if x.strip()]
                break
            # block list form
            for nxt in fm_lines[idx + 1:]:
                if re.match(r"^\s*-\s+", nxt):
                    out.append(nxt.strip()[1:].strip().strip("\"'"))
                elif nxt.strip() == "":
                    continue
                else:
                    break
            break
    return out


def build_routes(repo: str):
    """Return a set of normalised valid routes derived from the filesystem
    (and dist/ if present)."""
    routes = set(norm_route(r) for r in EXTRA_ROUTES)

    # Generic content pages (SPLAT) -> /<subdir>/<slug>
    content_dir = os.path.join(repo, "content")
    for path in md_files(content_dir):
        rel = os.path.relpath(path, content_dir)[:-3]  # drop .md
        parts = rel.split(os.sep)
        routes.add(norm_route("/".join(parts)))
        # blog posts also get a canonical date URL: /blog/YYYY/MM/DD/slug
        if parts[0] == "blog" and re.match(r"^\d{4}-\d{2}-\d{2}-", parts[-1]):
            name = parts[-1]
            y, mo, d, slug = name[:4], name[5:7], name[8:10], name[11:]
            routes.add(norm_route(f"/blog/{y}/{mo}/{d}/{slug}"))

    # People -> /person/<slug>
    for sub in ("people", os.path.join("people", "alumni")):
        d = os.path.join(repo, sub)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".md") and f != "README.md":
                    routes.add(norm_route(f"/person/{f[:-3]}"))

    # Papers -> /paper/<slug> and each alias
    papers_dir = os.path.join(repo, "papers")
    if os.path.isdir(papers_dir):
        for f in os.listdir(papers_dir):
            if f.endswith(".md") and f != "README.md":
                slug = f[:-3]
                routes.add(norm_route(f"/paper/{slug}"))
                for alias in load_yaml_field_list(os.path.join(papers_dir, f), "aliases"):
                    routes.add(norm_route(f"/paper/{alias}"))

    # Projects -> /project/<slug>
    projects_dir = os.path.join(repo, "projects")
    if os.path.isdir(projects_dir):
        for f in os.listdir(projects_dir):
            if f.endswith(".md") and f != "README.md":
                routes.add(norm_route(f"/project/{f[:-3]}"))

    # Augment with anything an existing build produced (authoritative if present).
    dist = os.path.join(repo, "dist")
    if os.path.isdir(dist):
        for dirpath, _dirs, files in os.walk(dist):
            if "index.html" in files:
                rel = os.path.relpath(dirpath, dist)
                routes.add(norm_route("/" if rel == "." else rel))
            for f in files:
                if f.endswith(".html") and f != "index.html":
                    rel = os.path.relpath(os.path.join(dirpath, f[:-5]), dist)
                    routes.add(norm_route(rel))

    return routes


# ---------------------------------------------------------------------------
# Classification / checking of a single reference
# ---------------------------------------------------------------------------

def looks_like_asset(pathpart: str) -> bool:
    if pathpart.startswith(ASSET_PREFIXES):
        return True
    last = pathpart.rstrip("/").rsplit("/", 1)[-1]
    return "." in last  # has a file extension


def find_case_insensitive(repo: str, rel_under_public: str):
    """Return the on-disk name if a case-insensitive match exists, else None."""
    target = os.path.join(repo, PUBLIC_DIR, rel_under_public.lstrip("/"))
    d = os.path.dirname(target)
    base = os.path.basename(target)
    if not os.path.isdir(d):
        return None
    for name in os.listdir(d):
        if name.lower() == base.lower():
            return os.path.join(d, name)
    return None


def resolve_relative(src_route_dir: str, url: str) -> str:
    """Resolve a relative URL against the directory of the page it appears on."""
    joined = os.path.normpath(os.path.join(src_route_dir, url))
    if not joined.startswith("/"):
        joined = "/" + joined
    return joined


def route_dir_for_source(repo: str, path: str) -> str:
    """Best-effort logical directory of the page a Markdown file renders to,
    used to resolve relative links."""
    rel = os.path.relpath(path, repo)
    parts = rel.split(os.sep)
    top = parts[0]
    if top == "content":
        # /<subdirs>/  (the page lives at /<subdirs>/<slug>, dir is its parent)
        sub = parts[1:-1]
        return "/" + "/".join(sub) if sub else "/"
    if top == "papers":
        return "/paper"
    if top == "projects":
        return "/project"
    if top == "people":
        return "/person"
    return "/"


def check_reference(repo, routes, src_path, url):
    """Return (severity, message) or None if the reference is fine.

    severity is 'error' or 'warn'."""
    url = url.strip()
    if not url or url.startswith("#"):
        return None
    low = url.lower()
    if low.startswith(SKIP_SCHEMES):
        return None

    # Malformed scheme, e.g. "https:/doi.org/..." (single slash) — a typo.
    if re.match(r"^https?:/[^/]", low):
        return ("error", f"malformed URL (missing '/' after scheme): {url}")

    # External links
    if low.startswith("http://") or low.startswith("https://"):
        if low.startswith("http://") and "localhost" not in low and "127.0.0.1" not in low:
            return ("insecure-http", url)  # aggregated by caller
        return None
    if url.startswith("//"):
        return ("warn", f"protocol-relative URL (prefer https): {url}")

    # Internal: split off query/fragment and decode %20 etc.
    split = urlsplit(url)
    path = unquote(split.path)
    if not path:
        return None  # pure #fragment or ?query

    relative = not path.startswith("/")

    # A scheme-less bare domain, e.g. "dbaasp.org/" — almost certainly a link
    # that lost its https:// prefix, not a real relative path.
    if relative and re.match(r"^[a-z0-9-]+(\.[a-z0-9-]+)+(/|$)", low):
        return ("warn", f"link looks like an external URL missing its scheme: {url}")

    abs_path = path if not relative else resolve_relative(
        route_dir_for_source(repo, src_path), path)

    # Local asset?
    if looks_like_asset(abs_path):
        disk = os.path.join(repo, PUBLIC_DIR, abs_path.lstrip("/"))
        if os.path.isfile(disk):
            if " " in abs_path:
                return ("warn", f"asset URL has unencoded space(s) (encode as %20): {url}")
            return None
        hint = find_case_insensitive(repo, abs_path)
        if hint:
            return ("error", f"asset case mismatch: {url}  (on disk: "
                             f"{os.path.relpath(hint, repo)})")
        return ("error", f"missing asset: {url}  (looked for {os.path.relpath(disk, repo)})")

    # Otherwise treat as a route.
    if norm_route(abs_path) in routes:
        return None
    if relative:
        return ("warn", f"unresolved relative link: {url}  (guessed {abs_path})")
    return ("error", f"broken internal link: {url}")


# ---------------------------------------------------------------------------
# Optional external checking
# ---------------------------------------------------------------------------

def check_external(urls, timeout=8):
    """HEAD/GET each external URL; return {url: problem_or_None}."""
    import urllib.request
    import urllib.error

    results = {}
    for url in sorted(urls):
        problem = None
        req = urllib.request.Request(
            url, method="HEAD",
            headers={"User-Agent": "Mozilla/5.0 (reference-checker)"})
        try:
            urllib.request.urlopen(req, timeout=timeout)
        except urllib.error.HTTPError as e:
            if e.code in (403, 405, 429):  # method/anti-bot; retry with GET
                try:
                    req = urllib.request.Request(
                        url, method="GET",
                        headers={"User-Agent": "Mozilla/5.0 (reference-checker)"})
                    urllib.request.urlopen(req, timeout=timeout)
                except Exception as e2:  # noqa: BLE001
                    problem = f"{type(e2).__name__}: {e2}"
            else:
                problem = f"HTTP {e.code}"
        except Exception as e:  # noqa: BLE001
            problem = f"{type(e).__name__}: {e}"
        results[url] = problem
    return results


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main(argv):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=os.path.dirname(os.path.abspath(__file__)) or ".",
                    help="repository root (default: script location)")
    ap.add_argument("--external", action="store_true",
                    help="also verify external http(s) URLs over the network (slow)")
    ap.add_argument("--include-readme", action="store_true",
                    help="also scan README.md files (off by default)")
    ap.add_argument("--no-warn", action="store_true",
                    help="only print errors, hide warnings")
    args = ap.parse_args(argv)

    repo = os.path.abspath(args.root)
    routes = build_routes(repo)

    errors = 0
    warnings = 0
    external_urls = set()
    findings = []  # (path, line, severity, message)
    # insecure http links aggregated by (relpath, host) -> [lines]
    insecure = {}

    for root in CONTENT_ROOTS:
        base = os.path.join(repo, root)
        if not os.path.isdir(base):
            continue
        for dirpath, _dirs, files in os.walk(base):
            for f in sorted(files):
                if not f.endswith(".md"):
                    continue
                if f == "README.md" and not args.include_readme:
                    continue
                path = os.path.join(dirpath, f)
                relpath = os.path.relpath(path, repo)
                for line, url in extract_references(path):
                    low = url.lower()
                    if low.startswith(("http://", "https://")):
                        external_urls.add(url.split()[0])
                    res = check_reference(repo, routes, path, url)
                    if res is None:
                        continue
                    severity, msg = res
                    if severity == "insecure-http":
                        host = urlsplit(msg).netloc or msg
                        insecure.setdefault((relpath, host), []).append(line)
                        continue
                    if severity == "warn" and args.no_warn:
                        continue
                    findings.append((relpath, line, severity, msg))

    # Fold aggregated insecure-http links into the findings list.
    if not args.no_warn:
        for (relpath, host), lines in insecure.items():
            n = len(lines)
            plural = "s" if n > 1 else ""
            findings.append((relpath, min(lines), "warn",
                             f"{n} insecure http:// link{plural} to {host} "
                             f"(prefer https){'' if n == 1 else f'; lines {min(lines)}-{max(lines)}'}"))

    # Report internal/asset findings, grouped by file.
    findings.sort(key=lambda t: (t[0], t[1]))
    current = None
    for path, line, severity, msg in findings:
        if path != current:
            print(f"\n{path}")
            current = path
        tag = "ERROR" if severity == "error" else "warn "
        print(f"  {tag} L{line}: {msg}")
        if severity == "error":
            errors += 1
        else:
            warnings += 1

    # Optional external checking.
    if args.external and external_urls:
        print(f"\nChecking {len(external_urls)} external URL(s) over the network...")
        for url, problem in check_external(external_urls).items():
            if problem:
                print(f"  ERROR (external): {url}  -> {problem}")
                errors += 1

    print("\n" + "-" * 60)
    print(f"Scanned routes known: {len(routes)}")
    print(f"Errors: {errors}   Warnings: {warnings}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
