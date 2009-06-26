def println s
  print "<nil>" if s.nil?
  print "#{s}\n"
  STDOUT.flush
end

def quit reason=nil
  println reason || "all fine, kthxbai"
  exit
end

def require_all folder
  dir = folder.dir
  raise "no directory #{folder} found" unless dir

  dir.each do |file|
    next unless file
    require("#{folder}/#{file}") if file.ends_with? ".rb"
  end
end

def require_package folder
  # slightly python-y packages. init.rb is required first, then everything else is required
  init_file = "#{folder}/init.rb"
  require init_file if init_file.is_file?
  require_all folder
end

class Object
  def is? what
    self == what
  end
  
  def is_array?
    return false
  end
  
  def is_symbol?
    return false
  end
end

class Range
  def limit value
    return first if value < first
    return last if value > last
    return value
  end
end

class NilClass
  def empty?
    return true
  end
end

class String
  def dir
    Dir.new(self)
    #files = []
    #dir.each {|f| files << f }
    #files
  end
  
  def is_dir?
    begin
      Dir.new(self)
    rescue
      return false
    end
    true
  end
  
  def each_dir
    self.dir.each do |target|
      yield(target) if target.is_dir?
    end
  end
  
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
    camelize(self.sub(/.*\./, ''))
  end
  
  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    return camelize(self) unless lower_case_and_underscored_word

    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end
  
  def instantiate
    Kernel.const_get(self.classify)
  end
end

class Array
  def count
    self.size
  end
  
  def is_array?
    true
  end
end

class Symbol
  def is_symbol?
    true
  end
end

class Hash
  def keys
    self.collect {|key, value| key}
  end
  
  def values
    self.collect {|key, value| value}
  end
end

def probability p
  rand < p
end

def repl
  # thx mike http://mike-burns.blogspot.com/2005/06/ruby-repl.html
  print "exc"
  while true
    '> '.display
    gets.each do | e |
      puts(eval(e))
    end
  end
end
