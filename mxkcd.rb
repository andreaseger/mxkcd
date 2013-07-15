require 'rss'
require 'open-uri'
require 'twitter'

def build_tweet item
  [
    item.title,
    item.link, 
    item.description.match(/img src="(?<image>.*\.png)"/)[:image]
  ].join(' ')
end

url = 'http://xkcd.com/rss.xml'
open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  feed.items.each do |item|
    puts build_tweet(item)
  end
end


