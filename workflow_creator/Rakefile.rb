require 'benchmark'
require 'parser'

# ---------------------------------------------------------------------------
desc "clean up generated output files"
task :clean do
  `rm ./examples/out.*`
end

# ---------------------------------------------------------------------------
desc "create graph for 10 job example"
task :ten do
  puts Benchmark.measure { 
    Parser.new( "./examples/10jobs.html", "out" ).parse
  }
end