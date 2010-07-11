# BlogHelper

Having a closer look at ruby based blogging platforms like [serious](http://github.com/colszowka/serious) and [toto](http://cloudhead.io/toto), I missed some functionality.

This a a collection of tools usable in both platforms.

## Features

- tag your posts
- use seo friendly page titles
- use the disqus comment counter
- a workaround for seriuous allowing you to use generic yaml fields

## Installation

It's a piece of cake: just use the `gem` tool to get going with the _blog_helper_: `sudo gem install blog_helper`

If you want to use features that rely on accessing the http requests like the _tag_ feature, you'll need to use the [_toto_prerelease_](http://github.com/5v3n/toto).

Please follow the instrucions there to do so.

## Usage

Piece of cake, again: all you have to do is use `<% require 'blog_helper'%>` in your .rhtml or .erb file and call the corresponding methods.

For example, to use seo friendly titles, your layout.rhtml should be looking like this:


    <!doctype html>
    <html>
      <head>
        <% require 'blog_helper'
           page_title = BlogHelper::generate_title(@path, title, 'yourSitesTitle.com')
        %>
    .
    .
    .
        <title><%=  page_title %></title>
        <link rel="alternate" type="application/atom+xml" title="<%= page_title %> - feed" href="/index.xml" />
    .
    .
    .
