require 'spec_helper'

describe Runner do
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