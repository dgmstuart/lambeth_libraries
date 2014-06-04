require 'spec_helper'

describe Runner do

  describe "#display_all" do
    before(:each) do
      Runner.stub(:libraries).and_return({ "Narnia Library" => "url"})
    end
    it "should call display on a Library" do
      Library.any_instance.should_receive(:display)
      Runner.display_all
    end
  end
  describe "#display_day" do
    before(:each) do
      Runner.stub(:libraries).and_return({ "Narnia Library" => "url"})
    end
    it "should call display_day on a Library object" do
      Library.any_instance.should_receive(:display_day).with(:monday)
      Runner.display_day("Monday")
    end
  end
  describe "#display" do
    it "should call display on a Library" do
      Library.any_instance.should_receive(:display)
      Runner.display("Foo")
    end
  end
  describe "#list" do
    it "should get the list of libraries" do
      Runner.should_receive(:libraries).and_return({})
      Runner.list
    end
  end
  context "when there are no libraries" do
    before { Nokogiri::HTML::Document.any_instance.stub(:css).and_return([]) }
    describe "display_all" do
      it "raises an error" do
        expect{Runner.display_all}.to raise_error("No Libraries found")
      end
    end
    describe "list" do
      it "raises an error" do
        expect{Runner.list}.to raise_error("No Libraries found")
      end
    end
  end
end