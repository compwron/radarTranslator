require_relative "../lib/items"
require 'date'

describe Items do

  data_dir = 'spec/radars'
  subject { Items.new data_dir }
  radar_date = Date.new(2010, 01, 01)
  
  it 'gets filenames from data dir' do
    subject.get_filenames.should include "2010-01.txt"
    subject.get_filenames.should include "2012-03.txt"
    subject.get_filenames.should_not include "2010-08.txt"
    subject.get_filenames.should_not include "."
  end


  it 'gets items from all files in data dir' do
    subject.items.first.name.should include "Ruby"
    subject.items.size.should == 2
  end

  # it 'sees all items with recs in a data dir (more than 1 file)' do
  #   subject.with_recs.should include Item.new("Ruby", radar_date, "Languages", "1", "Adopt")
  #   subject.with_recs.should include Item.new("Python", radar_date, "Languages", "2", "Adopt")
  # end

  it 'sees json of all items with recs in a data dir (more than 1 file)' do
    json_ruby_adopt = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
    subject.to_json.should include json_ruby_adopt
  end

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

  adopt_1 = Recommendation.new("1", "Adopt", radar_date)
  hold_2 = Recommendation.new("2", "Hold", radar_date)
  
  describe "#get_recommendations_in_dir" do
    adopt_1_2012_03 = Recommendation.new("1", "Adopt", Date.new(2012, 3, 1))

    it "should see recs in directory" do
      subject.get_recommendations_in_dir.should include adopt_1
      subject.get_recommendations_in_dir.should include adopt_1_2012_03
    end
  end

  describe "#add_recs_to_items" do
    item_with_adopt_1 = Item.new("Ruby", radar_date, "Languages", "1", "Adopt")

    it 'can add a rec to the items list (from data_dir)' do
      subject.add_recs_to_items(adopt_1)
      subject.items.should include item_with_adopt_1
    end

    it 'can add several recs to the items list (from data_dir)' do 
    end
  end

  describe "test larger data sets" do
    items_in_big_radar = 104
    big_radar_data_dir = 'spec/big_radar'
    big_items = Items.new(big_radar_data_dir)

    it "should get correct number of recs in data file" do
      big_items.get_filenames.size.should == 1

      big_items.get_recommendations_in_dir.size.should == items_in_big_radar
      big_items.items.size.should == items_in_big_radar
      big_items.with_recs.size.should == items_in_big_radar
    end
  end

  describe "#with_recs_csv" do
    it "should see data as csv" do
      ruby_adopt_csv = "Ruby,2010-01-01,Languages,1,"
      subject.to_csv.should include ruby_adopt_csv
    end
  end
end
