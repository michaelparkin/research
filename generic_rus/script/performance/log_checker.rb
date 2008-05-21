#!/home/parkinm/software/ruby/bin/ruby
record_number = 0
total_time = 0.0
average = 0.0

File.open( ARGV[0] ).each_line do |line|
  
  if line.include?('Completed in')
    
    record_number += 1
  
    tmp = line.slice( 13, line.length )
    time = tmp.slice( 0, tmp.index( ' ') ).to_f
    total_time += time
  
    tmp = line.slice( 22, line.length )
    requests_sec = tmp.slice( 0, tmp.index( ' ') ).to_f    
    average += requests_sec    
  end
  
end

p record_number.to_s + " uploads in " + total_time.to_s + " seconds"
p "average time: " + ( total_time / record_number ).to_s
p "average number of records/sec " + ( average / record_number ).to_s 