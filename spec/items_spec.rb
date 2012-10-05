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

  it 'sees all items with recs in a data dir (more than 1 file)' do
    subject.with_recs.should include Item.new("Ruby", radar_date, "Languages", "1", "Adopt")
    subject.with_recs.should include Item.new("Python", radar_date, "Languages", "2", "Adopt")
  end

  it 'sees json of all items with recs in a data dir (more than 1 file)' do
    json_ruby_adopt = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
    subject.with_recs_json.should include json_ruby_adopt
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

  describe "#get_recommendations_from_string" do
    rec_string = "Adopt 1"
    two_rec_string = "Adopt 1\nHold 2"
    item_string = "Tools\n10. Visualization & metrics"

    it "sees recommendation in string" do
      subject.get_recommendations_from_string(rec_string, radar_date).should include adopt_1
    end

    it "sees several recommendations in string" do
      subject.get_recommendations_from_string(two_rec_string, radar_date).should include adopt_1
      subject.get_recommendations_from_string(two_rec_string, radar_date).should include hold_2
      subject.get_recommendations_from_string(two_rec_string, radar_date).size.should == 2
    end

    it "sees no recommendation in item string" do
      subject.get_recommendations_from_string(item_string, radar_date).size.should == 0
    end
  end

  describe "#get_recommendations" do
    one_rec = "Adopt 1"
    rec_range = "Adopt 1-3"
    rec_range_and_single = "Adopt 1-3, 4"
    two_rec_types = "Adopt 1-5\nHold 6-7"
    two_rec_types_with_range_and_singleton ="Adopt 1-5, 9\nHold 6-7, 10"
    rec_and_item = "Adopt 1\n\nLanguages\n1. Ruby"

    it 'can get one recommendation' do
      recommendation_map = { "Adopt" => [["1"], radar_date] }
      subject.get_recommendations(one_rec, radar_date).should include recommendation_map
    end

    it 'can get a range of recommendations' do
      recommendation_map = { "Adopt" => [["1", "2", "3"], radar_date] }
      subject.get_recommendations(rec_range, radar_date).should include recommendation_map
    end

    it 'can get a singleton and a range in a recommendation line' do
      recommendation_map = { "Adopt" => [["1", "2", "3", "4"], radar_date] }
      subject.get_recommendations(rec_range_and_single, radar_date).should include recommendation_map
    end

    it 'can get recommendations for different statuses' do
      adopt_recommendations = {"Adopt"=> [["1", "2", "3", "4", "5"], radar_date]}
      hold_recommendations = {"Hold"=>[["6", "7"], radar_date]}

      subject.get_recommendations(two_rec_types, radar_date).should include adopt_recommendations
      subject.get_recommendations(two_rec_types, radar_date).should include hold_recommendations
    end

    it 'can get recommendations for different statuses for mixed range and singleton lists' do
      adopt_recommendations = {"Adopt"=>[["1", "2", "3", "4", "5", "9"], radar_date]}
      hold_recommendations = {"Hold"=>[["6", "7", "10"], radar_date]}

      recs = subject.get_recommendations(two_rec_types_with_range_and_singleton, radar_date)
      recs.should include adopt_recommendations
      recs.should include hold_recommendations
    end

    it 'should not make rec items with nil or invalid rec numbers' do
      recs = subject.get_recommendations(rec_and_item, radar_date)
      recs.each {|rec|
        rec.keys.should_not include nil
        rec.keys.should_not include "1."
        rec.keys.should_not include "Languages"
      }
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
end
