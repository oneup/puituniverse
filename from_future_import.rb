alias :old_print :print
def print s
  old_print "#{s}\n"
  STDOUT.flush
end

class NilClass
  def empty?
    return true
  end
end

class String
  def uppercase
    upcase
  end

  def uppercase!
    upcase!
  end
  
  def starts_with? what
    self[0...what.size] == what
  end
  
  def ends_with? what
    self[-what.size, what.size] == what
  end
  
  def lines
    ll
    self.each_line {|l| ll << l}
    ll
  end
  
  def classify
    self.capitalize # TODO: make bla_foo into BlaFoo
  end
  
  def instantiate
    Kernel.const_get(classname)
  end
end

def dir folder
  Dir.new(folder)
end

def require_all folder
  dir(folder).each do |file|
    require "#{folder}/#{file}" if file.ends_with? ".rb"
  end
end
