require 'open-uri'
require 'twitter'
require 'rss'
require 'json'
require 'ostruct'

auth = JSON.parse IO.read('config/auth.json'), object_class: OpenStruct
Twitter.configure do |config|
  config.consumer_key = auth.consumer_key
  config.consumer_secret = auth.consumer_secret
  config.oauth_token = auth.token
  config.oauth_token_secret = auth.secret
end

class Xkcd
  TRACKER = 'last_tweeted_xkcd'
  URL = 'http://xkcd.com/rss.xml'
  def xkcd_tracker
    if File.exists? TRACKER
      @tracker ||= Time.at IO.read(TRACKER).to_i
    else
      # default to 3 days ago
      Time.now - 60*60*24*3
    end
  end
  def update_xkcd_tracker item
    @tracker=item.pubDate
    IO.write(TRACKER, @tracker.to_i)
  end

  # mobile subdomain
  # image src from description
  # should be always < 140 characters
  def build_tweet item
    [
      item.title,
      item.description.match(/img src="(?<image>.*\.png)"/)[:image],
      item.link.insert(7,'m.'),
      "#xkcd"
    ].join(' ')
  end

  def tweet item
    tweet = build_tweet item
    if tweet.size < 140
      Twitter.update tweet
      puts "[info] #{tweet}"
      return true
    else
      puts "[error] tweet to long: #{tweet}"
      return false
    end
  rescue Twitter::Error::TooManyRequests => error
    puts "[error] twitter rate limit, reset in #{error.rate_limit.reset_in}s"
    return false
  end

  def run
    open(URL) do |rss|
      feed = RSS::Parser.parse(rss)
      print "#{Time.now.utc.strftime "%FT%R "}"
      last_xkcd = nil
      todo = feed.items.select{ |item| item.pubDate > xkcd_tracker }
      (puts "no new comics" and exit) if todo.empty?
      todo.reverse.each do |item|
        if tweet item
          last_xkcd = item
          sleep 1 #short delay after each tweet
        end
      end
      update_xkcd_tracker last_xkcd if last_xkcd
    end
  end
end

class XkcdTime < Xkcd
  URL2 = 'http://xkcd.mscha.org/time_latest.csv'
  URL = 'http://xkcd.mscha.org/time.json'
  TRACKER = 'last_tweeted_time_xkcd'

  def xkcd_time_tracker
    if File.exists? TRACKER
      @tracker ||= Time.at IO.read(TRACKER).to_i
    else
      # default to 3 hours ago
      Time.now - 60*60*3
    end
  end
  def update_xkcd_time_tracker item
    @tracker=item.epoch
    IO.write(TRACKER, @tracker.to_i)
  end
  def build_tweet item
    [
      "Time",
      item.downloadedUrl,
      "#time #xkcd"
    ].join(' ')
  end
  def run
    open(URL) do |data|
      items = JSON.parse data.read, object_class: OpenStruct
      print "#{Time.now.utc.strftime "%FT%R "}"
      last_xkcd = nil
      todo = items.select{ |item| Time.at(item.epoch) > xkcd_time_tracker }
      (puts "no new time frames" and exit) if todo.empty?
      todo.each do |item|
        if tweet item
          last_xkcd = item
          sleep 1 #short delay after each tweet
        end
      end
      update_xkcd_time_tracker last_xkcd if last_xkcd
    end
  end
end

Xkcd.new.run
XkcdTime.new.run

