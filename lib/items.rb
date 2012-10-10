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

  def get_items
    get_filenames.map { |filename|
      file_content = @@parser.get_data_from_file(@data_dir, filename)
      date = @@parser.date_of(filename)
        most_recent_header = ""
        file_content.split("\n").map { |datum| 
        most_recent_header = datum if (["Languages", "Tools", "Techniques", "Platforms"].include?(datum)) 
        most_recent_header == datum ? nil : Item.new(@@parser.item_name(datum), date, most_recent_header, @@parser.item_number(datum))
      }.compact.reject { |item|
        item.name.nil?
      } 
    }.inject(:+)
  end

  def get_filenames
    Dir.entries(@data_dir).reject { |filename|
      filename.match /^\..*/
    }
  end
end
