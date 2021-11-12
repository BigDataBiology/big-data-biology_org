# How to write posts in the blog
## 1. Add your post file in /_posts folder
Notice the format:

(1)The name of your file should be:`Year-Month-day-name.md`,such as `2020-04-29-NME2.md`

(2)The head of the article should be:


```
---
title: "your title"
date: year-month-day
---

your name

<div style="padding: 1em" markdown="1">

</div>
```
such as

```
---
title: "Methionine tanks: how we almost got fooled by a flawed dataset"
date: 2020-04-29
---

_Célio Dias Santos Júnior, Luis Pedro Coelho_

<div style="padding: 1em" markdown="1">

</div>
```
What you need to change is the title,the date and the name.

(3)If you want to add images,all the images should be stored in `/assets/` folder.
You can add image like this:
`![alt]({{ site.baseurl }}/assets/images/filename.jpg)`
such as:
`![figure4]({{ site.baseurl }}/assets/2020-04-10-cryptic/image1_after4.png )`

## 2. Add your images in /assets folder
You can create your images folder in /assets folder,and add your images.Then when you add images in your article,add the address of your images.
