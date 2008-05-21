#!/home/parkinm/software/ruby/bin/ruby
require 'rubygems'
require 'net/http'
require 'uri'

url = URI.parse("http://localhost:3000/usage_records")
record_no = 0
records_added = 0
records_failed = 0
total_bytes = 0
start_time = Time.now
output = STDOUT
offset = ARGV[1].to_i

File.open( ARGV[0] ).each do |record|

  if (record_no > offset )
    req = Net::HTTP::Post.new( url.path )
    req.content_type = "application/xml+gfd-r-p.098"
    req.body = record
    total_bytes += record.length
    
    res = Net::HTTP.new( url.host, url.port ).start { |http| http.request( req ) }
 
    case res
    when Net::HTTPSuccess 
      output.print( '.' )
      records_added += 1
    else
      res.error!
      records_failed += 1
      output.print( 'F' )
    end

    output.flush

  end

  record_no += 1

end

end_time = Time.now
time_taken = end_time - start_time
total_records = records_added + records_failed

print "\n"
p "Time taken:           " + time_taken.to_s + " secs"
p "Total records posted: " + total_records.to_s
p "  Sucessfully:        " + records_added.to_s
p "  Unsuccessfully:     " + records_failed.to_s
p "Average time:         " + ( total_records / time_taken.to_i ).to_s + " records/sec"
p "Average record size   " + ( total_bytes / total_records ).to_s + " bytes"

