require 'spec_helper'
require 'nokogiri'
# require 'pry'

describe Localtumblr::Template do
  let(:tumblr_base_hostname) { "bftech.tumblr.com" }
  let(:tumblr_api_key) { "5GPgmox9xWmFEyuLGwSh5xMJ0WMG7YhmtHsByRjSPnDc1prZNc" }

  describe ".initialize" do
    it "requires a source template to be set" do
      expect { Localtumblr::Template.new }.to raise_error(ArgumentError)
    end
  end

  describe ".from_file" do
    let(:template) { Localtumblr::Template.from_file(File.join(File.dirname(__FILE__), "../support/tumblr-index.html")) }

    it "opens a file" do
      expect { template }.not_to raise_error(Errno::ENOENT)
    end

    it "reads a string from a file" do
      expect(template).not_to be_nil
    end

    it "parses a template and returns HTML" do
      new_template = template.parse
      expect(new_template).not_to be_nil
    end
  end

  describe "#parse" do
    let(:template) { Localtumblr::Template.from_file(File.join(File.dirname(__FILE__), "../support/easy-reader-2.html.tmbl")) }

    it "parses the source template and returns HTML" do
      expect(template.parse).not_to be_nil
    end

    context "in photo post" do
      let(:posts) do
        VCR.use_cassette('photo_posts') do
          # Get posts with exactly one photo.
          Localtumblr::Post.from_blog(tumblr_base_hostname, tumblr_api_key, type: 'photo').select { |x| x.photos.count == 1 }
        end
      end

      let(:template_with_photo_posts) do
        template.posts = posts
        template
      end

      it "expands the contents of a photo tag once for each photo post in the page" do
        html_doc = Nokogiri::HTML(template_with_photo_posts.parse.to_s)
        html_doc_photos = html_doc.css("#posts > .post > .photo")
        expect(html_doc_photos).to have(posts.count).photo_posts
      end
    end

    context "in photoset post" do
      let(:posts) do
        VCR.use_cassette('photo_posts') do
          # Get posts with more than one photo.
          Localtumblr::Post.from_blog(tumblr_base_hostname, tumblr_api_key, type: 'photo').select { |x| x.photos.count > 1 }
        end
      end

      let(:template_with_photoset_posts) do
        template.posts = posts
        template
      end

      it "expands the contents of a photoset tag if the post has more than one photo" do
        html_doc = Nokogiri::HTML(template_with_photoset_posts.parse.to_s)
        photosets = html_doc.css("#posts > .post > .photoset-photos")
        photosets.each do |photoset|
          photos_in_photoset = photoset.css(".photo")
          expect(photos_in_photoset).to have_at_least(2).photos
        end
      end

      it "expands the contents of a photo tag once for each photo in a photoset post" do
        html_doc = Nokogiri::HTML(template_with_photoset_posts.parse.to_s)
        html_doc_photosets_with_photos = html_doc.css("#posts > .post > .photoset-photos > .photo")
        photo_count = 0
        posts.each do |post|
          photo_count += post.photos.count
        end
        expect(html_doc_photosets_with_photos).to have(photo_count).photos
      end
    end
  end
end