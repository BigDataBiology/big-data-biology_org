# Adding a paper

1. Choose a _slug_ for your paper. This should be a short (one or two words)
   name. It is preferable to use underscores rather than spaces.
2. Choose an image for your paper and save it as a PNG file (it could
   eventually be generalized to other formats, but someone needs to write that
   code).
3. Run `python add-paper-stub.py <DOI> <SLUG> <IMG_FILE>` (where `<DOI>` is the
   DOI of the paper, while `<SLUG>` and `<IMG_FILE>` are the slug and image
   files you chose in the previous steps.
4. Manually whether there is some edits needed. The body of the document should
   be the abstract of the paper.
5. Add a `short_description` field.

## Technical notes

The output is a markdown file with front matter and the image will be added to
`public/images/paper/year_{slug}.png`.

