require_relative "../lib/parser"

describe Parser do

  subject { Parser.new }
  radar_date = Date.new(2010, 01, 01)
  
  it 'gets date from filename' do
    subject.date_of("2010-01.txt").should == radar_date
  end

  it 'gets item name from datum' do
    subject.item_name("1. Ruby")
  end

  describe "#item_number" do
    it 'gets item number from datum' do
      subject.item_number("1. Ruby")
    end

    it 'sees item number from datum' do
      whole_file_text = "Languages\n1. Ruby"
      subject.item_number(whole_file_text).should == "1"
    end

    it 'understands multidigit items' do
      subject.item_number("Languages\n100. Ruby").should == "100"
    end
  end
end