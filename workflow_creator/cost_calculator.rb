# should be used to find the prices for the set of workflows
# produced by Viktor, linked by me (using parser.rb) that produces
# 1) number of jobs
# 2) total Duration (processing time required)
# 3) workflow Duration (wallclock time required)
#
# use by intialising with default constants and then call
# gen_cost to generate costs. this will vary the time through
# 0 <= ta <= tm and the confidence through 10%--100% to find
# a set of prices. the three-dimensional cost plane can be
# plotted using gnuplot. the x dimension is time. the y
# dimension is confidence. the z dimension is cost.

class CostCalculator
  # constructor.
  # pen   weighting factor of penalty time (2)
  # te  (estimate of) total duration (300)
  # tm  maximum allowed time for workflow (600)
  # vb  booking fee
  # vr  charging rate of resources (10)
  def initialize( pen, te, tm, vb, vr )
    @pen, @te, @tm, @vb, @vr = pen, te, tm, vb, vr
    @confidences = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]
  end

  def gen_cost
    @results = []
    # for each level of confidence (0..1) increase the time and find the price
    @confidences.each do |c| 
      ta = 0
      while ta <= @tm do
        price = get_price( c, @pen, ta, @te, @tm, @vb, @vr )
        @results << [c, ta, price]
        ta += 1
      end
    end
  end

  def write_results( filename = 'out.dat' )
    if @results.empty?
      raise Exception.new( "Should generate results first" )
    else
      out = File.open( filename, 'wb' )
      out << "#Ta\tc\tprice\n"
      @results.each do |r| 
        out << "\n" if r[1] == 0
        out << r[1].to_s + "\t" +r[0].to_s + "\t" +r[2].to_s + "\n"
      end
      out.close
    end
  end
  
  def create_plot_file ( filename = 'out' )
    s = ""
    s << "unset log\n"
    s << "unset label\n"
    s << "unset key\n"
    s << "unset xtics\n"
    s << "unset ytics\n"
    s << "unset ztics\n"
    s << "set size 1.0 ,1.0\n"
    s << "set title \"Cost vs. Time vs. Confidence\"\n"
    s << "set label \"data\" at 2,0.5"
    s << "set xtic auto\n"
    s << "set ytic auto\n"
    s << "set ztic 80000\n"
    s << "set xlabel \"Time\"\n"
    s << "set ylabel \"Confidence\"\n"
    s << "set zlabel \"Cost\"\n"
    s << "set zrange [0:550000]\n"
    s << "set ticslevel 0\n"
    s << "set pointsize 0.2\n"
    s << "set pm3d\n"
    s << "set isosample 500\n"
    s << "set view 120,45\n"
    s << "set term postscript eps color enh"
    s << "set output \"#{filename}.eps\"\n"
    s << "splot \"out.dat\"\n"
    
    script_file_name = "#{filename}.p"
    File.open( script_file_name, 'wb' ) << s
    script_file_name
  end
    
  private 
  def largest_cost
    largest_cost = 0.0
    @results.each { |r| largest_cost = r[2] if r[2] > largest_cost }
    largest_cost
  end
  
  private 
  def get_price( c, pen, ta, te, tm, vb, vr )
    price = vb
    if ta <= te                         # ta upto and equal to te
      price += ( vr / c ) * ta
    elsif ( ta > te ) && ( ta < tm )    # ta above te upto tm
      price += ( ( vr / c ) * te ) + (( pen * vr / c ) * ( ta - te ) )
    elsif ta >= tm                      # tm and above
      price += ( ( vr / c ) * te ) + ( ( pen * vr / c ) * ( tm - te ) )
    end
    price
  end
end