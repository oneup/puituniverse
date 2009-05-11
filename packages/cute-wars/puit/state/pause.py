import random, os
from puit.state.gamestate import Gamestate
from puit.objects.menuitem import MenuitemGroup
from backgroundstuff import graphics
import puit
import puit.state
# commented out next line for now, since it seems to be good for nothing
# from backgroundstuff.boundingbox import Boundingbox

class PauseMenu(MenuitemGroup):
  def __init__(self, x, y):
    super(PauseMenu, self).__init__(['resume', 'exit to menu'], x, y)
  
  def on_selected(self, text):
    if text == 'resume':
      puit.gamemaster.switch_state(self.gamestate.suspended_state)
    elif text == 'exit to menu':
      puit.gamemaster.switch_state(puit.state.get_menu())


class Pause(Gamestate):
  def __init__(self, suspended_state):
    super(Pause, self).__init__()
    self.suspended_state = suspended_state
    
    self.add_object(PauseMenu(puit.gamemaster.scrollarea.width/2 - 20, puit.gamemaster.scrollarea.height/2))

  def draw(self):
    super(Pause, self).draw()
    self.suspended_state.draw()