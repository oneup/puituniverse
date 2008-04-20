class Gameobject  
  include Collideable

  attr_accessor :x, :y, :width, :height

  def set_keys mapping
    @key_mapping = mapping
    @is_pressed = {}
    @key_mapping.each { |key, method| @is_pressed[method] = false }
  end
  
  def has_key_mapping?
    not @key_mapping == nil
  end

  def level
    $level
  end
  
  def update
  end
  
  def die
    @is_dead = true
  end
  
  def is_dead?
    return @is_dead
  end
  
  def set_sprite name
    @sprite = name.img
  end

  def img
    sprite
  end

  def sprite
    @sprite
  end

  def width
    @sprite.width
  end

  def height
    @sprite.height
  end
  
  def on_button down, id
    return unless has_key_mapping?
    method = @key_mapping[id]
    if method
      @is_pressed[method] = down
      self.send(method, down)
    end
  end
  
  def is_pressed? method
    @is_pressed[method]
  end
  
  def button_down id
    on_button(true, id)
  end
  
  def button_up id
    on_button(false, id)
  end
  
  def draw
    sprite.draw(@x, @y, 0) if sprite # meta fixme: set_sprite should recode the draw() function for this object
  end
end