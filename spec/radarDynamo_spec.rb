require_relative "../lib/radar_dynamo"

describe RadarDynamo do

  data_dir = 'spec/radars'
  subject { RadarDynamo.new data_dir }
  radar_date = Date.new(2010,1,1)
  ruby_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
  python_item = {"Python"=>{radar_date =>{"category"=>"Languages", "number" => "2"}}}
  
  describe "uses data_dir" do
    it 'gets filenames from data dir' do
      subject.get_filenames(data_dir).should include "2010-01.txt"
      subject.get_filenames(data_dir).should include "2012-03.txt"
      subject.get_filenames(data_dir).should_not include "2010-08.txt"
      subject.get_filenames(data_dir).should_not include "."
    end

    it "should get raw data from files" do
      subject.get_data_from_file("2010-01.txt").should == "Languages\n1. Ruby"
    end

    it 'gets items from all files in data dir' do
      ruby_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
      subject.get_items(data_dir).should include ruby_item
      subject.get_items(data_dir).size.should == 2
    end

    it 'should get items for a particular date when given a data directory with files in' do
      subject.get_items_for_date(radar_date).should include ruby_item
      subject.get_items_for_date(radar_date).should_not include python_item
    end
  end

  describe "#item_number" do
    it 'sees item number in item' do
      whole_file_text = "Languages\n1. Ruby"
      subject.item_number(whole_file_text).should == "1"
    end

    it 'understands multidigit items' do
      subject.item_number("Languages\n100. Ruby").should == "100"
    end
  end

  it 'gets date from filename' do
    subject.date_of("2010-01.txt").should == radar_date
  end

  describe "#get_items_from_string" do
    one_language = "Languages\n1. Ruby"
    two_languages = "Languages\n1. Ruby\n2. Python"
    two_item_types = "Languages\n1. Ruby\n\nTools\n14. Subversion"
    two_item_types_one_rec = "Adopt 1\n\nLanguages\n1. Ruby\n\nTools\n2. Puppet"

    it 'knows whether item is a language' do
      language_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
      subject.get_items_from_string(one_language, radar_date).should include language_item
    end

    it 'can see two items of the same type in a file' do
      items = subject.get_items_from_string(two_languages, radar_date)
      items.should include ruby_item
      items.should include python_item
    end

    it 'can see two kinds of item' do
      languages_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
      tools_item = {"Subversion"=>{radar_date =>{"category"=>"Tools", "number" => "14"}}}

      items = subject.get_items_from_string(two_item_types, radar_date)
      items.should include tools_item
      items.should include languages_item
    end

    it 'can compose an item with spaces in the name' do
      tools_item = {"Visualization & metrics"=>{radar_date =>{"category"=>"Tools", "number" => "10"}}}
      subject.get_items_from_string("Tools\n10. Visualization & metrics", radar_date).should include tools_item
    end

    it "doesn't return items with nil key even when dealing with multiple file sections" do
      subject.get_items_from_string(two_item_types_one_rec, radar_date).first.keys.should_not include nil
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

  describe "#get_items_with_recommendations" do
    rec_and_item = "Adopt 1\n\nLanguages\n1. Ruby"
    recs_and_items = "Adopt 1-2\nHold 3\n\nLanguages\n1. Ruby\n2. Python\n\nTools\n3. Subversion"
    item_without_rec = "Languages\n1. Ruby"
    rec_without_item = "Adopt 1"

    it 'can combine item with recommendation' do
      item_with_recommendation = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      subject.get_items_with_recommendations(rec_and_item, radar_date).should include item_with_recommendation
    end

    it 'can combine several items with recommendation list' do 
      adopt_ruby = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      adopt_python = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      hold_subversion = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      
      rec_items = subject.get_items_with_recommendations(recs_and_items, radar_date)
      
      rec_items.should include adopt_ruby
      rec_items.should include adopt_python
      rec_items.should include hold_subversion
    end

    it 'items without recommendations should not be returned' do
      subject.get_items_with_recommendations(item_without_rec, radar_date).size.should == 0
    end
  end

  describe "#add_recommendation_value_to_item" do
    it 'adds recommendation to item, given item and date' do
      rec_type = "Adopt"
      ruby_item_with_rec = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      subject.add_recommendation_value_to_item(ruby_item, rec_type, radar_date).should == ruby_item_with_rec
    end
  end
end













