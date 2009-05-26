require 'rubygems'
require 'rgl/adjacency'
require 'rgl/dot'

class Workflow
      
  def initialize
    @tasks_by_time = []
  end
    
  def add_task_at_time( task, time )
    ( @tasks_by_time[time] ||= [] ) << task
  end
  
  def create_dependencies
    @graph = RGL::DirectedAdjacencyGraph.new
    @tasks_by_time.each do |tasks|  
      add_nodes_and_edges( tasks )
    end
  end
  
  # return the sum of the duration of the
  # longest task at each time interval
  # this duration is equivalent to the minimum 
  # wallclock time needed to complete the workflow
  def workflow_duration
    workflow_duration = 0
    @tasks_by_time.each do |tasks|
      longest_task_duration = 0
      if tasks && !tasks.empty?
        tasks.each do |task| 
          if task.duration > longest_task_duration
            longest_task_duration = task.duration
          end
        end
      end
      workflow_duration += longest_task_duration
    end
    workflow_duration
  end
  
  # return the sum of durations of all tasks.
  # this duration is the sum of the CPU times 
  # required to complete each task (i.e., the 
  # duration of each task multiplied by the 
  # number of CPUs required for the task).
  def duration
    duration = 0.0
    @tasks_by_time.each do |tasks|
      if tasks && !tasks.empty?
        tasks.each { |task| duration += ( task.duration * task.cpu_count ) }
      end
    end
    duration
  end
  
  # need to have dot[http://www.graphviz.org/]
  # in your application path for this to work
  def visualise_to_file( filename, format)
    src = filename + ".dot"
    dot = filename + "." + format    
    viz = RGL::DOT::Digraph.new

    @graph.each_vertex do |v|
      viz << RGL::DOT::Node.new( 'name' => v.name, 'fontsize' => '8', 'label' => v.name )
    end
      
    @graph.each_edge do |u,v|
      #viz << RGL::DOT::DirectedEdge.new( 'from' => u.name, 'to' => v.name, 'fontsize' => '8' )
    end
      
    File.open(src, 'w') << viz    
    system( "dot -T#{format} #{src} -o #{dot}" )
    dot
  end
  
  # the number of tasks is simply the
  # number of vertices in the graph
  def number_of_tasks
    create_dependencies
    @graph.vertices.length
  end
    
  private 
  def add_nodes_and_edges( next_tasks )
    if next_tasks
      new_nodes = []

      # create new nodes for the next tasks
      next_tasks.each do |next_task|         
        duration = next_task.duration
        name = "%0.2f" % duration
        height = 0.5
        width = 0.5
        node = RGL::DOT::Node.new( { 'name'=>name, 'height'=>height, 'width'=>width }, [ 'name', 'height', 'width' ] )
        new_nodes << node
      end
        
      # add the new nodes and edges from current -> new nodes
      if @current_nodes
        @current_nodes.each do |current_node|
          new_nodes.each { |new_node| @graph.add_edge( current_node, new_node ) }
        end
      end
      
      # set the new nodes to be current nodes
      @current_nodes = new_nodes
    end
  end
end