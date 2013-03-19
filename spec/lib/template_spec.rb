require 'spec_helper'

describe Localtumblr::Template do
  describe ".initialize" do
    it "requires a source template to be set" do
      expect { Localtumblr::Template.new }.to raise_error(ArgumentError)
    end
  end

  describe ".from_file" do
    let(:template) { Localtumblr::Template.from_file(File.join(File.dirname(__FILE__), "../support/tumblr-index.html")) }

    it "reads a file" do
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
    let(:template) { Localtumblr::Template.from_file(File.join(File.dirname(__FILE__), "../support/tumblr-index.html")) }

    it "parses the source template and returns HTML" do
      expect(template.parse).not_to be_nil
    end
  end
end