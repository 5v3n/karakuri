# Some useful feature for serious, toto and the likes. Basically, any ruby based blog or site.
module BlogHelper
  # create a list of links to tagged articles, default link_format: <a href=/tagged?tag=&+tag+%& >#{tag}</a>
  def BlogHelper.create_tag_link_list(csv_string)
    # read csv-string into array
    tag_list = process_to_array(csv_string)
    if tag_list
      tag_string = ""
      tag_list.each { |tag| tag_string << %&<a href="/tagged?tag=#{tag}" alt="articles concerning #{tag}" >#{tag}</a> & }
    end
    tag_string
  end
  # processes a csv-string into an array
  def BlogHelper.process_to_array(csv_string)
    if csv_string
      #split & handle forgotten spaces after the separator. then flatten the multidemnsional array:
      result = csv_string.split(', ').map{ |e| e.split(',')}.flatten
    end
  end
=begin
Generates javascript to include to the bottom of your index page.
Appending '#disqus_thread' to the end of permalinks will replace the text of these links with the comment count.

For example, you may have a link with this HTML: <a href="http://example.com/my_article.html#disqus_thread">Comments</a>  The comment count code will replace the text "Comments" with the number of comments on the page

(see http://disqus.com/comments/universal/ for details)
=end
  def BlogHelper.disqus_comment_count_js(disqus_shortname)
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
end