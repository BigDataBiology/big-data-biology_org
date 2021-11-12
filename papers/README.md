# Adding a paper

1. Choose a _slug_ for your paper. This should be a short (one or two words)
   name. It is preferable to use underscores rather than spaces.
2. Run `python add-paper-stub.py <DOI> <SLUG>` (where `<DOI>` is the DOI of the
   paper and `<SLUG>` is the slug you chose in the previous step).
3. Manually whether there is some edits needed. The body of the document should
   be the abstract of the paper.
4. Add a `short_description` field.
5. Add an image to `public/images/paper/year_{slug}.png`. It must have this
   name and it must be a PNG file (it could eventually be generalized to SVG,
   but someone needs to write that code).

