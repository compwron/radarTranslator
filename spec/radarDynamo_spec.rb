require_relative "../lib/radar_dynamo"

describe RadarDynamo do

  data_dir = 'spec/radars'
  subject { RadarDynamo.new data_dir }
  radar_date = Date.new(2010,1,1)
  ruby_item = {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1"}}}
  python_item = {"Python"=>{radar_date =>{"category"=>"Languages", "number" => "2"}}}
end
