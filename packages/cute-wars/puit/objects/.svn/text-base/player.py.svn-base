import puit
from puit.objects.character import Character, Minigun, Parachute
from puit.objects.bullet import Bullet
import puit.settings
from backgroundstuff.mainloop import CameraTarget
from pyglet import event

class Player(Character):
  def __init__(self, position, team, number):
    self.number = number
    position = list(position)
    position[0] -= self.number * 20
    super(Player, self).__init__(position, team)
    self.keys = puit.settings.keys_player(self.number)
    self.local_human = True
    self.lifes = 2
    self._left_pressed = False
    self._right_pressed = False
    self._jump_pressed = False
    self._shoot_pressed = False
    self._duck_pressed = False
    self._no_shooting_for = 0

  def on_key_press(self, symbol, modifier):
    if symbol == self.keys['left']:
      self._left_pressed = True
      if not self._duck_pressed:
        self.move_left(suppress_turn=self._shoot_pressed)
    elif symbol == self.keys['right']:
      self._right_pressed = True
      if not self._duck_pressed:
        self.move_right(suppress_turn=self._shoot_pressed)
    elif symbol == self.keys['jump']:
      self._jump_pressed = True
      self.jump()
    elif symbol == self.keys['shoot']:
      self._no_shooting_for = 0
      self._shoot_pressed = True
      self.start_use_equipment()
    elif symbol == self.keys['duck']:
      self._duck_pressed = True
      self.stop()
      self.duck()
    
    # AIM UP ^__^/
  
  def on_key_release(self, symbol, modifier):
    if symbol == self.keys['left']:
      self._left_pressed = False
      if self._right_pressed and not self._duck_pressed:
        self.move_right()
      else:
        self.stop()
    elif symbol == self.keys['right']:
      self._right_pressed = False
      if self._left_pressed and not self._duck_pressed:
        self.move_left()
      else:
        self.stop()
    elif symbol == self.keys['shoot']:
      self._shoot_pressed = False
      self.stop_use_equipment()
    elif symbol == self.keys['duck']:
      self._duck_pressed = False
      self.stand_up()
      if self._left_pressed:
        if not self._right_pressed:
          self.move_left()
        else:
          if self.facing_left:
            self.move_left()
          else:
            self.move_left()
      elif self._right_pressed:
        self.move_right()
  
  def landed(self):
    super(Player, self).landed()
    if self._duck_pressed:
      self.duck()
      return
    suppress_turn = self._no_shooting_for < 16
    if self._left_pressed:
      if not self._right_pressed:
        self.move_left(suppress_turn)
      else:
        if self.facing_left:
          self.move_left(suppress_turn)
        else:
          self.move_left(suppress_turn)
    elif self._right_pressed:
      self.move_right(suppress_turn)
    

  def respawn(self):
    self.revive()
    self.stop()
     # the previous version of the avove line had the comment:
     # "todo: can cause problems" -- is this still true?
    self.stop_use_equipment() # todo: can cause problems when relying on fixed start/stopuse cycle
    # FIXME: this is a really ugly hack, the respawn height should depend on
    # the level, but not on the scrollarea! for now it works, as we're only
    # scrolling horizontally.
    self.set_top(puit.gamemaster.scrollarea.top)
    self.velocity[0] = 0
    self.body.equipment = Parachute(self.body)
    self.set_invincible(100)
  
  def die(self, killer=None):
    super(Player, self).die(killer)
    self.gamestate.mainloop.play('die_player.wav')

    self.lifes -= 1
    if self.lifes >= 0:
      self.respawn()

  def draw(self):
    super(Player, self).draw()
    
    life_advance = puit.gamemaster.pixelfont.glyph_width + 1
    # DRAW SCORE
    if self.number == 0:
      x, y = 1, puit.gamemaster.scrollarea.height-6
      puit.gamemaster.pixelfont.draw(str(self.kill_count), x, y)
    elif self.number == 1:
      x, y = puit.gamemaster.scrollarea.width-1, puit.gamemaster.scrollarea.height-6
      puit.gamemaster.pixelfont.draw_right(str(self.kill_count), x, y)
      x -= 5
      life_advance = -life_advance
    elif self.number == 2:
      x, y = 1, 7
      puit.gamemaster.pixelfont.draw(str(self.kill_count), x, y)
    else:
      raise "no hud area defined for player number " + str(self.number)

    y -= puit.gamemaster.pixelfont.line_height()
    for i in range(0, self.lifes):
      puit.gamemaster.pixelfont.draw('L', x, y)
      x += life_advance
    
  scroll_border = 80
  
  
  def tick(self):
    super(Player, self).tick()
    if not self._shoot_pressed:
      self._no_shooting_for += 1
    #p  = self.boundingbox.bottom_left
    #if p[0] - Player.scroll_border < puit.gamemaster.scrollarea.left:
    #  puit.gamemaster.scrollarea.left = p[0] - Player.scroll_border
    #
    #if p[0] + Player.scroll_border > puit.gamemaster.scrollarea.left \
    #    + puit.gamemaster.scrollarea.width:
    #  puit.gamemaster.scrollarea.left = p[0] + Player.scroll_border \
    #      - puit.gamemaster.scrollarea.width
    if self.local_human:
      if self.facing_left:
        facing = CameraTarget.LEFT
      else:
        facing = CameraTarget.RIGHT
      camera_target = CameraTarget(self.boundingbox.center_x,
        self.boundingbox.center_y, facing)
      puit.gamemaster.add_camera_target(camera_target)
  
  def pickup_item(self, item):
    if item == 'minigun':
      self.body.equipment = Minigun(self.body)