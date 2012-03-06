require 'rubygems'
require 'mysql2'

client = Mysql2::Client.new(:host => "localhost", :username => "root")

results = client.query("SELECT * FROM chinese_thes.cedict limit 10")

results.each do |row|
  puts row
	# conveniently, row is a hash
  # the keys are the fields, as you'd expect
  # the values are pre-built ruby primitives mapped from their corresponding field types in MySQL
  # Here's an otter: http://farm1.static.flickr.com/130/398077070_b8795d0ef3_b.jpg
end
