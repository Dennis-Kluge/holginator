require "rss"
require "json"
require "rest_client"
require "redis"

module Holginator
  class FeedHandler

    LINK_PREFIX = "http://holginator.poddata.net/"

    # some feeds are dirty as hell and don't provide
    # a length in the enclosure tag
    DEFAULT_ENCLOSURE_LENGTH = 1000000

    def initialize
      feed_config = File.read(File.expand_path("../../../feeds.json", __FILE__))
      @feed_specification = JSON.parse(feed_config)                  
      connect_to_redis
    end

    def connect_to_redis
      if ENV["REDISCLOUD_URL"]
        uri = URI.parse(ENV["REDISCLOUD_URL"])
        @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)          
      else
        puts "... testing locally"
        @redis = Redis.new
      end
    end

    def create_feeds
      @feed_specification["composed_feeds"].each do |feed_definition|
        puts "Definition: #{feed_definition}"
        items = collect_items(feed_definition["feeds"])              
        feed = generate_feed(items.flatten, feed_definition)      
        write_feed(feed, feed_definition)        
      end      
    end

    def test_feed(feed_name)
      test_feed_definition = {}
      # look up the right definition
      @feed_specification["composed_feeds"].each do |feed_definition|
        if feed_definition["name"] == feed_name
          test_feed_definition = feed_definition
          break
        end
      end

      if !test_feed_definition.empty? 
        items = collect_items(test_feed_definition["feeds"])              
        feed = generate_feed(items.flatten, test_feed_definition)      
        puts "#{feed_name}: #{feed}"
      else
        nil
      end
    end

    def write_feed(feed, feed_definition)
      key = ["holginator:", feed_definition["name"]].join
      @redis.set(key, feed)
    end

    def generate_feed(items, feed_definition)
      feed = RSS::Maker.make("2.0") do |maker|
        make_channel(maker.channel, feed_definition)
        make_image(maker.image, feed_definition)        
        maker.items.do_sort = true        
        make_items(items, maker)
      end          
      feed
    end

    def make_items(items, maker)  
      items.each_with_index do |item, index|
        maker.items.new_item do |new_item|
          new_item.title            = item.title
          new_item.description      = item.description
          new_item.pubDate          = item.pubDate              
          new_item.link             = item.link
          new_item.enclosure.url    = item.enclosure.url            
          new_item.enclosure.type   = item.enclosure.type

          if item.enclosure.length
            new_item.enclosure.length = item.enclosure.length 
          else
            new_item.enclosure.length = DEFAULT_ENCLOSURE_LENGTH
          end
        end
      end
    end

    def make_channel(channel, feed_definition)
      channel.updated = Time.now.to_s
      channel.title = feed_definition["title"]
      channel.description = feed_definition["description"]
      channel.link = feed_link(feed_definition)
    end

    def make_image(image, feed_definition)
      image.title = feed_definition["title"]
      image.url = feed_definition["image"]
    end

    def feed_link(feed_definition)
      feed_link = [LINK_PREFIX, feed_definition["name"]].join
    end

    def collect_items(feeds)
      items = []
      feeds.each do |feed|
        puts "Downloading feed... #{feed["url"]}"
        downloaded_content = RestClient.get(feed["url"])
        # turning off validation because RSS feeds are a huge mess
        feed_content = RSS::Parser.parse(downloaded_content, false)
        filtered_items = filter_items(feed_content, feed["filter"])        
        items << filtered_items
      end
      items
    end

    def filter_items(feed_content, filter)
      return feed_content.items if filter == nil
      filtered_items = []
      filter_reg_exp = /#{filter}/      
      feed_content.items.each do |item|
        if item.title =~ filter_reg_exp || item.description =~ filter_reg_exp
          filtered_items << item
        end        
      end
      filtered_items      
    end

  end
end