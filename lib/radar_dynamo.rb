# assume that vanishing means staying still (i.e. if in trial and then hold, assume stays in hold)
# desired output: all data in json format. and/or report of everything that has stayed still in adopt (or x section) for x years?
require 'date'

class RadarDynamo
	attr_accessor :filenames, :data_dir

	def initialize data_dir
		@data_dir = data_dir
		@filenames = []
		Dir.foreach(data_dir) { |f| @filenames += [f] }
		@filenames -= [".", ".."]
	end

	def get_data_from_files
		lines = []
		filenames.map { |f| 
			File.open(data_dir + "/" + f).each_line { |line|
				lines += [line] 
			}
			lines.join("")
		}
	end

	def parse_files file_contents
		
	end

	def data_output
		{
			"Python" => {
				"2010-01" => {
					"category" => "languages",
					"recommendation" => "trial"
				},
				"2012-03" => {
					"category" => "languages",
					"recommendation" => "adopt"
				}
			}
		}
	end
end