#! /usr/bin/ruby

require 'parseconfig'

config = ParseConfig.new(ARGV[0])
template_file = config['template_file']
unless File.file?(template_file)
	puts "ERROR: Check the template_file configuration variable is correct (points to a valid template's filename) in #{ARGV[0]}"
	abort
end

