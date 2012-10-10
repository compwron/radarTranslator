require_relative 'item'
require_relative 'recommendation'
require_relative 'parser'

class Items
  include Enumerable

  attr_reader :items

  @@parser = Parser.new

  def initialize data_dir
    @data_dir = data_dir
    @items = get_items
    
  end

  def to_json
    with_recs.map {|item| item.to_json}
  end

  def to_csv
    with_recs.map {|item| item.to_csv}
  end

  def with_recs
    add_recs_to_items(get_recommendations_in_dir)
  end

  def get_recommendations_in_dir
    get_filenames.map { |filename|
      [@@parser.get_data_from_file(@data_dir, filename), @@parser.date_of(filename)]
    }.map { |file_content, date| 
      @@parser.get_recommendations_from_string(file_content, date)
    }.flatten
  end

  def add_recs_to_items *recommendations
    recommendations.flatten.map { |rec| 
      items.map {|item|
        if item.matches(rec) then
          item.add_rec(rec.name)
        end
      }
    }
    items
  end

  def make_valid_item name, date, category, number
    if !(name.nil? || date.nil? || category.nil? || number.nil?) then
      Item.new(name, date, category, number)
    end
  end

  def get_items
    get_filenames.map { |filename|
      date = @@parser.date_of(filename)
      category = nil
      @@parser.get_data_from_file(@data_dir, filename).split("\n").map { |datum| 
        category = (["Languages", "Tools", "Techniques", "Platforms"].include?(datum)) ? datum : category
        make_valid_item(@@parser.item_name(datum), date, category, @@parser.item_number(datum))
      }.compact 
    }.inject(:+)
  end

  def get_filenames
    Dir.entries(@data_dir).reject { |filename|
      filename.match /^\..*/
    }
  end
end
