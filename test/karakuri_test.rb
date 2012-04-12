# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'karakuri'

class KarakuriTest < Test::Unit::TestCase
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
    result_nil = Karakuri::csv_to_array(nil)
    assert(result_nil == nil, "nil should return nil!")
    result_00 = Karakuri::csv_to_array(STRING_00)
    assert(result_00 == [], "Unexpected result for #{STRING_00}!")
    result_01 = Karakuri::csv_to_array(STRING_01)
    assert(result_01 == ["tag_1"], "Unexpected result for #{STRING_01}!")
    result_02 = Karakuri::csv_to_array(STRING_02)
    assert(result_02 == Array["tag_1", "tag_2"], "Unexpected result for #{STRING_02}!")
    result_03 = Karakuri::csv_to_array(STRING_03)
    assert(result_03 == Array["tag_1", "tag_2", "tag_3"], "Unexpected result for #{STRING_03}!")
    result_04 = Karakuri::csv_to_array(STRING_04)
    assert(result_04 == Array["hacks", "love", "rock 'n' roll"], "Unexpected result for #{STRING_04}!")
  end
  def test_tag_link_list
    result_nil = Karakuri::tag_link_list(nil)
    assert("Unexpected mapping for nil!", result_nil == nil)
    result_00 = Karakuri::tag_link_list(STRING_00)
    assert("Unexpected mapping for #{STRING_00}!", result_00 == "")
    result_01 = Karakuri::tag_link_list(STRING_01)
    assert("Unexpected mapping for #{STRING_01}!", result_01 == "<a href=/tagged?tag=tag_1 >tag_1</a> ")
    result_02 = Karakuri::tag_link_list(STRING_02)
    expected_result_02 = %{<a href="/tagged?tag=tag_1" title="articles concerning tag_1">tag_1</a> <a href="/tagged?tag=tag_2" title="articles concerning tag_2">tag_2</a> }
    assert(result_02 == expected_result_02, "Unexpected mapping for #{STRING_02}!")
    result_03 = Karakuri::tag_link_list(STRING_03)
    expected_result_03 = %{<a href="/tagged?tag=tag_1" title="articles concerning tag_1">tag_1</a> <a href="/tagged?tag=tag_2" title="articles concerning tag_2">tag_2</a> <a href="/tagged?tag=tag_3" title="articles concerning tag_3">tag_3</a> }
    assert(result_03 == expected_result_03, "Unexpected mapping for #{STRING_03}!")
    result_04 = Karakuri::tag_link_list(STRING_04)
    expected_result_04 = %{<a href="/tagged?tag=hacks" title="articles concerning hacks">hacks</a> <a href="/tagged?tag=love" title="articles concerning love">love</a> <a href="/tagged?tag=rock 'n' roll" title="articles concerning rock 'n' roll">rock 'n' roll</a> }
    assert(result_04 == expected_result_04, "Unexpected mapping for #{STRING_04}!")
  end
  def test_short_url_bitly
    short_url = Karakuri::short_url_bitly(TEST_URL, "", "")
    assert(short_url == TEST_URL, "generated short url: '#{short_url}', but should be '#{TEST_URL}' since no login and/or api key are given.")
    aok = false
    begin
      short_url = Karakuri::short_url_bitly("invalid url", BITLY_LOGIN, BITLY_API_KEY)
    rescue URI::InvalidURIError
       aok = true
    ensure # make sure the result is checked & the remaining tests are executed
      assert(aok, "Invalid url should have resulted in an InvalidURIError!")
      short_url = Karakuri::short_url_bitly(TEST_URL, BITLY_LOGIN, BITLY_API_KEY)
      assert(short_url != 'RATE_LIMIT_EXCEEDED', "Use your own login & api key if the demo account's rate limit is reached...")
      assert(short_url == EXPECTED_SHORT_URL, "generated short url: '#{short_url}', but should be '#{EXPECTED_SHORT_URL}'")
    end
  end
  def test_desired_tag
    result = Karakuri::desired_tag(GIVEN_QUERY_01)
    assert(result == EXPECTED_TAG_01, "Wrong tag extracted! Expected '#{EXPECTED_TAG_01}', but was '#{result}'")
    result = Karakuri::desired_tag("tag=")
    assert(result == '', "Result expected to be empty, but was #{result}")
    result = Karakuri::desired_tag("tag")
    assert(result == '', "Result expected to be empty, but was #{result}")
    result = Karakuri::desired_tag("")
    assert(result == '', "Result expected to be empty, but was #{result}")
    result = Karakuri::desired_tag(nil)
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

    result = Karakuri::desired_articles(articles, "love")
    assert(result != nil && result[0] != nil && result[0] == article_01_mock && result[1] != nil && result[1] == article_03_mock,
      "Result expected to be first & second article, but was #{result.inspect}")

    result = Karakuri::desired_articles(articles, "hacks")
    assert(result != nil && result.first != nil && result.first == article_01_mock, "Result expected to be first article, but was #{result.inspect}")

    result = Karakuri::desired_articles(articles, nil)
    assert(result == nil, "Result expected to be nil, but was #{result}")

    result = Karakuri::desired_articles(nil, nil)
    assert(result == nil, "Result expected to be nil, but was #{result}")
  end
  def test_tag_cloud
    #mock articles
    article_01_mock = Hash.new()
    article_02_mock = Hash.new()
    article_03_mock = Hash.new()

    article_01_mock[:title] = "article01"
    article_01_mock[:tags] = STRING_01

    article_02_mock[:title] = "article02"
    article_02_mock[:tags] = STRING_02

    article_03_mock[:title] = "article03"
    article_03_mock[:tags] = STRING_03

    articles = Array.new()
    articles << article_01_mock << article_02_mock << article_03_mock

    result = Karakuri::tag_cloud(articles)
    assert(result != nil, "Result is expected to be not nil")

    #test tags
    tags = result.keys
    expected_tags = %w[ tag_1 tag_2 tag_3]

    assert(tags != nil && tags - expected_tags == [], "Wrong extracted tags. Expected #{expected_tags}, but was #{tags}")

    #test tag frequency
    tag_1 = expected_tags[0]
    tag1_exp_freq = 3

    tag_2 = expected_tags[1]
    tag2_exp_freq = 2

    tag_3 = expected_tags[2]
    tag3_exp_freq = 1

    assert(result[tag_1] == tag1_exp_freq, "Frequency for tag 'tag_1' is wrong, expected #{tag1_exp_freq}, was #{result[tag_1]}")
    assert(result[tag_2] == tag2_exp_freq, "Frequency for tag 'tag_2' is wrong, expected #{tag2_exp_freq}, was #{result[tag_2]}")
    assert(result[tag_3] == tag3_exp_freq, "Frequency for tag 'tag_3' is wrong, expected #{tag3_exp_freq}, was #{result[tag_3]}")

    #test for edge cases:

    #passing in nil
    result = Karakuri::tag_cloud(nil)
    assert(result == {}, "Result is expected to be an empty hash, but was #{result}")

    #pass in article with no tags
    article_mock = Hash.new()
    article_mock[:title] = "article"

    articles = [article_mock]

    result = Karakuri::tag_cloud(articles)
    assert(result == {}, "Result is expected to be an empty hash, but was #{result}")

    #pass in article with empty string as a tag
    article_mock = Hash.new()
    article_mock[:tags] = ""

    articles = [article_mock]

    result = Karakuri::tag_cloud(articles)
    assert(result == {}, "Result is expected to be an empty hash, but was #{result}")

  end

  def test_link_format
    #mock articles
    article_01_mock = Hash.new()
    article_02_mock = Hash.new()

    article_01_mock[:tags] = STRING_01

    article_02_mock[:tags] = STRING_02

    # Test the default link format
    result_01 = Karakuri::tag_link_list(article_01_mock[:tags])
    expected_01 = "<a href=\"/tagged?tag=#{STRING_01}\" title=\"articles concerning #{STRING_01}\">#{STRING_01}</a> "
    assert(result_01 == expected_01 , "Link for tag is wrong, expected #{expected_01}, was #{result_01}")

    result_02 = Karakuri::tag_link_list(article_02_mock[:tags])
    expected_02 =  '<a href="/tagged?tag=tag_1" title="articles concerning tag_1">tag_1</a> <a href="/tagged?tag=tag_2" title="articles concerning tag_2">tag_2</a> '
    assert(result_02 == expected_02, "Link for tag is wrong, expected #{expected_02}, was #{result_02}")

    # Test customed link format
    Karakuri.link_format '<a href="/{tag}">{tag}</a>'

    result_01 = Karakuri::tag_link_list(article_01_mock[:tags])
    expected_01 = "<a href=\"/#{STRING_01}\">#{STRING_01}</a>"
    assert(result_01 == expected_01 , "Link for tag is wrong, expected #{expected_01}, was #{result_01}")

    result_02 = Karakuri::tag_link_list(article_02_mock[:tags])
    expected_02 =  '<a href="/tag_1">tag_1</a><a href="/tag_2">tag_2</a>'
    assert(result_02 == expected_02, "Link for tag is wrong, expected #{expected_02}, was #{result_02}")

    # Reset to default for other tests
    Karakuri.link_format '<a href="/tagged?tag={tag}" title="articles concerning {tag}">{tag}</a> '
  end

  def test_title_separator
    # Test the default title separator '|'
    path = 'example'
    title = 'test'
    seo_ending = 'Karakuri'
    result = Karakuri::seo_friendly_title(path, title, seo_ending)
    expected = "Example | Karakuri"
    assert(result == expected, "Page title is wrong, expected #{expected}, was #{result}")

    # Test customed title separator '+'
    Karakuri.title_separator '+'
    result = Karakuri::seo_friendly_title(path, 'test', 'Karakuri')
    expected = "Example + Karakuri"
    assert(result == expected, "Page title is wrong, expected #{expected}, was #{result}")

    # Reset to default for other tests
    Karakuri.title_separator '|'
  end

end

