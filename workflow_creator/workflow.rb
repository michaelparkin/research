require 'rubygems'
require 'rgl/adjacency'
require 'rgl/dot'

class Workflow
      
  def initialize
    @jobs_by_time = []
  end
    
  def add_job_at_time( job, time )
    ( @jobs_by_time[time] ||= [] ) << job
  end
  
  def create_dependencies
    @graph = RGL::DirectedAdjacencyGraph.new
    
    last_jobs  = @jobs_by_time.last
    last_index = @jobs_by_time.index( last_jobs )
      
    @jobs_by_time.each do |jobs|
      jobs_index = @jobs_by_time.index( jobs )
      next_jobs  = get_next_jobs( jobs_index, last_index )
      add_nodes_and_edges( jobs, next_jobs )
    end
  end
  
  # return the sum of the duration of the
  # longest job at each time interval
  # this duration is equivalent to the minimum 
  # wallclock time needed to complete the workflow
  def workflow_duration
    workflow_duration = 0
    @jobs_by_time.each do |jobs|
      longest_job_duration = 0
      if jobs && !jobs.empty?
        jobs.each do |job| 
          if job.duration > longest_job_duration
            longest_job_duration = job.duration
          end
        end
      end
      workflow_duration += longest_job_duration
    end
    return workflow_duration
  end
  
  # return the sum of durations of all jobs.
  # this duration is the sum of the CPU times 
  # required to complete each task (i.e., the 
  # duration of each task multiplied by the 
  # number of CPUs required for the task).
  def total_duration
    total_duration = 0
    @jobs_by_time.each do |jobs|
      if jobs && !jobs.empty?
        jobs.each do |job|
          job_time = job.duration * job.cpu_count
          total_duration += job_time
        end
      end
    end
    return total_duration
  end
  
  # need to have dot[http://www.graphviz.org/]
  # in your application path for this to work
  def visualise_to_file( filename, format)
    @graph.write_to_graphic_file( format, filename )
  end
  
  # the number of jobs is simply the
  # number of vertices in the graph
  def number_of_jobs
    create_dependencies
    @graph.vertices.length
  end

  private
  def get_next_jobs( current_index, last_index )
    next_jobs = nil
    while current_index <= last_index
        current_index += 1
        next_jobs = @jobs_by_time[current_index] 
        break if ( next_jobs && !next_jobs.empty? )
    end
    return next_jobs
  end
  
  private
  def add_nodes_and_edges( jobs, next_jobs )
    if jobs && next_jobs
      jobs.each do |job|
        next_jobs.each do |next_job|
          # TODO: correct labels?
          @graph.add_edge( job, next_job )
        end
      end
    end
  end 
end