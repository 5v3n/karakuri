# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'serious_blog_helper'

class SeriousBlogHelperTest < Test::Unit::TestCase
  # TODO implement proper tests!
  def test_tags_from_article
    result = SeriousBlogHelper::tags_from_article(nil)
    assert("nil should lead to nil in the result", result == nil)
  end
end
