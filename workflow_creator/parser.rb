#!/usr/bin/ruby
# Michael Parkin (26/03/2009)
# A script to parse jobs from Viktor's Job Generator and
# create dependencies between the tasks so we end up 
# with a workflow like Grid and COMP Superscalar produce.
#
# The idea is then to use the workflow to determine the
# 'best' strategy for pricing such workflows.
#
# Viktor's Job Generator creates a table with the following
# data in each column of each HTML table row:
#
# 1-Arrival time/current time (wallclock). 
# 2-Job Rate.
# 3-Tightness. An intermediate parameter that determines
#   the time constraints (see the last two parameters in
#   this list).
# 4-Number of CPU nodes required by the job.
# 5-Job Duration time. The actual time it takes for the
#   job from start to finish. Can be viewed as projected
#   job duration time.
# 6-Earlest allowed start time for the job (wallclock).
# 7-Latest allowed finish time for the job (wallclock).
#
require 'rubygems'
require 'job'
require 'hpricot'
require 'workflow'

# get the paths and file names being used.
workload_file = ARGV[0]
working_dir = File.dirname( ARGV[0] )

# -- start of job extraction -- 
page = Hpricot.parse( File.read( workload_file ) )
page.search("fieldset").remove
page.search("th").remove
tables = page.search("table")

workflow = Workflow.new

# get the data from the first table
tables[0].search("tr").each do |row|
  begin
    data = row.search("td")
    args = { :time           => data[0].inner_text.to_f,
             :job_rate       => data[1].inner_text.to_f,
             :tightness      => data[2].inner_text.to_f,
             :cpu_count      => data[3].inner_text.to_f,
             :duration       => data[4].inner_text.to_f,
             :earliest_start => data[5].inner_text.to_f,
             :latest_finish  => data[6].inner_text.to_f }
    workflow.add_job_at_time( Job.new( args ), args[:time] )
  rescue
    nil
  end
end
# -- end of job extraction --

# -- create simple dependencies between jobs --
workflow.create_dependencies

# visualise the workflow to a png file
workflow.visualise_to_file( working_dir + '/workflow', 'png' )

# -- find workflow properties --
p "Number of jobs: " + workflow.number_of_jobs.to_s
p "Total CPU time needed: " + workflow.total_duration.to_s
p "Wallclock time needed: " + workflow.workflow_duration.to_s


