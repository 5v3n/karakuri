# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'blog_helper'

class BlogHelperTest < Test::Unit::TestCase
  #TODO DRY! use methods for the repetitive parts of the test!
  STRING_00 = ""
  STRING_01 = "tag_1"
  STRING_02 = "tag_1, tag_2"
  STRING_03 = "tag_1, tag_2, tag_3"
  STRING_04 = "hacks, love, rock 'n' roll"

  EXPECTED_SHORT_URL  = "http://bit.ly/c5BSQl\n"
  TEST_URL            = 'http://5v3n.com'
  BITLY_LOGIN         = 'bitlyapidemo'
  BITLY_API_KEY       = 'R_0da49e0a9118ff35f52f629d2d71bf07'


  def test_process_to_array
    result_nil = BlogHelper::csv_to_array(nil)
    assert("nil should return nil!", result_nil == nil)
    result_00 = BlogHelper::csv_to_array(STRING_00)
    assert("Unexpected result for #{STRING_00}!", result_00 == [])
    result_01 = BlogHelper::csv_to_array(STRING_01)
    assert("Unexpected result for #{STRING_01}!", result_01 == ["tag_1"])
    result_02 = BlogHelper::csv_to_array(STRING_02)
    assert("Unexpected result for #{STRING_02}!", result_02 == Array["tag_1", "tag_2"])
    result_03 = BlogHelper::csv_to_array(STRING_03)
    assert("Unexpected result for #{STRING_03}!", result_03 == Array["tag_1", "tag_2", "tag_3"])
    result_04 = BlogHelper::csv_to_array(STRING_04)
    assert("Unexpected result for #{STRING_04}!", result_04 == Array["hacks", "love", "rock 'n' roll"])
  end
  def test_tag_link_list
    result_nil = BlogHelper::tag_link_list(nil)
    assert("Unexpected mapping for nil!", result_nil == nil)
    result_00 = BlogHelper::tag_link_list(STRING_00)
    assert("Unexpected mapping for #{STRING_00}!", result_00 == "")
    result_01 = BlogHelper::tag_link_list(STRING_01)
    assert("Unexpected mapping for #{STRING_01}!", result_01 == "<a href=/tagged?tag=tag_1 >tag_1</a> ")
    result_02 = BlogHelper::tag_link_list(STRING_02)
    assert("Unexpected mapping for #{STRING_02}!", result_02 == "<a href=/tagged?tag=tag_1 >tag_1</a> <a href=/tagged?tag=tag_2 >tag_2</a> ")
    result_03 = BlogHelper::tag_link_list(STRING_03)
    assert("Unexpected mapping for #{STRING_03}!", result_03 == "<a href=/tagged?tag=tag_1 >tag_1</a> <a href=/tagged?tag=tag_2 >tag_2</a> <a href=/tagged?tag=tag_3 >tag_3</a> ")
    result_04 = BlogHelper::tag_link_list(STRING_04)
    assert("Unexpected mapping for #{STRING_04}!", result_04 == "<a href=/tagged?tag=hacks >hacks</a> <a href=/tagged?tag=love >love</a> <a href=/tagged?tag=rock 'n' roll >rock 'n' roll</a> ")
  end
  def test_short_url_bitly
    short_url = BlogHelper::short_url_bitly(TEST_URL, "", "")
    assert(short_url == TEST_URL, "generated short url: '#{short_url}', but should be '#{TEST_URL}' since no login and/or api key are given.")
    aok = false
    begin
      short_url = BlogHelper::short_url_bitly("invalid url", BITLY_LOGIN, BITLY_API_KEY)
    rescue URI::InvalidURIError
       aok = true
    ensure # make sure the result is checked & the remaining tests are executed
      assert(aok, "Invalid url should have resulted in an InvalidURIError!")
      short_url = BlogHelper::short_url_bitly(TEST_URL, BITLY_LOGIN, BITLY_API_KEY)
      assert(short_url != 'RATE_LIMIT_EXCEEDED', "Use your own login & api key if the demo account's rate limit is reached...")
      assert(short_url == EXPECTED_SHORT_URL, "generated short url: '#{short_url}', but should be '#{EXPECTED_SHORT_URL}'")
    end
  end
end
