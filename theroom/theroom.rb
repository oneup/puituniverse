class Theroom < Game
  resolution [640, 480]
  
  def setup
    @selected_game_nr = 0

    @bundles = []
    ".".each_dir do |possible_game|
      begin
        @bundles << possible_game unless possible_game.starts_with?(".")
        #@bundles << possible_game.instantiate # if we have a x_game class
      rescue
        #println "boken game or no game: #{possible_game}"
      end
    end
    
    #set :font, "Lucida Grande".ttf
  end
  
  def button_down id
    super id # do whatever we would usually do
    
    case id
      when Gosu::Button::KbDown
        @selected_game_nr += 1
      when Gosu::Button::KbUp
        @selected_game_nr -= 1
      when Gosu::Button::KbReturn
        #close
        `ruby play.rb #{selected_game}&`
        #exit(1)
    end
    
    @selected_game_nr = (0...(@bundles.count-1)).limit @selected_game_nr # has to be between 0 and $games.count so we don't selected non-existant bla bla bla bla bla bla bla bla bla :P
  end
  
  def update
  end
  
  def selected_game
    @bundles[@selected_game_nr]
  end
  
  def draw
    x = 10
    y = 0
    @bundles.each do |game|
      x = selected_game == game ? 40 : 10
      font.draw(game, x, y, 0)
      y += font.height
    end
  end

  def font
    @@font ||= begin
      "Lucida Grande".ttf($game.height/(@bundles.count))
    rescue
      "Verdana".ttf($game.height/(@bundles.count)) # windows users only have Verdana. poor them :( :P
    end
  end
end