require_relative "../lib/items"
require 'date'

describe Items do

  data_dir = 'spec/radars'
  subject { Items.new data_dir }
  radar_date = Date.new(2010, 01, 01)
  

  it 'gets item name from datum' do
    subject.item_name("1. Ruby")
  end

  it 'gets date from filename' do
    subject.date_of("2010-01.txt").should == radar_date
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

  it 'should get items for a particular date when given a data directory with files in' do
    subject.for_date(radar_date).first.name.should == "Ruby"
    subject.for_date(radar_date).first.date.should == radar_date
    subject.for_date(radar_date).size.should == 1
  end

  it 'gets filenames from data dir' do
    subject.get_filenames(data_dir).should include "2010-01.txt"
    subject.get_filenames(data_dir).should include "2012-03.txt"
    subject.get_filenames(data_dir).should_not include "2010-08.txt"
    subject.get_filenames(data_dir).should_not include "."
  end

  it "should get raw data from files" do
    subject.get_data_from_file("2010-01.txt").should == "Adopt 1\n\nLanguages\n1. Ruby"
  end

  it 'gets items from all files in data dir' do
    subject.get_items(data_dir).first.name.should include "Ruby"
    subject.get_items(data_dir).size.should == 2
  end

  # broken: get Items.new to bring in recs also?
  # it 'sees all items with recs in a data dir (more than 1 file)' do
  #   adopt_ruby = Item.new("Ruby", radar_date, "Languages", "1", "Adopt")
  #   adopt_python = Item.new("Python", radar_date, "Languages", "2", "Adopt")

  #   subject.with_recs.should include adopt_ruby
  #   subject.with_recs.should include adopt_python
  # end

  describe "#get_items_from_string" do
    one_language = "Languages\n1. Ruby"
    two_languages = "Languages\n1. Ruby\n2. Python"
    two_item_types = "Languages\n1. Ruby\n\nTools\n14. Subversion"
    two_item_types_one_rec = "Adopt 1\n\nLanguages\n1. Ruby\n\nTools\n2. Puppet"
    ruby_item = Item.new("Ruby", radar_date, "Languages", "1")
    python_item = Item.new("Python", radar_date, "Languages", "2") 
    tools_item = Item.new("Subversion", radar_date, "Tools", "14")

    it 'knows whether item is a language' do
      subject.get_items_from_string(one_language, radar_date).should include ruby_item
    end

    it 'can see two items of the same type in a file' do
      items = subject.get_items_from_string(two_languages, radar_date)
      items.should include ruby_item
      items.should include python_item
    end

    it 'can see two kinds of item' do
      items = subject.get_items_from_string(two_item_types, radar_date)
      items.should include tools_item
      items.should include ruby_item
    end

    it 'can compose an item with spaces in the name' do
      subject.get_items_from_string("Tools\n10. Visualization & metrics", radar_date).should include tools_item
    end

    it "doesn't return items with nil key even when dealing with multiple file sections" do
      subject.get_items_from_string(two_item_types_one_rec, radar_date).first.name.should_not == nil
    end
  end

  describe "#get_recommendations" do
    adopt_1 = Recommendation.new("1", "Adopt", radar_date)
    adopt_1_2012_03 = Recommendation.new("1", "Adopt", Date.new(2012, 3, 1))
    subject.get_recommendations.should include adopt_1
    subject.get_recommendations.should include adopt_1_2012_03
  end
end
