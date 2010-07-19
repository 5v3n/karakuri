# BlogHelper

Having a closer look at ruby based blogging platforms like [serious](http://github.com/colszowka/serious) and [toto](http://cloudhead.io/toto), I missed some functionality.

This a a collection of tools usable in both platforms.

## Features

- tag your posts
- use seo friendly page titles
- use the disqus comment counter
- a workaround for serious allowing you to use generic yaml fields

## Installation

It's a piece of cake: just use the `gem` tool to get going with the _blog_helper_: `sudo gem install blog_helper`

If you want to use features that rely on accessing the http requests like the _tag_ feature, you'll need to use the [_toto_prerelease_](http://github.com/5v3n/toto).

Please follow the instrucions there to do so.

## Usage

Piece of cake, again: all you have to do is use `<% require 'blog_helper'%>` in your .rhtml or .erb file and call the corresponding methods.

### SEO friendly titles
For example, to use seo friendly titles, your layout.rhtml should be looking like this:


    <!doctype html>
    <html>
      <head>
        <% require 'blog_helper'
           page_title = BlogHelper::seo_friendly_title(@path, title, 'yourSitesTitle.com')
        %>
    .
    .
    .
        <title><%=  page_title %></title>
        <link rel="alternate" type="application/atom+xml" title="<%= page_title %> - feed" href="/index.xml" />
    .
    .
    .
### Tags
Adding the tagging feature requires the _toto_prerelease_ as mentioned above, since we need the http request to apply our little hack.

To add a list of tags to your article, just use a custom yaml attribute:

    title: The Wonderful Wizard of Oz
    author: Lyman Frank Baum
    date: 1900/05/17
    tags: hacks, love, rock 'n' roll

    Dorothy lived in the midst of the great Kansas prairies, with Uncle Henry,
    who was a farmer, and Aunt Em, who was the farmer's wife.

Next, you need a place to show the tag links, for example the index.rhtml:

    <section id="articles">
      <% require 'blog_helper' %>
      <% for article in articles[0...10] %>
        <article class="post">
          <header>
            <h1><a href="<%= article.path %>"><%= article.title %></a></h1>
            <span class="descr"><%= article.date %></span><% 10.times { %>&nbsp;<%}%>
            <span class="tags">
                <%= BlogHelper::tag_link_list(article[:tags])  %>
            </span><% 10.times { %>&nbsp;<%}%>
    .
    .
    .



And again: piece of caked ;-). Now all we need to add is a page that displays articles belonging to a ceratin tag:

Create a page called `tagged.rhtml` in your `templates/pages` directory that looks like this:

    <%#
    # search given tags...
    %>
    <%
     require 'blog_helper'
     desired_tag = BlogHelper::desired_tag(env["QUERY_STRING"])
    %>
    <h1>Posts filed under '<%= desired_tag %>': </h1>
    <ul>

    <% BlogHelper::desired_articles(@articles, desired_tag).each do |article| %>
      <li>
        <span class="descr"><a href="<%= article.path %>" alt="<%= article.title %>"><%= article.title %></a><br/></span>
      </li>
    <% end %>
    </ul>
    <br/>

Now, you did most likely implement a tag listing on your toto blog. Congrats!


### short url (via bit.ly)

To use a bit.ly shortened URL, just call the followin function inside a .rhtml file:

    <%= BlogHelper::short_url_bitly(<url>, <bit.ly login name>, <bit.ly api key>) %>


### disqus comment counter

TBD... I have to refer to the source & ri for now.

### serious custom yaml field reader

TBD... I have to refer to the source & ri for now.