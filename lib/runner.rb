require './library'
require 'pp'

BASE_URL = "http://www.lambeth.gov.uk"
LIBRARY_PAGE_URL = "#{BASE_URL}/Services/LeisureCulture/Libraries/LocalLibraries/"

def libraries
  page = Nokogiri::HTML(open(LIBRARY_PAGE_URL))
  names_and_urls = page.css("h2 a").map { |a| [a.text, a['href']] }
  Hash[names_and_urls]
end

libraries.each_pair do | name, url |
  puts Library.new(name, "#{BASE_URL}#{url}").display
  puts 
end

# BRIXTON = Library.new("Brixton Library", "#{BASE_URL}/Services/LeisureCulture/Libraries/LocalLibraries/BrixtonLibrary.htm")
# puts BRIXTON.display
# pp BRIXTON.opening_hours
