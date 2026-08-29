# Adding a paper

1. Choose a _slug_ for your paper. This should be a short (one or two words)
   name. It is preferable to use underscores rather than spaces. The script
   will add the year prefix automatically. See the existing files in this folder
   for examples.
2. Choose an image for your paper and save it as a PNG file (it could
   eventually be generalized to other formats, but someone needs to write the
   code to auto-convert). This is often Fig 1 (or Fig 1a) of the paper, but it
   could be any image that represents the paper well. The image will be resized
   to a width of 600px (keeping the aspect ratio).
3. Run `python add-paper-stub.py <DOI> <SLUG> <IMG_FILE>` (where `<DOI>` is the
   DOI of the paper, while `<SLUG>` and `<IMG_FILE>` are the slug and image
   files you chose in the previous steps. ⚠️ It sometimes takes a few days for
   the DOI→Crossref information to be available. If this fails, please try
   again later.
4. Manually check the outputs. The body of the document should be the abstract
   of the paper, but sometimes Crossref has incomplete or incorrect
   information. Please fix as needed!
5. Add a `short_description` field. This should be a one or two sentence
   summary of the paper, suitable for display on the main page.
6. For preprints, set `status: preprint` and make sure the `journal` field
   names the preprint server (e.g. `bioRxiv`) without repeating the word
   *preprint*: the website adds a **preprint** badge wherever the paper is
   listed. When the paper is accepted but not yet out, use `status: in press`.
   Papers without a `status` field are taken to be published, which is the
   right default for almost everything.

   When updating to the published version, drop the `status` field, set
   `journal` to the journal name, and either update the existing file or create
   a new one and **remove** the old preprint to avoid duplicates (you can keep
   the same slug). If renaming the file (e.g., changing the year prefix), add
   an `aliases` field listing old slugs so that existing links keep working:
   ```yaml
   aliases:
   - 2025_old_slug
   ```
7. Open a PR with the new files.

We also list paper on the left side bar (so they appear on every page), but
_only_ recent core group papers (namely where both first and last authors are
in the group). Please add these manually to `src/Shared.elm` (the entries there
carry the same `status`, as `Lab.Preprint`/`Lab.Published`, so that the badge
also shows up in the side bar).

## Example

```bash
python add-paper-stub.py 10.1101/2025.09.17.676595 dogs dog_figure1.png
```

## Technical notes

The output is a markdown file with front matter and the image will be added to
`public/images/paper/year_{slug}.png`.

