# assume that vanishing means staying still (i.e. if in trial and then hold, assume stays in hold)
# desired output: all data in json format. and/or report of everything that has stayed still in adopt (or x section) for x years?
require 'date'

class RadarDynamo
	attr_accessor :filenames

	def initialize data_dir
		@filenames = []
		Dir.foreach(data_dir) { |f| @filenames += [f] }
		@filenames -= [".", ".."]
	end

	def get_data_from_files
		files.map { |f| }
	end

	def data_output
		fake_data = { "Python" => { [Date.new(2012, 3, 1)] => ['Adopt', 'Language', 1] }, "Ruby" => { [Date.new(2012, 3, 1), Date.new(2010, 1, 1)] => ['Adopt', 'Language', 1] } }
	end
end