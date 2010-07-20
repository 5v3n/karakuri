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

  EXPECTED_TAG_01     = "rock 'n' roll"
  GIVEN_QUERY_01      = "tag=rock%20%27n%27%20roll"

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
  def test_desired_tag
    result = BlogHelper::desired_tag(GIVEN_QUERY_01)
    assert(result == EXPECTED_TAG_01, "Wrong tag extracted! Expected '#{EXPECTED_TAG_01}', but was '#{result}'")
    result = BlogHelper::desired_tag("tag=")
    assert(result == '', "Result expected to be empty, but was #{result}")
    result = BlogHelper::desired_tag("tag")
    assert(result == '', "Result expected to be empty, but was #{result}")
    result = BlogHelper::desired_tag("")
    assert(result == '', "Result expected to be empty, but was #{result}")
    result = BlogHelper::desired_tag(nil)
    assert(result == nil, "Result expected to be nil, but was #{result}")
  end
  def test_desired_articles
    #there's no article objects in this context, so we just use hash mock-ups...
    article_01_mock = Hash.new()
    article_02_mock = Hash.new()
    article_03_mock = Hash.new()

    article_01_mock[:tags] = STRING_04
    article_01_mock[:title] = "article01"
    article_02_mock[:tags] = ""
    article_02_mock[:title] = "article02"
    article_03_mock[:tags] = "love"
    article_03_mock[:title] = "article03"

    articles = Array.new()
    articles << article_01_mock << article_02_mock << article_03_mock

    result = BlogHelper::desired_articles(articles, "love")
    assert(result != nil && result[0] != nil && result[0] == article_01_mock && result[1] != nil && result[1] == article_03_mock,
      "Result expected to be first & second article, but was #{result.inspect}")

    result = BlogHelper::desired_articles(articles, "hacks")
    assert(result != nil && result.first != nil && result.first == article_01_mock, "Result expected to be first article, but was #{result.inspect}")

    result = BlogHelper::desired_articles(articles, nil)
    assert(result == nil, "Result expected to be nil, but was #{result}")

    result = BlogHelper::desired_articles(nil, nil)
    assert(result == nil, "Result expected to be nil, but was #{result}")
  end

end
