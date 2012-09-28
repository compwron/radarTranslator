# assume that vanishing means staying still (i.e. if in trial and then hold, assume stays in hold)
# desired output: all data in json format. and/or report of everything that has stayed still in adopt (or x section) for x years?
require 'date'

class RadarDynamo
	attr_accessor :data_dir, :types

	def initialize data_dir
		@data_dir = data_dir
		# filenames = []
		# Dir.foreach(data_dir) { |f| filenames += [f] }
		# filenames -= [".", ".."]
		@types = ["Languages", "Tools", "Techniques", "Platforms"]
		# @all_data_from_files = get_data_from_files
	end

	def get_filenames data_dir
		files = Dir.entries(data_dir)
		files.reject { |filename|
			filename == "." || filename == ".."
		}
	end

	def get_items data_dir
		get_items_from_file(get_data_from_files(get_filenames(data_dir)))
	end

	def get_data_from_files filenames
		filenames.map { |filename|
			all_text_in_file = ""
			File.open(data_dir + "/" + filename).each_line { |line| 
				all_text_in_file += line
			}
			all_text_in_file
		}
	end

	def get_items_from_file file_text, radar_date
		recommendation = "not set yet"

		most_recent_header = ""
		file_text.split("\n").select { |item| 
			!item.nil? 
		}.map { |item| 
			most_recent_header = item if (types.include?(item)) 
			most_recent_header == item ? nil : tech_object(item_name(item), radar_date, most_recent_header, recommendation, item_number(item))
		}.compact.reject { |item|
			item.keys.include? nil
		}
	end

	def item_number item
		regex = /(\d*)\..*/
		matcher = item.match(regex)
		(matcher.nil? ? nil : (item.match regex)[1] )
	end

	def item_name item
		regex = /\d*\. (.*)/
		matcher = item.match(regex)
		(matcher.nil? ? nil : (item.match regex)[1] )
	end

	def get_recommendations file_text, radar_date
		recommendations = ["Adopt", "Trial", "Assess", "Hold"]

		current_recommendation = nil
		file_text.split("\n").map { |item|
			line_components = item.split(" ").map {|component|
				component.split(",")
			}.flatten
			current_recommendation = line_components.first
			{current_recommendation => [rec_item_numbers(current_recommendation, line_components), radar_date] }
		}.reject {|rec|
			!(recommendations.include? rec.keys.first)
		}
	end

	def rec_item_numbers current_recommendation, line_components
		line_components.delete(current_recommendation)
		numbers = []
		line_components.map { |range|
			range = range.split("-")
			range.delete("-")
			
			first = range.first.to_i
			last = range.last.to_i

			(first..last).each {|number|
				numbers += [number.to_s]
			}
		}.flatten
		numbers
	end

	def get_items_with_recommendations file_text, radar_date
		all_recs = get_recommendations(file_text, radar_date)
		all_recs.each { |foo|
			puts "all_recs #{all_recs}"
			all_recs.each { |rec_type_hash|
				rec_type = rec_type_hash.first
				rec_date_array = rec_type_hash.values.first
				
				rec_numbers = rec_date_array.first
				rec_date = rec_date_array.last

				puts "- - - rec_numbers #{rec_numbers} ... rec_date #{rec_date}"

				get_items_for_date(rec_date).each { |item|
	# 		items_for_date(rec_date).each
	# 			items.values.each |hash_with_item_date_as_key|
	# 				if hash_with_item_date_as_key.keys.first == rec_date
	# 					rec_numbers.each |rec_number|
	# 					if hash_with_item_date_as_key.values.includes rec_numbers
	# 						add recommendation value to item
				}
			}

		}

		{}
	end

	def get_items_for_date(full_file_text, date)
		# get_items_from_file(full_file_text, date)

	end



	def tech_object item_name, radar_date, most_recent_header, recommendation, item_number
		{ item_name => { 
				radar_date => {
					"category" => most_recent_header,
					"number" => item_number
					# "recommendation" => recommendation
				}
			}
		}
	end
end
