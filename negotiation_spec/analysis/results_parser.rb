#!/usr/bin/ruby
# This script takes a results file containing many outputs from
# multiple TLC runs, parses it and dumps the results in a CSV 
# file called 'csvout' in the currrent directory. A CSV output
# was chosen as this can be imported into Numbers or Excel or
# other spreadsheet applications for analysis, graphing, etc.
# The CSV results array format is:
# [0] start time
# [1] end time
# [2] no. of messages
# [3] duplicates
# [4] generated states
# [5] distinct states
# [6] queue
# [7] depth
# [8] calculated
# [9] fingerprints

# check arguments passed to application.
if !ARGV[0]
  puts "Usage: results_parser.rb [results file name]"
  exit(0)
else
  puts "Opening " + ARGV[0]
end

results = []

# loop over each line in the file
IO.foreach(ARGV[0]) do |line|

  line.lstrip!
  
  if line =~ /model start time: (\d+)/i
    $collect_result = true
    $result = Array.new(10)
    $result[0] = $1.to_i
  end

  if $collect_result
    if line =~ /model end time: (\d+)/i
      $result[1] = $1.to_i
      results << $result
      $collect_result = false # this is last entry in each run
    elsif line =~ /messages: (\d+) duplicates: (\d+)/i
      $result[2], $result[3] = $1.to_i, $2.to_i
    elsif line=~ /(\d+) states generated, (\d+) distinct states found, (\d+) states left on queue./i
      $result[4], $result[5], $result[6] = $1.to_i, $2.to_i, $3.to_i
    elsif line =~ /the depth of the complete state graph search is (\d+)./i
      $result[7] = $1.to_i
    elsif line =~ /calculated \(optimistic\):\s+(((\d+(\.\d*)?)|\.\d+)([eE][+-]?[0-9]+))/i
      $result[8] = $1.to_f
    elsif line =~ /based on the actual fingerprints:\s+(((\d+(\.\d*)?)|\.\d+)([eE][+-]?[0-9]+))/i
      $result[9] = $1.to_f
    end
  end
end

# dump some stats to screen
puts "Processed " + ARGV[0]
puts "There were " + results.size.to_s + " results found."

# write results to CSV file
require 'csv'
outfile = File.open('csvout', 'wb')
CSV::Writer.generate(outfile) do |csv|
  results.each { |result| csv << result }
end
outfile.close
