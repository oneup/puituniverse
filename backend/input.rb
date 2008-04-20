class String
  @@key_mapping = {
    "left" => Gosu::Button::KbLeft,
    "right" => Gosu::Button::KbRight,
    "up" => Gosu::Button::KbUp,
    "down" => Gosu::Button::KbDown,
    "A" => 0,
    "a" => 0,
    :a => 0,
    :A => 0,
    "d" => 2,
    "D" => 2,
    :d => 2,
    :D => 2,
    "w" => 13,
    "W" => 13,
    :w => 13,
    :W => 13,
    "space" => Gosu::Button::KbSpace
  }
  
  @@gamepad_mapping = {
    "left" => Gosu::Button::GpLeft,
    "right" => Gosu::Button::GpRight,
    "up" => Gosu::Button::GpUp,
    "down" => Gosu::Button::GpDown
  }
  
  def gamepad
    return @@gamepad_mapping[self]
  end

  def button
    key
  end

  def key
    return self[0].to_i if self.size == 1
    return @@key_mapping[self]
  end
end