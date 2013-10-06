require "spec_helper"
require_relative "../lib/holginator/feed_handler"

describe Holginator::FeedHandler do
  
  let(:feed_handler) {
    Holginator::FeedHandler.new
  }

  it "reads the feed specification" do
    feed_handler.should respond_to :feed_specification
    feed_handler.feed_specification.should be_a Hash  
  end

  it "creates a feed for the give configuration" do 
    feed_handler.should respond_to :create_feed
  end

end