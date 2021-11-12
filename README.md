Website for the Big Data Biology Lab

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

For development, the following should start a local server:

```bash
npm install
npm start
```
