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
6. For preprints, please make sure to adjust the `journal` field to read
   `bioRxiv (PREPRINT)` or as appropriate. Alternatively, when updating to the
   published version, either update the existing file or create a new one and
   **remove** the old preprint to avoid duplicates (you can keep the same
   slug).
7. Open a PR with the new files.

We also list paper on the left side bar (so they appear on every page), but
_only_ recent core group papers (namely where both first and last authors are
in the group). Please add these manually to `src/Shared.elm`.

## Example

```bash
python add-paper-stub.py 10.1101/2025.09.17.676595 dogs dog_figure1.png
```

## Technical notes

The output is a markdown file with front matter and the image will be added to
`public/images/paper/year_{slug}.png`.

