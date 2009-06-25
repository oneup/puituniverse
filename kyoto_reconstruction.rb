class Class
  def direct_descendents
    result = []
    ObjectSpace.each_object( Class ) do |c|
      result << c if c.superclass == self
    end
    return result
  end
end

module NamedRandom
  def randomly_between(range)
    range.begin + rand*(range.end-range.begin)
  end
  
  def with_probability(p)
    yield if (rand <= p)
  end
end

module NamedFractions
  def half
    0.5
  end
  
  def third
    1.0/3
  end
  
  def quarter
    0.25
  end
end

module Timer
  include NamedFractions
  def after(duration)
    Thread.new do
      sleep duration.to_f
      yield
    end
  end
  
  def every(duration)
    Thread.new do
      while true
        yield
        sleep duration.to_f
      end
    end
  end
end