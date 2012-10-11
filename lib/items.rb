require_relative 'item'
require_relative 'recommendation'
require_relative 'parser'

class Items
  include Enumerable

  attr_reader :items, :file_contents

  @@parser = Parser.new

  def initialize data_dir
    @data_dir = data_dir
    @items = get_items
    @file_contents = get_file_contents_and_date
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

  def get_file_contents_and_date
    @@parser.get_filenames(@data_dir).map { |filename|
      [@@parser.get_data_from_file(@data_dir, filename), @@parser.date_of(filename)]
    }
  end

  def get_recommendations_in_dir
    file_contents.map { |file_content, date|
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
    @@parser.get_filenames(@data_dir).map { |filename|
      date = @@parser.date_of(filename)
      category = nil
      @@parser.get_data_from_file(@data_dir, filename).split("\n").map { |datum| 
        category = (["Languages", "Tools", "Techniques", "Platforms"].include?(datum)) ? datum : category
        make_valid_item(@@parser.item_name(datum), date, category, @@parser.item_number(datum))
      }.compact 
    }.inject(:+)
  end
end
