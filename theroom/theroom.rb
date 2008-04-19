class Theroom < Game
  def setup
    @games = []
    ".".each_dir do |possible_game|
      begin
        @games << possible_game.instantiate # if we have a x_game class
      rescue
        println "boken game or no game: #{possible_game}"
      end
    end
    
    #set :font, "Lucida Grande".ttf
  end
  
  def update
  end
  
  def draw
    x = 10
    y = 10
    @games.each do |game|
      font.draw(game.name, x, y, 0)
      y += font.height
    end
  end
  
  def font
    "Lucida Grande".ttf
  end
end