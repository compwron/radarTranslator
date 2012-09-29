require_relative "../lib/radar_dynamo"

describe RadarDynamo do

  data_dir = 'spec/radars'
  subject { RadarDynamo.new data_dir }
  radar_date = Date.new(2010,1,1)
  ruby_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
  python_item = {"Python"=>{radar_date =>{"category"=>"Languages", "number" => "2"}}}
  
  it 'gets filenames from data dir' do
    subject.get_filenames(data_dir).should include "2010-01.txt"
    subject.get_filenames(data_dir).should include "2012-03.txt"
    subject.get_filenames(data_dir).should_not include "2010-08.txt"
    subject.get_filenames(data_dir).should_not include "."
  end

  it 'gets items from all files in data dir' do
    ruby_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
    subject.get_items(data_dir).should include ruby_item
  end

  describe "#item_number" do
    it 'sees item number in item' do
      whole_file_text = "Languages\n1. Ruby"
      subject.item_number(whole_file_text).should == "1"
    end

    it 'understands multidigit items' do
      whole_file_text = "Languages\n100. Ruby"
      subject.item_number(whole_file_text).should == "100"
    end
  end

  it 'gets date from filename' do
    subject.date_of("2010-01.txt").should == radar_date
  end

  describe "#get_items_from_string" do

    it 'knows whether item is a language' do
      whole_file_text = "Languages\n1. Ruby"
      language_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
      subject.get_items_from_string(whole_file_text, radar_date).should include language_item
    end

    it 'can see two language items in a file' do
      whole_file_text = "Languages\n1. Ruby\n2. Python"
      
      
      subject.get_items_from_string(whole_file_text, radar_date).should include ruby_item
      subject.get_items_from_string(whole_file_text, radar_date).should include python_item
    end

     it 'can see a language item and a tools item' do
       whole_file_text = "Languages\n1. Ruby\n\nTools\n14. Subversion"
       languages_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
       tools_item = {"Subversion"=>{radar_date =>{"category"=>"Tools", "number" => "14"}}}
      
        subject.get_items_from_string(whole_file_text, radar_date).should include tools_item
        subject.get_items_from_string(whole_file_text, radar_date).should include languages_item
        subject.get_items_from_string(whole_file_text, radar_date).should_not include nil
     end

     it 'can compose an item with spaces in the name' do
        whole_file_text = "Tools\n10. Visualization & metrics"
        tools_item = {"Visualization & metrics"=>{radar_date =>{"category"=>"Tools", "number" => "10"}}}

        subject.get_items_from_string(whole_file_text, radar_date).should include tools_item
     end

      it "doesn't return items with nil key even when dealing with recommendation section of file" do
        whole_file_text = "Adopt 1\n\nLanguages\n1. Ruby"
        subject.get_items_from_string(whole_file_text, radar_date).first.keys.should_not include nil
    end

  end

  describe "#get_recommendations" do
    it 'can get one recommendation' do
      whole_file_text = "Adopt 1"
      recommendation_map = { "Adopt" => [["1"], radar_date] }

      subject.get_recommendations(whole_file_text, radar_date).should include recommendation_map
    end

    it 'can get a range of recommendations' do
      whole_file_text = "Adopt 1-5"
      recommendation_map = { "Adopt" => [["1", "2", "3", "4", "5"], radar_date] }

      subject.get_recommendations(whole_file_text, radar_date).should include recommendation_map
    end

    it 'can get a singleton and a range in a recommendation line' do
      whole_file_text = "Adopt 1-5, 10"
      recommendation_map = { "Adopt" => [["1", "2", "3", "4", "5", "10"], radar_date] }

      subject.get_recommendations(whole_file_text, radar_date).should include recommendation_map
    end

    it 'can get recommendations for different statuses' do
      whole_file_text = "Adopt 1-5\nHold 6-7"
      adopt_recommendations = {"Adopt"=> [["1", "2", "3", "4", "5"], radar_date]}
      hold_recommendations = {"Hold"=>[["6", "7"], radar_date]}

      subject.get_recommendations(whole_file_text, radar_date).should include adopt_recommendations
      subject.get_recommendations(whole_file_text, radar_date).should include hold_recommendations
    end

    it 'can get recommendations for different statuses for mixed range and singleton lists' do
      whole_file_text = "Adopt 1-5, 9\nHold 6-7, 10"
      adopt_recommendations = {"Adopt"=>[["1", "2", "3", "4", "5", "9"], radar_date]}
      hold_recommendations = {"Hold"=>[["6", "7", "10"], radar_date]}

      subject.get_recommendations(whole_file_text, radar_date).should include adopt_recommendations
      subject.get_recommendations(whole_file_text, radar_date).should include hold_recommendations
    end

    it 'should not make rec items with nil rec numbers' do
      whole_file_text = "Adopt 1\n\nLanguages\n1. Ruby"
      recs = subject.get_recommendations(whole_file_text, radar_date)
      recs.each {|rec|
        rec.keys.should_not include nil
        rec.keys.should_not include "1."
        rec.keys.should_not include "Languages"
      }
    end
  end

  describe "#get_items_with_recommendations" do
    it 'can combine item with recommendation' do
      whole_file_text = "Adopt 1-2\nHold 2\nLanguages\n1. Ruby\n2. Python"
      item_with_recommendation = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}

      subject.get_items_with_recommendations(whole_file_text, radar_date).should include item_with_recommendation
    end
  end

  describe "#add_recommendation_value_to_item" do
    it 'adds recommendation to item, given item and date' do
      rec_type = "Adopt"
      ruby_item_with_rec = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      subject.add_recommendation_value_to_item(ruby_item, rec_type, radar_date).should == ruby_item_with_rec
    end
  end


  it 'can combine several items with recommendation list' do 
  end

  it "should get raw data from files" do
  	subject.get_data_from_file("2010-01.txt").should == "Languages\n1. Ruby"
  end


  it 'should get items for a particular date when given a data directory with files in' do
    subject.get_items_for_date(radar_date).should include ruby_item
    subject.get_items_for_date(radar_date).should_not include python_item
  end

  it 'items without recommendations should not be returned' do
  end
end













