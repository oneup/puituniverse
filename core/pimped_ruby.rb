alias :old_print :print
def print s
  old_print "#{s}\n"
  STDOUT.flush
end

class String
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
end