class Gameobject
  def img what
    Resources.load_gfx("#{what}")
  end
  
  def level
    $level
  end
  
  def update
  end
  
  def on_button down, id
  end
  
  def draw
  end
end
