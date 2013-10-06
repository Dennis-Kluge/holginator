require "rss"
require "json"
require "rest_client"

module Holginator
  class FeedHandler

    LINK_PREFIX = "http://holginator.poddata.net/"

    def initialize
      feed_config = File.read(File.expand_path("../../../feeds.json", __FILE__))
      @feed_specification = JSON.parse(feed_config)            
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
        items = collect_items(feed_definition["feeds"])              
        feed = generate_feed(items.flatten, feed_definition)      
        puts "#{feed_name}: #{feed}"
      else
        nil
      end
    end

    def write_feed(feed, feed_definition)
      destination_path = File.expand_path("../../../public/#{feed_definition["name"]}.xml", __FILE__)
      File.write(destination_path, feed)
    end

    def generate_feed(items, feed_definition)
      feed = RSS::Maker.make("2.0") do |maker|
        # TODO add iTunes description
        maker.channel.updated = Time.now.to_s
        maker.channel.title = feed_definition["title"]
        maker.channel.description = feed_definition["description"]
        maker.channel.link = [LINK_PREFIX, feed_definition["name"]].join
        
        maker.image.url = feed_definition["image"]
        
        maker.items.do_sort = true
        items.each_with_index do |item, index|
          maker.items.new_item do |new_item|
            new_item.title            = item.title
            new_item.description      = item.description
            new_item.pubDate          = item.pubDate              
            new_item.link             = item.link
            new_item.enclosure.url    = item.enclosure.url
            new_item.enclosure.length = item.enclosure.length
            new_item.enclosure.type   = item.enclosure.type
          end

        end
      end          
      feed
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