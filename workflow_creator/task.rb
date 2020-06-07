class Task
  
  attr_reader :time, :task_rate, :tightness, :cpu_count,
              :duration, :earliest_start, :latest_finish
  
  def initialize( args )
    @time           = args[:time]
    @task_rate      = args[:task_rate]
    @tightness      = args[:tightness]
    @cpu_count      = args[:cpu_count]
    @duration       = args[:duration]
    @earliest_start = args[:earliest_start]
    @latest_finish  = args[:latest_finish]
  end
end