require 'cgi'
require 'net/http'
require 'uri'

#
# Some useful feature for toto and the likes. Basically, any ruby based blog or site.
#
module Karakuri
  #
  # create a list of links to tagged articles, default link_format: <code>%&amp;&lt;a href=&quot;/tagged?tag=#{tag}&quot; title=&quot;articles concerning #{tag}&quot; &gt;#{tag}&lt;/a&gt; &amp;</code>
  #
  def Karakuri.tag_link_list(csv_string)
    # read csv-string into array
    tag_list = csv_to_array(csv_string)
    if tag_list
      tag_string = ""
      #TODO pass a format via parameter
      tag_list.each { |tag| tag_string << %&<a href="/tagged?tag=#{tag}" title="articles concerning #{tag}" >#{tag}</a> & }
    end
    tag_string
  end
  #
  # processes a csv-string into an array
  #
  def Karakuri.csv_to_array(csv_string)
      #split & handle forgotten spaces after the separator. then flatten the multidemnsional array:
      csv_string.split(', ').map{ |e| e.split(',')}.flatten if csv_string
  end
  #
  # pass the path (@path for a toto blog) & the desired SEO ending, e.g. the name of your blog.
  # example for toto: <code>seo_friendly_title(@path, title, "mysite.com") will produce 'subpage | mysite.com' as seo friendly page title.</code>
  #
  def Karakuri.seo_friendly_title(path, title, seo_ending)
    #TODO use custom title separator...
       if path == 'index'
        page_title = seo_ending
       elsif path.split('/').compact.length == 4
        page_title = title << " | #{seo_ending}"
       else
        page_title = path.capitalize.gsub(/[-]/, ' ') << " | #{seo_ending}"
      end
      page_title
  end
  #
  #Generates javascript to include to the bottom of your index page.
  #Appending '#disqus_thread' to the end of permalinks will replace the text of these links with the comment count.
  #
  #For example, you may have a link with this HTML: <code>&lt;a href=&quot;http://example.com/my_article.html#disqus_thread&quot;&gt;Comments&lt;/a&gt; </code>  The comment count code will replace the text "Comments" with the number of comments on the page
  #
  #(see http://disqus.com/comments/universal/ for details)
  #
  def Karakuri.disqus_comment_count_js(disqus_shortname)
    %&
      <script type="text/javascript">
      var disqus_shortname = '#{disqus_shortname}';
      (function () {
        var s = document.createElement('script'); s.async = true;
        s.src = 'http://disqus.com/forums/#{disqus_shortname}/count.js';
        (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
      }());
      </script>

    & if disqus_shortname
  end
  #
  # Retrieve bit.ly shortened url
  #
  def Karakuri.short_url_bitly(url, login, api_key)
    if api_key != "" && login != ""
      rest_call=%{http://api.bit.ly/v3/shorten?login=#{login}&apikey=#{api_key}&longUrl=#{url}&format=txt}
      begin
        Net::HTTP::get(URI.parse(rest_call)) # handle http errors (esp. timeouts!)
      rescue URI::InvalidURIError
        raise URI::InvalidURIError
      rescue
        url#in the case of a web service or HTTP error, we'll just ignore it & return the long url
      end
    else
      url #fallback: return long url if no proper login has been provided. TODO: check if a call w/o login is possible
    end
  end
  #desired articles matching a corresponding tag
  def Karakuri.desired_articles(articles, tag)
    if(articles && tag)
      articles.select do |a|
        tags = Karakuri::csv_to_array(a[:tags])
        tags.include?(tag) if tags
      end
    end
  end
  # extract desired tag from <code>env["QUERY_STRING"]</code> or an equally formed expression, e.g. tag=desired_tag
  def Karakuri.desired_tag(query_string)
    if query_string
      start = query_string.index("tag=")
      if start
        start = start + 3
        stop = query_string.index("&")
        stop = 0 unless stop
        desired_tag = query_string[start+1..stop-1]
        desired_tag = CGI::unescape(desired_tag)
      else
        '' #fallback: return empty string to prevent nil errors
      end
    end
  end

  #
  # Tag cloud, return a hash of tags and their frequency
  #
  def Karakuri.tag_cloud(articles)
    tag_cloud = {}
    if(articles)
      articles.select do |article|
        if tags = csv_to_array(article[:tags])
          tags.each do |tag| 
            if tag_cloud.has_key? tag
              tag_cloud[tag] += 1
            else
              tag_cloud[tag] = 1
            end
          end
        end
      end
    end
    tag_cloud
  end

end

