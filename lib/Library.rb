require 'nokogiri'
require 'open-uri'
require 'pry'

class Library
  attr_reader :name, :url

  def initialize(name, url) 
    @name = name
    @url = url   
  end

  def opening_hours(day=nil)
    day = get_day_sym(day) if RELATIVE_DAY_SYMBOLS.include?(day)
    raise ArgumentError, "Expected a day symbol e.g. :monday, but recieved a #{day.class}: \"#{day}\"" unless day.nil? || DAY_SYMBOLS.include?(day)

    @library_page = Nokogiri::HTML(open(@url))
    find_opening_hours_list
    oh = build_opening_hours

    if day.nil?
      oh
    else
      oh[day]
    end
  end

  def display
    output = ""
    output << "#{@name}\n"
    output << "Opening hours:\n"
    output << "--------------"
    
    opening_hours.each_pair do |day, opening|
      output << "\n"
      output << "#{day.capitalize}:".ljust(12)
      if opening.closed? 
        output << "closed"
      else
        output<< "#{opening.opening_time} - #{opening.closing_time}"
      end
    end
    output
  end

  def display_day(day_sym)
    output = ""
    output << "#{@name}:".ljust(25)
    
    opening_day = opening_hours(day_sym)
    if opening_day.closed? 
      output << "closed"
    else
      output<< "#{opening_day.opening_time} - #{opening_day.closing_time}"
    end
  end
  
  private

  DAY_SYMBOLS = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
  RELATIVE_DAY_SYMBOLS = [:today, :tomorrow, :yesterday]

  class ParseError < StandardError  
  end  

  def find_opening_hours_list
    section_title = @library_page.at("//h2[     contains(., 'Opening hours') ]")
    section_title = @library_page.at("//h3[     contains(., 'Opening hours') ]") if section_title.nil?
    section_title = @library_page.at("//strong[ contains(., 'Opening hours') ]") if section_title.nil?
    section_title =@library_page.at( "//text()[ contains(., 'Opening hours') ]") if section_title.nil?
    section_title =@library_page.at( "//text()[ contains(., 'is open') ]") if section_title.nil?

    raise "Couldn't find the \"Opening hours\" title in the page (#{@url})" if section_title.nil?
    # section_title = @library_page.at('strong:contains("Opening hours")') if section_title.nil?
    
    # Search through the following few nodes looking for a list of opening hours: 
    node = section_title
    i = 0
    loop do
      i += 1
      node = node.next
      raise "Couldn't find the list of opening hours in the page (#{@url})" if i > 6 || node.nil?
      if (node.name == "ul" || node.name == "p") && node.child.text[0..5]=="Monday"
        @opening_hours_nodes = node.children.to_a.delete_if { |e| e.name == "br" }
        # if the list was using a p tag with br tags, we need to remove the brs
        break
      end
    end
  end

  def build_opening_hours
    @opening_hours_nodes.inject({}) do |hash, line |
      cleaned_text = line.text.gsub(194.chr("UTF-8"),'').gsub("to",'').gsub("-",' ')
      array = cleaned_text.split(/[[:space:]]+/)
      hash.update(array.first.downcase.to_sym => parse_hours(array.drop 1))
    end
  rescue ParseError => e
    raise "Couldn't parse the page content: #{e}"
  end

  def parse_hours(hours_array)
    raise ParseError, "Tried to parse a nil array of hours info" if hours_array.nil?
    raise ParseError, "Tried to parse an empty array of hours info" if hours_array.empty?
    
    # indexes in the array where we'd expect to find things:
    opening_time = 0
    closing_time = 1
    params = {}
    if hours_array[0].downcase == "closed"
      params.update( closed: true )
    
    elsif hours_array[opening_time][0] =~ /[0-9]/
      # Assume it's a time
      params.update( opening_time: hours_array[opening_time])

      if hours_array[closing_time][0] =~ /[0-9]/
        params.update( closing_time: hours_array[closing_time])
      else
        raise ParseError, "Found what looked like an opening time (\"#{hours_array[1]}\"), but the next item didn't look like a closing time (\"#{hours_array[3]}\")"
      end
    else # Assume it's a note which basically means it's closed
      params.update( closed: true )
    end

    DayOpeningHours.new(params)
  end

  class DayOpeningHours
    attr_reader :closed, :opening_time, :closing_time
    alias :closed? :closed

    def initialize(params)
      @closed = params[:closed]
      @opening_time = params[:opening_time]
      @closing_time = params[:closing_time]
    end
  end

  def get_day_sym(relative_day_sym)
    raise ArgumentError, "Expected one of #{RELATIVE_DAY_SYMBOLS.inspect}" unless RELATIVE_DAY_SYMBOLS.include? relative_day_sym
    date = Date.today if relative_day_sym == :today
    date = Date.today + 1 if relative_day_sym == :tomorrow
    date = Date.today - 1 if relative_day_sym == :yesterday
    Date::DAYNAMES[date.wday].downcase.to_sym
  end

end
