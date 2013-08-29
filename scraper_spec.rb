require 'rspec'
require './scraper'

describe "Scraper" do
  describe "library_urls" do
    it "Should visit the main council library page" do
      Scraper.should_receive(:open).with("http://www.lambeth.gov.uk/Services/LeisureCulture/Libraries/LocalLibraries/")
      Scraper.library_urls
    end
  end

#   describe ".initialize" do
#     it "should assign @agent as a Nokogiri agent" do
#       scraper = Scraper.new
#       assigns(:agent).should be Nokogiri:
#     end
#   end
#
end




