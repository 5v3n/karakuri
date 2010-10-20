# extension to Karakuri with special methods for serious
require 'karakuri'
module SeriousBlogHelper
  #extract tags from article
  def SeriousBlogHelper.tags_from_article(article=nil)
    tags_marker = %&tags"=>&
    if article && article.inspect.index(tags_marker)
      tags_start_index=article.inspect.index(tags_marker) + tags_marker.length
      tags_end_index = article.inspect.index("\"," ,tags_start_index)
      tags = article.inspect[tags_start_index+1..tags_end_index-1]
    end
  end
end
