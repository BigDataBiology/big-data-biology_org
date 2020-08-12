# How to write posts in the blog
## 1. Add your post file in /_posts folder
Notice the format:

(1)The name of your file should be:`Year-Month-day-name.md`,such as `2020-04-29-NME2.md`

(2)The head of the article should be:


```
---
layout: single
title: "your title"
date: year-month-day
---
<style>
div.caption {
    font-size: small;
    color: #333333;
    padding-bottom:1em;
    padding-left:1em;
    padding-right:1em;
    padding-top:0em;
}
</style>

your name

<div style="padding: 1em" markdown="1">

</div>
```
such as

```
---
layout: single
title: "Methionine tanks: how we almost got fooled by a flawed dataset"
date: 2020-04-29
---
<style>
div.caption {
    font-size: small;
    color: #333333;
    padding-bottom:1em;
    padding-left:1em;
    padding-right:1em;
    padding-top:0em;
}
</style>

_Célio Dias Santos Júnior, Luis Pedro Coelho_

<div style="padding: 1em" markdown="1">

</div>
```
What you need to change is the title,the date and the name.

(3)If you want to add images,all the images should be stored in `/assets/` folder.
You can add image like this:
`![](/assets/2020-04-29-NME/figure_1.png)`

## 2. Add your images in /assets folder
You can create your images folder in it,and add your images.Then when you add images in your article,change the address of your images.
