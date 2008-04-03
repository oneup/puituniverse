def println s
  print "#{s}\n"
  STDOUT.flush
end

def quit reason=nil
  println reason || "all fine, kthxbai"
  exit
end

def require_all folder
  folder.dir.each do |file|
    require("#{folder}/#{file}") if file.ends_with? ".rb"
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