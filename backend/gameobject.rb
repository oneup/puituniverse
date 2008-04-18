class Gameobject  
  #attr_accessor x,y,w,h from object

  def map_keys mapping
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
  
  def on_button_down id
    on_button(true, id)
  end
  
  def on_button_up id
    on_button(false, id)
  end
  
  def draw
  end
end
