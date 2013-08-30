require 'nokogiri'
require 'open-uri'
require 'pry'

class Library
  attr_reader :name, :url

  def initialize(name, url) 
    @name = name
    @url = url   
  end

  def opening_hours
    @library_page = Nokogiri::HTML(open(@url))
    build_opening_hours
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
  
  private

  class ParseError < StandardError  
  end  

  def build_opening_hours
    section_title = @library_page.at('h3:contains("Opening hours")')
    opening_hours_nodes = section_title.next.next.next.next.children
    opening_hours_parts = opening_hours_nodes.map { |li| li.text.gsub(194.chr("UTF-8"),'').split(/[[:space:]]/) }
    opening_hours_parts.inject({}) do |hash, array|
      hash.update(array.first.downcase.to_sym => parse_hours(array.drop 1))
    end
    # opening_hours_text = opening_hours_nodes.map { |li| li.text.gsub(/[[:space:]]/,' ').split(" -") }
    # opening_hours_text.inject({}) do |hash, (day, hours)|
    #   hash.update(day.downcase.to_sym => parse_hours_string(hours))
    # end
  rescue ParseError => e
    raise "Couldn't parse the page content: #{e}"
  end

  def parse_hours(hours_array)
    raise ParseError, "Tried to parse a nil array of hours info" if hours_array.nil?
    raise ParseError, "Tried to parse an empty array of hours info" if hours_array.empty?
    params = {}
    if hours_array[0] == "-"
      if hours_array[1].downcase == "closed"
        params.update( closed: true )
      
      elsif hours_array[1][0] =~ /[0-9]/
        # Assume it's a time
        params.update( opening_time: hours_array[1])
        if hours_array[2] == "to"
          if hours_array[3].nil?
binding.pry
           raise ParseError, "Input ended after a 'to'" 
          end
          if hours_array[3][0] =~ /[0-9]/
            params.update( closing_time: hours_array[3])
          else
            raise ParseError, "Found what looked like an opening time (\"#{hours_array[1]}\"), but the next item didn't look like a closing time (\"#{hours_array[3]}\")"
          end
        else
          raise ParseError, "Found what looked like an opening time (\"#{hours_array[1]}\"), but this wasn't followed by \"to\""
        end
      
      else # Assume it's a note which basically means it's closed
        #binding.pry
        params.update( closed: true )
      end
    else
      #binding.pry
    end

    DayOpeningHours.new(params)
    # parts = hours_string.delete("Â").strip.split(" ")
    # parts.delete_at(1) if parts.length == 3 && parts[1] == "to"
    # parts
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
end
