require_relative "../lib/radar_dynamo"

describe RadarDynamo do

  data_dir = 'spec/radars'
  subject { RadarDynamo.new data_dir }
  radar_date = Date.new(2010,1,1)
  ruby_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
  python_item = {"Python"=>{radar_date =>{"category"=>"Languages", "number" => "2"}}}
  
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
    rec_and_item = "Adopt 1\n\nLanguages\n1. Ruby"
    recs_and_items = "Adopt 1-2\nHold 3\n\nLanguages\n1. Ruby\n2. Python\n\nTools\n3. Subversion"
    item_without_rec = "Languages\n1. Ruby"
    rec_without_item = "Adopt 1"

    it 'can combine item with recommendation' do
      item_with_recommendation = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      subject.add_recs_to_items(rec_and_item, radar_date).should include item_with_recommendation
    end

    it 'can combine several items with recommendation list' do 
      adopt_ruby = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      adopt_python = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      hold_subversion = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
      
      rec_items = subject.add_recs_to_items(recs_and_items, radar_date)
      
      rec_items.should include adopt_ruby
      rec_items.should include adopt_python
      rec_items.should include hold_subversion
    end

    it 'items without recommendations should not be returned' do
      subject.add_recs_to_items(item_without_rec, radar_date).size.should == 0
    end
  end
end
