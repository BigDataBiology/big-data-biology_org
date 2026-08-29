# AGENTS.md

## Project Overview

This is the static website for the Big Data Biology Lab (BDB-Lab) at QUT, built with [elm-pages](https://elm-pages.com/) (v2). Content is authored in Markdown with YAML frontmatter; Elm code handles layout, routing, and rendering.

## Commands

```bash
npm install                   # Install dependencies (also runs elm-tooling install via postinstall)
npm start                     # Start local dev server at port 1234 (elm-pages dev)
npm run build                 # Production build → dist/
npm run lint                  # Lint Elm code (elm-review); --fix-all applies fixes
python3 check-references.py   # Check Markdown links & image references (see below)
```

`npm run lint` runs [elm-review](https://github.com/jfmengels/elm-review) with the
configuration in `review/`: the `NoUnused.*` rules plus `Simplify`, i.e. dead code and
mechanical rewrites only. `NoUnused.Parameters` is deliberately off (elm-pages dictates
the shape of the page callbacks, and most of them ignore some arguments), and no style
rules are enabled. `.elm-pages/` is parsed but never reported on, so that the generated
`Main.elm` still counts as a user of each page module's `page`/`Data`/`Model`/`Msg`.
GitHub Actions runs it on every push and pull request.

⚠️ `elm-review --fix` and `--fix-all` run `elm-format` over every file they touch, which
reformats the whole file rather than just the fix. This code base is not elm-formatted,
so prefer applying the reported fixes by hand.

`check-references.py` is a best-effort link/reference checker for the Markdown content.
It reproduces the site's routing from the filesystem (and the `dist/` build, if present)
and reports broken internal links (`/person`, `/paper` incl. `aliases`, `/project`,
blog date URLs, content pages), missing/moved images under `public/`, malformed URLs,
and insecure `http://` links. Add `--external` to also verify external URLs over the
network, or `--no-warn` to show errors only (exits non-zero on errors, so it can gate CI).

## Architecture

### Technology Stack
- **Elm 0.19.1** — all frontend logic and page rendering
- **elm-pages v2** — static site generator; pages map to files under `src/Page/`
- **Bootstrap** (via elm-bootstrap) — styling
- **Netlify** — deployment (auto-deploys on push to `main`)

### Content Directories (Markdown with YAML frontmatter)
| Directory | Content |
|-----------|---------|
| `content/blog/` | Blog posts, named `YYYY-MM-DD-slug.md` |
| `people/` | Lab member profiles (slugs must match photo filenames) |
| `papers/` | Publications, named `YYYY_slug.md` |
| `projects/` | Research project pages |
| `content/` | General pages (index, software, positions, tutorials, etc.) |
| `public/` | Static assets served as-is (images, downloadable files) |

### Elm Source (`src/`)
- `Main.elm` — entry point
- `Shared.elm` — shared layout and state
- `Lab/Lab.elm` — core data types (`Member`, `Publication`, `Project`)
- `Lab/BDBLab.elm` — loads data from markdown files
- `Page/` — one file per route (e.g., `Page/Papers.elm`, `Page/Person/Slug_.elm`)

### Slug Convention
Slugs are computer-friendly identifiers used throughout the system:
- **Member slug**: determines profile filename (`people/slug.md`), photo filename (`public/images/people/slug.jpeg`), and references in project frontmatter
- **Paper slug**: combined with year as `papers/YYYY_slug.md`

## Adding Content

**Papers** — Use the helper script to auto-generate a stub from a DOI:
```bash
python papers/add-paper-stub.py <DOI> <SLUG> <IMAGE_FILE>
```
Or manually create `papers/YYYY_slug.md` with required frontmatter: `title`, `journal`, `date`, `doi`, `authors`, `short_description`. Preprints additionally
carry `status: preprint` (and papers accepted but not yet out `status: in press`),
which renders a badge wherever the paper is listed; without the field a paper is
taken to be published.

**Blog posts** — Create `content/blog/YYYY-MM-DD-slug.md` with frontmatter: `title`, `authors` (a single string, comma-separated names).

**Team members** — Create `people/slug.md` (required: `name`, `title`, `joined`, `short_bio`) and add photo at `public/images/people/slug.jpeg`.

**Software releases** — When a release is announced (news entry under `## Recent News` in `content/index.md`), also update the tool's page under `content/software/` in the same change: its "Latest release" section must name the new version and describe what changed. The two are easy to let drift apart; the software page is the one readers land on.

See `people/README.md`, `papers/README.md`, and `content/blog/README.md` for detailed field documentation.
