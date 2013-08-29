require 'nokogiri'
require 'open-uri'

class Scraper
  def self.library_urls
    open("http://www.lambeth.gov.uk/Services/LeisureCulture/Libraries/LocalLibraries/")
  end
end
