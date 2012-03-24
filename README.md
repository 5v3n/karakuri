# Karakuri

Having a closer look at ruby based blogging platforms like [serious](http://github.com/colszowka/serious) and [toto](http://cloudhead.io/toto), I missed some functionality.

This a a collection of tools usable in both platforms. The project was formerly known as blog_helper, but Karakuri is a far more suitable name & will be used from now on.

## Features

- tag your posts
- use seo friendly page titles
- use the disqus comment counter
- a workaround for serious allowing you to use generic yaml fields

## Installation

It's a piece of cake: just install the gem. Simply add `gem 'karakuri'` to your Gemfile or use `sudo gem install karakuri` to get going.

For a default karakuri powered toto template, check out [dorothy's sister karathy](https://github.com/5v3n/karathy).

## Usage

Piece of cake, again: all you have to do is use `<% require 'karakuri'%>` in your .rhtml or .erb file and call the corresponding methods.

### SEO friendly titles
For example, to use seo friendly titles, your layout.rhtml should be looking like this:


    <!doctype html>
    <html>
      <head>
        <% require 'karakuri'
           page_title = Karakuri::seo_friendly_title(@path, title, 'yourSitesTitle.com')
        %>
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
      <% require 'karakuri' %>
      <% for article in articles[0...10] %>
        <article class="post">
          <header>
            <h1><a href="<%= article.path %>"><%= article.title %></a></h1>
            <span class="descr"><%= article.date %></span><% 10.times { %>&nbsp;<%}%>
            <span class="tags">
                <%= Karakuri::tag_link_list(article[:tags])  %>
            </span><% 10.times { %>&nbsp;<%}%>
    .
    .
    .



And again: piece of cake ;-). Now all we need to add is a page that displays articles belonging to a ceratin tag:

Create a page called `tagged.rhtml` in your `templates/pages` directory that looks like this:


    <%
     require 'karakuri'
     desired_tag = Karakuri::desired_tag(env["QUERY_STRING"])
    %>
    <h1>Posts filed under '<%= desired_tag %>': </h1>
    <ul>

    <% Karakuri::desired_articles(@articles, desired_tag).each do |article| %>
      <li>
        <span class="descr"><a href="<%= article.path %>" alt="<%= article.title %>"><%= article.title %></a><br/></span>
      </li>
    <% end %>
    </ul>
    <br/>

Now, you did most likely implement a tag listing on your toto blog. Congrats!

### Tag Cloud

Example usage:

    <h1>Tags</h1>
    <%  Karakuri::tag_cloud(@articles).each do |tag, freq| %>
        <%= %|<a href="/tagged?tag=#{tag}" alt="articles concerning #{tag}" style="font-size: #{10 * freq}px">#{tag}</a>| %>
    <% end %>

### short url (via bit.ly)

To use a bit.ly shortened URL, just call the followin function inside a .rhtml file:

    <%= Karakuri::short_url_bitly(<url>, <bit.ly login name>, <bit.ly api key>) %>


### disqus comment counter

Basically just adds the necessary java script to enable the disqus comment counter. For best performance, place it near the end of the page:

        <%= Karakuri::disqus_comment_count_js(@config[:disqus]) %>
      </body>

    </html>

Mind the usage of `@config[:disqus]`, this enables configuration via `config.ru`.

To access the comment count, use `#disqus_thread` at the end of the permalink to the post & it will be replaced with the disqus comment count:

    <a href="<%= article.path %>#disqus_thread">&nbsp;</a>

Will result in the number of comments of the article the permalink posts to.

### serious custom yaml field reader

I hacked serious' custom yaml field access (quite dirty hack) - but please refer to the source & ri for that, I don't use serious anymore.
