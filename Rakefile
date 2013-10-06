require_relative "./lib/holginator/feed_handler"
require "dotenv"

namespace :holginator do

  desc "Creates feeds from the given config"
  task :create_feeds do
    feed_handler = Holginator::FeedHandler.new
    feed_handler.create_feeds
  end

  desc "Tests the composition and filtering for a given feed"
  task :test_feed, :feed_name do |task, args|
    puts "Feedname is: #{args[:feed_name]}"
    Dotenv.load
    feed_handler = Holginator::FeedHandler.new
    feed_handler.test_feed(args[:feed_name])
  end
  
end