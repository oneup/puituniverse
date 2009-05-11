from pyglet import window
from pyglet import clock
from pyglet.window import key
from pyglet.gl import *

import puit
from puit.state.objectcollection import TritreeObjectCollection
from puit.state.objectcollection import DictObjectCollection
from puit.state.objectcollection import ForkedObjectCollection
from puit.state.objectcollection import ObjectCollection
from puit.objects.bullet import Bullet

class Gamestate(object):
  show_fps = False

  def __init__(self):
    level_bounds = None
    if hasattr(self, 'level'):
      level_bounds = self.level.boundingbox
    self.collision_relations = {
        'bullets': ['targets'],
        'goodies': ['targets'],
        'scenery': ['bullets', 'targets', 'goodies', 'debris']
      }
    self.sorting_hints = {
        'bullets': ObjectCollection.HINT_SHALLOW,
        'debris': ObjectCollection.HINT_SHALLOW,
        'goodies': ObjectCollection.HINT_DEEP,
        'scenery': ObjectCollection.HINT_DEEP,
        'targets':  ObjectCollection.HINT_DEEP
      }
    #self.objects = TritreeObjectCollection(level_bounds, self.collision_relations,
    #    self.sorting_hints)
    #self.objects = DictObjectCollection(level_bounds, self.collision_relations,
    #    self.sorting_hints)
    self.objects = ForkedObjectCollection(level_bounds, self.collision_relations,
        self.sorting_hints)
    self.objects_to_add = []

  def tick(self):
    self._tick_objects()

  def draw(self):
    self._draw_objects()
  
  def update(self, draw=True):
    self.tick()
    if draw:
      glClearColor(132/255.0, 202/255.0, 236/255.0, 1) # why is this here (and not in draw)? (FIXME?)
      puit.gamemaster.viewport.begin()
      # glClear(GL_COLOR_BUFFER_BIT) # <-- this isn't needed. we're clearing the
          # colour buffer anyways, below. self.clear() also clears the depth
          # buffer, which isn't needed yet, but i've left it in since i want to
          # make use of that soon.
      puit.gamemaster.clear()
      self.draw()
      if Gamestate.show_fps:
        puit.gamemaster.pixelfont.draw("%.1f fps" % clock.get_fps(), 1, 1)
        puit.gamemaster.pixelfont.draw("%d obj" % len(self.objects), 1, 7)
      puit.gamemaster.viewport.end()
      puit.gamemaster.flip()
    
  #don't call this from outside. this is called automatically by the dispatcher
  def _tick_objects(self):
    for gameobject in self.objects:
      gameobject.move()
    
    #self._collide_objects(self.collideable_objects['scenery'],
    #    self.get_collideable_objects())
    #self._collide_objects(self.collideable_objects['bullets'],
    #    self.collideable_objects['targets'])
    #self._collide_objects(self.collideable_objects['goodies'],
    #    self.collideable_objects['targets'])
    # FIXME: get rid of the above, finish what's below:
    self._collide_objects() #self.objects, self.objects)

    for gameobject in self.objects:
      gameobject.tick()

    #cleanup gameobject tree
    self.remove_dead_objects()
    
    self.objects.extend(self.objects_to_add)
    #for o in self.objects_to_add: # FIXME: clean this up
    #  if hasattr(o, 'collision_group'):
    #    self.collideable_objects[o.collision_group].append(o)
    self.objects_to_add = []
  
  def get_all(self, cls):
    return self.objects.get_all(cls)
    """result = []
    for o in self.objects:
      if isinstance(o, cls): # TODO: should be done via duck typing
        result.append(o)
    return result"""
      
    
  def on_end(self):
    """
    is called when this gamestate is ending (and a new one will be started)
    """
    pass
  
  def _draw_objects(self):
    for gameobject in self.objects:
      gameobject.draw()
  
  def on_key_press(self, symbol, modifiers):
    if symbol == key.F1:
      Gamestate.show_fps = not Gamestate.show_fps
      
    for gameobject in self.objects:
      gameobject.on_key_press(symbol, modifiers)
    
  def on_key_release(self, symbol, modifiers):
    for gameobject in self.objects:
      gameobject.on_key_release(symbol, modifiers)
  
  def please_quit(self):
    self.mainloop.please_quit()
  
  def add_object(self, gameobject):
    gameobject.gamestate = self
    # this intermediate step is required to omit certain quirks with objects
    # created in key event handlers (which would get a key event they shouldn't get. etc)    
    self.objects_to_add.append(gameobject)
  
  def remove_dead_objects(self):
    for gameobject in self.objects:
      if gameobject.is_dead:
        self.objects.remove(gameobject)
    #for gameobject in self.get_collideable_objects(): # FIXME: clean this up
    #  if gameobject.is_dead:
    #    self.remove_collideable_object(gameobject)
  
  #def _collide_objects(self, colliders, targets):
    #for gameobject_collider in colliders:
    #  for gameobject_target in targets:
  def _collide_objects(self):
      h = self.objects.collisions
      # print len(h) # FIXME: clean this up
      for gameobject_collider, gameobject_target, target_parts in h:
        #if not gameobject_collider.is_dead \
        #    and not gameobject_target.is_dead \
        #    and gameobject_collider != gameobject_target:
          try:
            gameobject_collider.collide_with(gameobject_target, target_parts)
          except AttributeError:
            pass # not all objects need to implement collide_with
  
  def get_collideable_objects(self): # FIXME: do we still need this?
    ret_val = []
    for group in self.collideable_objects.values():
      ret_val.extend(group)
    return ret_val
  
  def remove_collideable_object(self, gameobject): # FIXME: this still needed?
    for group in self.collideable_objects.values():
      try:
        group.remove(gameobject)
      except ValueError:
        pass # gameobject doesn't have to be in every group, that's OK