require 'item'

class Items
	include Enumerable

	attr_reader :items, :data_dir, :item_types

	def initialize data_dir
		@data_dir = data_dir
		@items = get_items(data_dir)
		@item_types = ["Languages", "Tools", "Techniques", "Platforms"]
	end

	def get_items_from_string file_text, radar_date
		most_recent_header = ""

		file_text.split("\n").map { |datum| 
			most_recent_header = datum if (["Languages", "Tools", "Techniques", "Platforms"].include?(datum)) 
			most_recent_header == datum ? nil : Item.new(item_name(datum), radar_date, most_recent_header, item_number(datum))
		}.compact.reject { |item|
			item.name.nil?
		}
	end

	def get_items data_dir
		get_filenames(data_dir).map { |filename|
			[get_data_from_file(filename), date_of(filename)]
		}.map { |file_content, date|
			get_items_from_string(file_content, date)
		}.inject(:+)
	end

	def with_recs
		items.select {|item| !item.recommendation.nil? }
	end

	def date_of filename
		matcher = filename.match /(\d{4})-(\d{2})\.txt/
		Date.new(matcher[1].to_i, matcher[2].to_i, 1)
	end

	def get_filenames data_dir
		Dir.entries(data_dir).reject { |filename|
			filename.match /^\..*/
		}
	end

	def get_data_from_file filename
		all_text_in_file = ""
		File.open(data_dir + "/" + filename).each_line { |line| 
			all_text_in_file += line
		}
		all_text_in_file
	end

	def for_date(date)
		get_items(data_dir).select { |item|
			item.date == date
		}
	end

	def item_number datum
		regex = /(\d*)\..*/
		matcher = datum.match(regex)
		(matcher.nil? ? nil : (datum.match regex)[1] )
	end

	def item_name datum
		regex = /\d*\. (.*)/
		matcher = datum.match(regex)
		(matcher.nil? ? nil : (datum.match regex)[1] )
	end

	def to_s
		"I'm a list of items!"
	end

	def to_json
		items.map { |item|
			item.to_json
		}
	end

	def to_s
		"#{data_dir}: #{items}"
	end
end
