class Guid
  
  @@random_device = nil

  def initialize
    if !@@random_device
      if File.exists? "/dev/urandom"
        @@random_device = File.open "/dev/urandom", "r"
      elsif File.exists? "/dev/random"
        @@random_device = File.open "/dev/random", "r"
      else
        raise RuntimeError, "Can't find random device"
      end
    end

    @bytes = @@random_device.read(16)
  end
  
  def to_s
    @bytes.unpack("h8 h4 h4 h4 h12").join "-"
  end
    
end


