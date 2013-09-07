require 'spec_helper'

describe "Runner" do
  describe "display_day" do
    before(:each) do
      Runner.stub(:libraries).and_return({ "Narnia Library" => "url"})
    end
    it "should call display_day on a Library object" do
      Library.any_instance.should_receive(:display_day).with(:monday)
      Runner.display_day("Monday")
    end
  end
end