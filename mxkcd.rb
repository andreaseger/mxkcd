require 'rss'
require 'open-uri'
require 'twitter'
require 'yaml'

auth = YAML.load IO.read('config/auth.yml')
Twitter.configure do |config|
  config.consumer_key = auth['consumer_key']
  config.consumer_secret = auth['consumer_secret']
  config.oauth_token = auth['token']
  config.oauth_token_secret = auth['secret']
end

LAST_TWEET_TRACKER = 'last_tweeted_xkcd'
def last_xkcd
  if File.exists? LAST_TWEET_TRACKER
    @last_xkcd ||= Time.at IO.read(LAST_TWEET_TRACKER).to_i
  else
    # default to 3 days ago
    Time.now - 60*60*24*3
  end
end
def update_last_xkcd item
  @last_xkcd=item.pubDate
  IO.write(LAST_TWEET_TRACKER, @last_xkcd.to_i)
end

# mobile subdomain
# image src from description
# should be always < 140 characters
def build_tweet item
  [
    item.title,
    item.description.match(/img src="(?<image>.*\.png)"/)[:image],
    item.link.insert(7,'m.')
  ].join(' ')
end

def tweet item
  tweet = build_tweet item
  if tweet.size < 140
    Twitter.update tweet
    puts "[info] #{tweet}"
  else
    puts "[error] tweet to long: #{tweet}"
  end
end

url = 'http://xkcd.com/rss.xml'
open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  feed.items.select{ |item| item.pubDate > last_xkcd }.each do |item|
    tweet item
  end
  update_last_xkcd feed.items.first
end


