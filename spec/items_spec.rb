require_relative "../lib/items"
require_relative "../lib/recommendation"

require 'date'

describe Items do

  data_dir = 'spec/radars'
  subject { Items.new data_dir }
  radar_date = Date.new(2010, 01, 01)
  
  it 'gets items from all files in data dir' do
    subject.items.first.name.should include "Ruby"
    subject.items.size.should == 2
  end

  it 'sees json of all items with recs in a data dir (more than 1 file)' do
    json_ruby_adopt = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation" => "Adopt"}}}
    subject.to_json.should include json_ruby_adopt
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
      big_items.get_recommendations_in_dir.size.should == items_in_big_radar
      big_items.items.size.should == items_in_big_radar
      big_items.with_recs.size.should == items_in_big_radar
    end
  end

  describe "#with_recs_csv" do
    it "should see data as csv" do
      ruby_adopt_csv = "Ruby,2010-01-01,Languages,1,Adopt"
      subject.to_csv.should include ruby_adopt_csv
    end
  end

  describe "debugging full load using query: bin/radar_translator | grep -i ',.*,.*,.*,$'" do
    it "should pick up all recommednations in file" do
      end_to_end_debugging = "spec/end_to_end"
      Items.new(end_to_end_debugging).to_csv.should_not include "Android,2010-01-01,Platforms,25,"
      Items.new(end_to_end_debugging).to_csv.should include "Android,2010-01-01,Platforms,25,Trial"
    end

    it "should pick up stray rec" do
          #        bin/radar_translator | grep -i ',.*,.*,.*,$' # this should return 0 results - this is either bad code or invalid data
          # Build pipelines,2010-01-01,Techniques,8,
          # User centered design,2010-01-01,Techniques,9,
          # NoSQL,2010-04-01,Tools,22,
          # Intentional,2010-08-01,Tools,19,
          # iPad,2010-08-01,Platforms,61,
          # Ruby,2010-08-01,Languages,46,
    end
  end
end
