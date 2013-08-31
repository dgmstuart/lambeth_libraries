require 'spec_helper'

describe "Library" do
  # a list of possible strings:
  NBSP = "\u00a0"         # non-breaking space character (160)
  BOX = 194.chr("UTF-8")  # 'box' character (194)
  LINE_END = "\n\r"
  CLOSED = "closed"
  TIMES = "10am to 6pm"
  NOT_OPEN_NORMALLY = "Open for activities - see above"
  RAW_INPUT = %{<h3>Opening hours</h3>
<p>Narnia Library is open: </p>
<ul>
<li>Monday - #{CLOSED} #{LINE_END} 
</li><li>Tuesday -#{NBSP}#{CLOSED} #{LINE_END}
</li><li>Wednesday - #{TIMES} #{LINE_END}
</li><li>Thursday -#{NBSP}#{TIMES} #{LINE_END}
</li><li>Friday - #{NOT_OPEN_NORMALLY} #{LINE_END}
</li><li>Saturday -#{BOX} #{TIMES} #{LINE_END}
</li><li>Sunday - 12noon-5pm</li></ul>}
  
  RAW_INPUT_BR = %{<h3>Opening hours <br /></h3>
<p>Monday - 1pm to 6pm <br />Tuesday – open for activities – see above <br />Wednesday - 10am to 6pm <br />Thursday - 10am to 8pm <br />Friday - 10am to 6pm <br />Saturday - 9am to 5pm <br />Sunday - closed </p>}

  PRINTED_OUTPUT = %{Narnia Library
Opening hours:
--------------
Monday:     closed
Tuesday:    closed
Wednesday:  10am - 6pm
Thursday:   10am - 6pm
Friday:     closed
Saturday:   10am - 6pm
Sunday:     12noon - 5pm}

  before(:each) do
    @library = Library.new "Narnia Library", "http://url"
    Library.any_instance.stub(:open).and_return(RAW_INPUT)
  end
  describe "#new" do
    it "should take a name and url and return a Library object" do
      @library.should be_an_instance_of Library
    end
  end
  describe "#name" do
    it "should return the correct name" do
      @library.name.should == "Narnia Library"
    end
  end
  describe "#url" do
    it "should return the correct url" do
      @library.url.should == "http://url"
    end
  end

  describe "opening_hours" do
    it "should fetch the page content" do
      @library.should_receive(:open).with("http://url").and_return(RAW_INPUT)
      @library.opening_hours
    end
    it "should return a hash of days" do
      @library.opening_hours.keys.should == [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    end
    context "when the library is closed" do
       it "should create an object with a 'closed' set to true" do
        @library.opening_hours[:monday].closed?.should be_true
      end
      it "should handle non-breaking spaces" do
        @library.opening_hours[:tuesday].closed?.should be_true
      end
    end
    context "when the library isn't open as normal" do
      it "should treat it as though it were closed" do
        @library.opening_hours[:friday].closed?.should be_true
      end
    end
    context "when the library is not closed" do  
      it "should create an object with closed set to false" do
        @library.opening_hours[:wednesday].closed.should be_false
      end
      it "should set the opening time" do
        @library.opening_hours[:wednesday].opening_time.should == "10am"
      end
      it "should set the closing time" do
        @library.opening_hours[:wednesday].closing_time.should == "6pm"
      end
      it "should handle non-breaking spaces" do
        @library.opening_hours[:thursday].opening_time.should == "10am"
      end
      it "should handle the unicode box character (194)" do
        @library.opening_hours[:saturday].opening_time.should == "10am"
      end
      context "and when the input uses '-' instead of 'to'" do
        it "should set the opening time" do
          @library.opening_hours[:sunday].opening_time.should == "12noon"
        end
        it "should set the closing time" do
          @library.opening_hours[:sunday].closing_time.should == "5pm"
        end
      end
    end
    context "when the list uses br instead of li" do
      before(:each) do
        @library.stub(:open).with("http://url").and_return(RAW_INPUT_BR)
      end
      it "should return a hash of days" do
        @library.opening_hours.keys.should == [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
      end
      context "when the library is closed" do
         it "should create an object with a 'closed' set to true" do
          @library.opening_hours[:sunday].closed?.should be_true
        end
      end
      context "when the library isn't open as normal" do
        it "should treat it as though it were closed" do
          @library.opening_hours[:tuesday].closed?.should be_true
        end
      end
      context "when the library is not closed" do  
        it "should create an object with closed set to false" do
          @library.opening_hours[:wednesday].closed.should be_false
        end
        it "should set the opening time" do
          @library.opening_hours[:wednesday].opening_time.should == "10am"
        end
        it "should set the closing time" do
          @library.opening_hours[:wednesday].closing_time.should == "6pm"
        end
      end
    end
  end

  describe "display" do
    # N.B. the purist approach would be to stub out opening_hours, but that would 
    # involve creating yet another big ugly data structure for testing.
    it "should produce nicely formatted output for the command line" do
      @library.display.should == PRINTED_OUTPUT
    end
  end
end