from backgroundstuff.boundingbox import Boundingbox

import puit
from puit.objects.character import Character
from puit.objects.itemcrate import Itemcrate
from puit import draw as draw_me_a

class Radar(object):
  def __init__(self, gamestate):
    self._gamestate = gamestate
    self._width = puit.gamemaster.scrollarea.width
    self._height = 20
    self._bottom = puit.gamemaster.scrollarea.height - (self._height + 1)
    self._level_width = gamestate.level.boundingbox.width
    self._level_height = gamestate.level.boundingbox.height
    self._map_pic = gamestate.level.get_mini_graphic()
    self._x_ratio = float(self._width) / self._level_width
    self._y_ratio = float(self._height) / self._level_height
    self._player_dot_bounds = Boundingbox(size=(1, 1))
    self._blink_counter = 0
    self._on_ticks = 20
    self._repeat_ticks = 30
    self._zoom_factor = self._width / float(self._level_width)
    mini_screen_width = int(self._zoom_factor * self._width)
    self._mini_screen_bounds = Boundingbox(size=(mini_screen_width, self._height))
  
  def draw(self):
    scroll_location = int(puit.gamemaster.scrollarea.left * self._zoom_factor)
    self._mini_screen_bounds.bottom_left = (scroll_location, self._bottom)
    draw_me_a.rect(self._mini_screen_bounds, (0.6, 0.87, 1.0))
    self._map_pic = self._gamestate.level.get_mini_graphic()
    self._map_pic.blit(0, self._bottom)
    for p in self._gamestate.get_all(Character):
      x, y = p.boundingbox.center
      x = int(x * self._x_ratio)
      y = int(y * self._y_ratio + self._bottom)
      col = p.team.main_colour_gl
      self._player_dot_bounds.bottom_left = (x, y)
      draw_me_a.rect(self._player_dot_bounds, col)
    if self._blink_counter <= self._on_ticks:
      col = (0.9, 0.3, 0.1)
    else:
      col = (0.54, 0.14, 0.0)
    self._blink_counter += 1
    self._blink_counter %= self._repeat_ticks
    for c in self._gamestate.get_all(Itemcrate):
      x, y = c.boundingbox.center
      x = int(x * self._x_ratio)
      y = int(y * self._y_ratio + self._bottom)
      self._player_dot_bounds.bottom_left = (x, y)
      draw_me_a.rect(self._player_dot_bounds, col)