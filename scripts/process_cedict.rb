require 'nokogiri'
require 'rubygems'
require 'active_record'

# DB Setup

ActiveRecord::Base.establish_connection(
:adapter => "mysql2",
:host => "localhost",
:username => "root",
:database => "chinese_thes"
)

class Cedict < ActiveRecord::Base
	set_table_name "cedict"
end

# File Processor

input = File.open("/research/chinese_thes/dictionaries/cedict_ts.u8","r")


for line in input
	# don't process comments
	next if line[0] == "#"
	line_split = line.split()	

	new_entry = Cedict.new()
	new_entry.traditional = line_split[0]
	new_entry.simplified = line_split[1]
	# to get pinyin look between the [ ** ]
	new_entry.pinyin = line[line.index("[")+1 .. line.index("]")-1]
	new_entry.definition = line[line.index("]")+1..-1]
	new_entry.save
end


