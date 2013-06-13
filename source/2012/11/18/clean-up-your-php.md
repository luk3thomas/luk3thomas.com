---
layout: post
tags: [PHP]
category: Programming
title: Cleaning up your PHP code with printf
---

I build a lot of [WordPress](http://wordpress.org/) sites, and I often work on code from other developers. I have seen a fair bit of PHP code and it always bothers me when I see code like this:
{% highlight php %}
<ul class="slides">
  <?php while($query->have_posts()): $query->the_post(); ?>
    <li style="background:<?php if(get_field('slide_background_color')): the_field('slide_background_color'); else: echo '#000'; endif; ?>">
      <a href="<?php the_permalink() ?>"> <?php get_the_image(array('size' => 'slideshow', 'link_to_post' => FALSE)); ?> </a>
    </li>
  <?php endwhile; ?>
</ul>
{% endhighlight %}

The reason I cringe when I see that is 
1. It is tough to quickly understand what is happening
1. I know mantainence time for that style of coding is higher.

How I usually deal with code like that is to move the code into a ```printf()``` or ```sprintf()``` function. I am a fan of moving all variable assignments above the HTML code and then plugging the variables into the ```printf()``` function, like so.

{% highlight php %}
<ul class="slides">
  <?php while($query->have_posts()): $query->the_post(); 
    $color = get_field('slide_background_color') ? the_field('slide_background_color') : '#000';
    $image = get_the_image(array('size' => 'slideshow', 'link_to_post' => false)); 
    $href  = get_permalink();

    printf('
      <li style="background:%s">
        <a href="%s">%s</a>
      </li>
    '
    , $color
    , $href
    , $image
    );

  endwhile; 
  ?>
</ul>
{% endhighlight %}

There are a couple reasons why I like that:
1. Since all the variables are defined before they are stuffed into the template, it is easier to debug if something is going crazy.
1. It is easier to edit the HTML template. Define a new variable, add a place holder and plug the variable into the ```printf()``` function.
1. I can read and understand the code, *quickly*.
1. The code is easier to maintain later on. 

This is just my personal preference at the moment. I am sure there is a better way to do things, so if you have an opinion then toot your horn and let me know.
