require 'spec_helper'


describe ApplicationHelper do
  describe 'full_title' do
    it "include the page title" do
      expect( full_title("foo") ).to match(/foo/)
    end

    it "include the base title" do
      expect( full_title("foo") ).to match(/^Ruby on Rails Tutorial Sample App/)
    end

    it "not include a bar for the home page" do
      expect( full_title("") ).not_to match(/\|/)
    end
  end
end

