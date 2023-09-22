Website for the Big Data Biology Lab

[![Netlify Status](https://api.netlify.com/api/v1/badges/7c716f31-f1d8-422d-ad91-b43fd63cac3d/deploy-status)](https://app.netlify.com/sites/big-data-biology/deploys)

See [http://big-data-biology.org/](http://big-data-biology.org/)

## For group members updating the website


Six important subdirectories

1. `content/`: General purpose pages
2. `content/blog/`: the blog
3. `people/`: For members
4. `projects/`: For projects
5. `papers/`: For papers. There is a script (`add-paper-stub.py`) to help you get started.
6. `public/`: Files in these directories are just served directly. The
   subdirectories `images/people` and `images/papers` have a specific purpose
   (see `people/README.md` and `papers/README.md`, respectively)

An important concept is that of a _slug_, which is a computer-friendly short
identifier. For example, Luis' slug is `luis_pedro_coelho` as determined by the
fact that his information is in the file `people/**luis_pedro_coelho**.md`.
This is then used to identify Luis' photo
(`public/images/people/luis_pedro_coelho.jpeg`) and to refer to Luis in project
member lists.

## Running locally

This is an [elm-pages](https://elm-pages.com/) website, which allows us to mix
Markdown static content (see above) with full Elm logic and active pages. If
you only want to update content, the above instructions should be enough to get
started, but if you want to either test the changes locally or develop the
website, you may want to run elm locally.

For development, the following should start a local server (assuming you have
[npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
installed):

```bash
npm install
npm start
```

## Notes on what goes on the website

1. _Most recent BDB-Lab papers_: if a BDB-Lab member is first or corresponding
   (including co-first and co-corresponding), then it is a core lab paper.
   Papers are considered recent for six months.

