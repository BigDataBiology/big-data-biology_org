# AGENTS.md

## Project Overview

This is the static website for the Big Data Biology Lab (BDB-Lab) at QUT, built with [elm-pages](https://elm-pages.com/) (v2). Content is authored in Markdown with YAML frontmatter; Elm code handles layout, routing, and rendering.

## Commands

```bash
npm install       # Install dependencies (also runs elm-tooling install via postinstall)
npm start         # Start local dev server at port 1234 (elm-pages dev)
npm run build     # Production build → dist/
npx elm-review    # Lint Elm code
```

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
Or manually create `papers/YYYY_slug.md` with required frontmatter: `title`, `journal`, `date`, `doi`, `authors`, `short_description`.

**Blog posts** — Create `content/blog/YYYY-MM-DD-slug.md` with frontmatter: `title`, `author`.

**Team members** — Create `people/slug.md` (required: `name`, `title`, `joined`, `short_bio`) and add photo at `public/images/people/slug.jpeg`.

See `people/README.md`, `papers/README.md`, and `content/blog/README.md` for detailed field documentation.
