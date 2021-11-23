# How to write posts in the blog
## 1. Add your post file in /content/blog folder
Notice the format:

(1)The name of your file should be:`Year-Month-day-name.md`,such as `2020-04-29-NME2.md`

(2)The head of the article should be:

```
---
title: "Your title"
author: "Your name"
---
```
such as

```
---
title: "Methionine tanks: how we almost got fooled by a flawed dataset"
author: Célio Dias Santos Júnior, Luis Pedro Coelho
---
```

(3)If you want to add images,all the images should be stored in `/assets/` folder.
You can add image like this:
`![alt]({{ site.baseurl }}/assets/images/filename.jpg)`
such as:
`![figure4]({{ site.baseurl }}/assets/2020-04-10-cryptic/image1_after4.png )`

## 2. Add your images in /assets folder
You can create your images folder in /assets folder,and add your images.Then when you add images in your article,add the address of your images.
