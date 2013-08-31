require './library'

BASE_URL = "http://www.lambeth.gov.uk"
LIBRARY_PAGE_URL = "#{BASE_URL}/Services/LeisureCulture/Libraries/LocalLibraries/"

def libraries
  page = Nokogiri::HTML(open(LIBRARY_PAGE_URL))
  names_and_urls = page.css("h2 a").map { |a| [a.text, a['href']] }
  Hash[names_and_urls]
end

def display_all
  libraries.each_pair do | name, url |
    puts Library.new(name, "#{BASE_URL}#{url}").display
    puts 
  end
end

def display(library_name)
  library = Library.new library_name, "#{BASE_URL}/Services/LeisureCulture/Libraries/LocalLibraries/#{library_name.delete(" ")}.htm"
  puts library.display
end

display_all

# display("Brixton Library")
