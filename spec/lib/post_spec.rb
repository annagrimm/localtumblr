require 'spec_helper'

describe Localtumblr::Post do
  describe ".from_blog" do
    let(:posts) do
      VCR.use_cassette('posts') do
        Localtumblr::Post.from_blog("bftech.tumblr.com", "5GPgmox9xWmFEyuLGwSh5xMJ0WMG7YhmtHsByRjSPnDc1prZNc")
      end
    end

    it "imports posts from a specified blog" do
      expect(posts).not_to be_nil
    end
  end
end