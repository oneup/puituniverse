class Animation
  def initialize name
    @frames = []

    dir = Dir.new name
    dir.each do |entry|
      next if entry.starts_with? '.'
      file = "#{name}/#{entry}"
      @frames << Resources::load_image(file)
    end
  end
  
  def draw x, y, order
    @frames[Gosu::milliseconds / 100 % @frames.size].draw(x,y,order)
  end
end