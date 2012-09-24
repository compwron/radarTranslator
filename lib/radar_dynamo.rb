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

	def get_items file_text, radar_date
		recommendation = "not set yet"

		most_recent_header = ""
		file_text.split("\n").select { |item| 
			!item.nil? 
		}.map { |item| 
			most_recent_header = item if (types.include?(item)) 
			most_recent_header == item ? nil : tech_object(item_name(item), radar_date, most_recent_header, recommendation)
		}.compact
	end

	def get_recommendations file_text
		recommendations = ["Adopt", "Trial", "Assess", "Hold"]

		current_recommendation = nil
		file_text.split("\n").map { |item|
			line_components = item.split(" ")
			current_recommendation = line_components.first
			{ current_recommendation => item_numbers(current_recommendation, line_components) }
		}
	end

	def item_numbers current_recommendation, line_components
		line_components.delete(current_recommendation)
		line_components.map { |range|
			range = range.split("")
			range.delete("-")
			
			first = range.first.to_i
			last = range.last.to_i

			numbers = []
			(first..last).each {|number|
				numbers += [number.to_s]
			}
			numbers
		}.flatten
	end

	def item_name item
		matcher = item.match(/\d*\. (.*)/)
		(matcher.nil? ? nil : (item.match /\d*\. (.*)/)[1] )
	end

	def tech_object item_name, radar_date, most_recent_header, recommendation
		{ item_name => { 
				radar_date => {
					"category" => most_recent_header
					# "recommendation" => recommendation
				}
			}
		}
	end
end
