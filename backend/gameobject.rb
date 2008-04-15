class Gameobject  
  def level
    $level
  end
  
  def update
  end
  
  def on_button down, id
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
