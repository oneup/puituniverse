# hmm, does this belong in objects or state? putting it in state for now,
# as objects _are_ state, and functionally this belongs closer to
# state.gamestate than to objects.gameobject. i suspect it really belongs in
# backgroundstuff.

if __name__ == '__main__':
  # make the import statement below work ...
  import os
  import sys
  dir = os.path.dirname(os.path.abspath(sys.modules[__name__].__file__))
  sep = os.path.sep
  par = os.path.pardir
  dir += sep + par + sep + par + sep
  dir = os.path.abspath(dir)
  sys.path.insert(0, dir)
  import backgroundstuff

from backgroundstuff.boundingbox import Boundingbox
from puit.objects.player import Player # FIXME: this has to go when it's not needed any longer

import math

# TODO: now that i'm in the process of making CompositeGameobjects, i have to
# figure out how to detect, handle and report collisions, and work this into
# the documentation of ObjectCollection. looking at the current implementation,
# i'd say that the 'collider' should always be a non-container object; if
# multiple game objects inside a container object collide with something else,
# multiple collisions will be generated. however, i don't want to hit targets
# directly when they're a component of a CompositeGameobject, because then
# they might need to notify their container object, which means each object
# that can be a target would have to be extended so it's aware of whether
# it is in a container or not. it's simpler to avoid this, so game objects
# don't have to care at all whether they're inside a container or not.
# therefore, when parts of a container are hit, the container will be notified,
# but a list of affected parts is passed along as an argument. another
# preliminary decision i have made for now is that when colliding against
# a CompositeGameobject, only the collision_group of this object matters and
# the collision_groups of the contained objects aren't evaluated. the same is
# not true for the reverse situation: because parts of a container will
# collide individually against other objects, in this case their collision
# groups matter. one more thing: container game objects must not contain other
# container objects, only basic, non-container game objects.

class ObjectCollection(object):
  """This 'abstract class' describes the interface for all object collections.
  """
  HINT_DEEP = 0
  HINT_SHALLOW = 1
  
  def __init__(self, dimensions, collision_relations, sorting_hints=None, parent=None):
    """See long description for explanations of the arguments.
    
    - dimensions: a backgroundstuff.boundingbox.Boundingbox that describes the
      extents of the area covered by this collection. all contained Gameobjects
      should remain completely inside this area; depending on the implementation
      of a concrete object collection, this constraint may be strictly enforced,
      or not. the reason why this constraint exists is that it helps collision
      detection. it is permissible to pass None for dimensions.
    - collision_relations: a dict that has collision groups as keys and lists
      of collision groups as values. if group bar is in the list assigned to
      the key group foo, this means that foo.collide_with(bar) is a sensible
      operation; i.e. the dict describes what can collide with what. this is
      required for performing collision detection. the result of passing None for
      collision_relations isn't well defined yet, but you can probably get away
      with it if you never query the collection for collisions.
    - sorting_hints: optional argument, not processed by every object collection.
      this is a dict that maps collision groups to either
      ObjectCollection.HINT_DEEP or ObjectCollection.HINT_SHALLOW. As a rule of
      thumb, DEEP is appropriate for objects that are rather static (little to
      no movement) and long-lived. SHALLOW is appropriate for objects that
      either move very quickly most of the time (bullet speed) or are rather
      short-lived (a few seconds or less).
    - parent: this argument is only used by object collections that create
      more collections recursively; users never need to supply a parent
      themselves.
    """
    # FIXME: look up the proper idiom for forcing people to supply keyword
    # arguments only with their respective keywords, and implement it here.
    # i think it's done by inserting *args in between the positional args and the
    # keyword args.
    raise NotImplemented
  
  def add(self, gameobject):
    """add gameobject to this collection.
    
    N.B.: the result of adding an object multiple times is not defined!
    N.B.: some concrete implementations may delay actual addition (i.e.
    when gameobject will show up in queries) until after all iterators have
    finished.
    """
    raise NotImplemented
  
  def extend(self, collection):
    """add every gameobject contained in collection to this collection.
    
    - collection: this argument must be a list, tuple, or similar.
    """
    raise NotImplemented
  
  def remove(self, gameobject):
    """remove gameobject from this collection.
    """
    raise NotImplemented
  
  def notify_moved(self, gameobject, boundingbox):
    """notify this collection that gameobject has moved and thus a new bounding box.
    
    this is important for implementations that cache information about the
    relative positions of objects in order to speed up collision detection.
    - gameobject: an object contained in this collection.
    - boundingbox: the updated bounding box of gameobject. this must be the
      exact same object that is available as gameobject.boundingbox. yes, this
      is redundant, and it might change, but for now it's no problem, as
      boundingbox is already at hand in every place that calls notify_moved.
    """
    raise NotImplemented
  
  def __len__(self):
    """return number of objects contained in this collection.
    
    number does not include objects that are queued for addition, but not yet
    added because an iterator is still accessing this collection; and does
    include objects that are queued for removal, but not yet removed for the
    same reason.
    """
    raise NotImplemented
  
  def __iter__(self):
    """standard iterator interface.
    
    returns an iterator that is designed to be fool-proof, i.e. you may
    add and remove objects while iterating over this collection. however,
    iterators are not required to cache a copy of each collection (for some
    implementations, this might be expensive). therefore, the effects of
    additions and removals may be delayed until after all iterators have
    finished. therefore, it is important to never hold onto an iterator
    object across multiple ticks.
    """
    raise NotImplemented
  
  def get_all(self, cls):
    """get all objects that are instances of class cls or a subclass thereof.
    
    the collection may assume that all instances of a class belong to the
    same collision group, because, depending on the internal implementation,
    this may aid performance. therefore, make sure the objects you put into
    the collection don't violate this constraint. however, different classes
    may have the same collision group.
    """
    raise NotImplemented
  
  def _get_collisions(self):
    raise NotImplemented
  
  collisions = property(_get_collisions)
  """a list of all tuples of intersecting objects in this collection.
  
  this read-only property is evaluated each time it is accessed. each tuple
  (foo, bar) is a potential collison that fulfills all of the following
  requirements:
  * the bounding boxes of foo and bar intersect
  * foo is described as being able to collide with bar by the
    collision_relations dict that was supplied to this collection; i.e.
    foo.collide_with(bar) is a sensible operation
  * both foo and bar are alive
  * foo != bar
  the list is complete, i.e. it may contain both (foo, bar) and (bar, foo).
  """

class DictObjectCollection(ObjectCollection):
  def __init__(self, dimensions, collision_relations, sorting_hints=None, parent=None):
    self._collision_relations = collision_relations
    self._colliding_objects = {}
    for group in collision_relations:
      if group not in self._colliding_objects:
        self._colliding_objects[group] = []
      for group in collision_relations[group]:
        if group not in self._colliding_objects:
          self._colliding_objects[group] = []
    self._misc_objects = []
  
  def add(self, gameobject):
    try:
      self._colliding_objects[gameobject.collision_group].append(gameobject)
    except KeyError:
      self._misc_objects.append(gameobject)
  
  def extend(self, collection):
    for o in collection:
      self.add(o)
  
  def remove(self, gameobject):
    try:
      self._colliding_objects[gameobject.collision_group].remove(gameobject)
    except KeyError:
      self._misc_objects.remove(gameobject)
  
  def notify_moved(self, gameobject, boundingbox):
    pass
  
  def __len__(self):
    ret_val = 0
    for group in self._colliding_objects.values():
      ret_val += len(group)
    ret_val += len(self._misc_objects)
    return ret_val
  
  def __iter__(self):
    all_objects = self._misc_objects[:]
    for group in self._colliding_objects.values():
      all_objects.extend(group)
    return all_objects.__iter__()
  
  def get_all(self, cls):
    ret_val = []
    if cls.collision_group in self._colliding_objects:
      h = self._colliding_objects[cls.collision_group]
    else:
      h = self._misc_objects
    for obj in h:
      if isinstance(obj, cls):
        ret_val.append(obj)
    return ret_val
  
  def _get_collisions(self):
    collisions = []
    for collider_group in self._collision_relations:
      for collider in self._colliding_objects[collider_group]:
        for target_group in self._collision_relations[collider_group]:
          for target in self._colliding_objects[target_group]:
            collisions.extend(self._evaluate_collison(collider, target))
    return collisions
  
  collisions = property(_get_collisions)

  def _evaluate_collison(self, collider, target):
    if collider.boundingbox.intersects(target.boundingbox) \
        and (collider != target) and (not collider.is_dead) \
        and (not target.is_dead):
      if collider.container:
        result = []
        for part in collider.get_parts():
          result.extend(self._evaluate_collison(part, target))
        return result
      if target.container:
        parts = []
        for part in target.get_parts():
          if collider.boundingbox.intersects(part.boundingbox) \
              and (collider != part) and (not part.is_dead):
            parts.append(part)
        if len(parts) > 0:
          return [(collider, target, parts)]
        else:
          return []
      else:
        return [(collider, target, None)]
    else:
      return []


class ForkedObjectCollection(ObjectCollection):
  def __init__(self, dimensions, collision_relations, sorting_hints=None, parent=None):
    self._shallow = DictObjectCollection(dimensions, collision_relations,
        sorting_hints)
    self._deep = TritreeObjectCollection(dimensions, collision_relations,
        sorting_hints)
    self._sorting_hints = sorting_hints.copy()
    for group, hint in self._sorting_hints.items():
      if hint == ObjectCollection.HINT_SHALLOW:
        self._sorting_hints[group] = self._shallow
      else:
        self._sorting_hints[group] = self._deep
  
  def add(self, gameobject):
    self._sorting_hints.get(gameobject.collision_group, self._shallow
        ).add(gameobject)
  
  def extend(self, collection):
    for o in collection:
      self.add(o)
  
  def remove(self, gameobject):
    self._sorting_hints.get(gameobject.collision_group, self._shallow
        ).remove(gameobject)
  
  def notify_moved(self, gameobject, boundingbox):
    self._sorting_hints.get(gameobject.collision_group, self._shallow
        ).notify_moved(gameobject, boundingbox)
  
  def __len__(self):
    return len(self._shallow) + len(self._deep)
  
  def __iter__(self):
    for o in self._deep:
      yield o
    for o in self._shallow:
      yield o
  
  def get_all(self, cls):
    return self._sorting_hints.get(cls.collision_group, self._shallow
        ).get_all(cls)
  
  def _get_collisions(self):
    ret_val = []
    self._deep._get_collisions(ret_val)
    ret_val.extend(self._shallow._get_collisions())
    for o in self._shallow:
        self._deep._collide_object_with_node(o, ret_val)
    return ret_val
  
  collisions = property(_get_collisions)


class TritreeObjectCollection(ObjectCollection):
  # N.B.: this is an experimental implementation that allows you to do crazy
  # stuff you don't actually need. the final version will be much shorter and
  # cleaner; as a result, it should also be a bit faster.
  SPLIT_THRESH = 16
  MERGE_THRESH = 6
  LEFT_RIGHT = 0
  BOTTOM_TOP = 1
  
  def __init__(self, dimensions, collision_relations, sorting_hints=None, parent=None):
    self._dimensions = dimensions
    self._collision_relations = collision_relations
    self._objects = []
    self._object_count = 0
    self._split_direction = None
    self._near_subnode = None
    self._middle_subnode = None
    self._far_subnode = None
    self._parent = parent
    self._iterators = 0 # how many iterators are currently accessing this collection
    self._waiting_for_add = []
    self._has_objects_to_add = False
    self._waiting_for_remove = []
    self._has_objects_to_remove = False
  
  def add(self, o, supress_split=False):
    # print "add", o
    if (self._split_direction is None) and (len(self._objects
        ) >= (self.SPLIT_THRESH - 1)) and (self._dimensions is not None
        ) and (self._dimensions.height >= 2) and (self._dimensions.width >= 2
        ) and (not supress_split):
      self._split()
    if (self._split_direction is None):
      if self._iterators > 0:
        self._waiting_for_add.append(o)
        self._has_objects_to_add = True
        return
      self._objects.append(o)
      self._object_count += 1
      parent = self._parent
      while parent is not None:
        parent._object_count += 1
        parent = parent._parent
      if o.boundingbox is not None:
        o.boundingbox.set_tree_node(self)
    else:
      trap = self._object_count
      self._add_to_subnode(o, supress_split)
      assert (trap + 1 == self._object_count, ("before:", trap, " after:", self._object_count))
  
  def extend(self, seq):
    for o in seq:
      self.add(o)
  
  def remove(self, o, supress_merge=False):
    # print "remove", o
    if o in self._objects:
      if self._iterators > 0:
        self._waiting_for_remove.append(o)
        self._has_objects_to_remove = True
        return
      self._objects.remove(o)
      self._object_count -= 1
      parent = self._parent
      while parent is not None:
        parent._object_count -= 1
        parent = parent._parent
    else:
      try:
        self._find_subnode_for_object(o).remove(o, supress_merge)
      except AttributeError:
        # sometimes we end up here, even though o lies perfectly within
        # self._dimensions. as a workaround, for now i'm assuming that this
        # only happens when we try to remove an object multiple times, and
        # thus do nothing about this situation. however, there must be a 
        # bug somewhere, FIXME!
        pass
    if not supress_merge:
      self._merge_if_necessary()
  
  def _merge_if_necessary(self):
    if (self._split_direction is not None
        ) and (len(self) <= self.MERGE_THRESH):
      self._merge()
  
  def notify_moved(self, gameobject, boundingbox):
    # first of all, a huge problem: 'middle' nodes don't have bounding
    # boxes yet! this has to be added. or maybe we don't add this and merge
    # _objects and _middle_subnode together. (FIXME!) fortunately, we can make
    # two guarantees about 'middle' nodes: there is a parent, and the parent
    # is not a 'middle' node. therefore, for now, this workaround:
    if self._dimensions is None:
      if (gameobject.collision_group is None):
        return # nothing to do in this case!
      # as we don't have dimensions available, we can't check whether this
      # node is still the correct node for gameobject, therefore we always
      # reinsert it. this is quite stupid, as the object might well end up
      # in this node again!
      self.remove(gameobject)
      try:
        self._parent._reinsert(gameobject, boundingbox)
      except AttributeError:
        print self
        print gameobject, boundingbox
        raise
      #self._merge_if_necessary() # FIXME: check how this ended up here! is it needed? is it allowed?
      return
    # here we're assuming that all we have to do is check whether gameobject
    # has (fully or partly) moved outside the bounds of this node,
    # and, if yes, hand it over to the parent node. what we _don't_ do
    # is check whether the object should now be moved into a sub-node.
    elif self._dimensions.contains(boundingbox):
      return
    if self._parent is None:
      # for now we're ignoring that case, but eventually we'll have to
      # throw an exception or somenthing (FIXME!)
      # no, wait, let's do a little bit more than just return. let's see whether
      # gameobject's boundingbox at least still intersects this node:
      if self._dimensions.intersects(boundingbox):
        # yes! there still is hope.
        return
      else:
        # no? well, in that case, let's give up on that object, let's try
        # to kill it:
        gameobject.die()
        return
    self.remove(gameobject)
    self._parent._reinsert(gameobject, boundingbox)
    # self._merge_if_necessary() # FIXME: same as above
    # FIXME: when you remove the long explanatory comments from the above,
    # it becomes obvious that it could be written much simpler. however,
    # before i'll do that, i'll have to check off the FIXMEs above.
    #
  
  def _reinsert(self, gameobject, boundingbox):
    # print "_reinsert", gameobject, boundingbox
    if self._dimensions.contains(boundingbox):
      self.add(gameobject, True)
    else:
      try:
        self._parent._reinsert(gameobject, boundingbox)
      except AttributeError:
        # this node doesn't encompass gameobject, but it doesn't have a
        # parent node either! eventually this condition will have to raise an
        # exception, but for now (FIXME!) we'll just try the following:
        # self.add(gameobject)
        # actually, no, adding was a bad idea, this just made us leak
        # objects out of the level's boundaries. well, OK, sometimes
        # it is safe. let's say when the bounds at least still intersect,
        # we'll add the object back in for now:
        if self._dimensions.intersects(boundingbox):
          self.add(gameobject, True)
        else:
          # but if not, we kill the object and throw it away. well, except
          # if it's a Player object, then this won't work ... damn, this is
          # ugly. as i said, this condition should actually be an exception,
          # and it will be an exception as soon as we have collision handling
          # that actually works.
          if isinstance(gameobject, Player):
            self.add(gameobject, True)
          else:
            gameobject.die()
  
  def _split(self):
    # print "_split"
    if self._dimensions.width > self._dimensions.height:
      self._split_direction = self.LEFT_RIGHT
      left_width = int(math.ceil(self._dimensions.width / 2.0))
      right_width = self._dimensions.width - left_width
      self._near_subnode = TritreeObjectCollection(Boundingbox(
          self._dimensions.bottom_left, (left_width, self._dimensions.height)),
          self._collision_relations, parent=self)
      self._middle_subnode = TritreeObjectCollection(None,
          self._collision_relations, parent=self)
      self._far_subnode = TritreeObjectCollection(Boundingbox(
          (self._dimensions.left + left_width, self._dimensions.bottom),
          (left_width, self._dimensions.height)), self._collision_relations,
          parent=self)
      for o in self._objects:
        self._add_to_subnode(o)
    else:
      self._split_direction = self.BOTTOM_TOP
      bottom_height = int(math.ceil(self._dimensions.height / 2.0))
      top_height = self._dimensions.height - bottom_height
      self._near_subnode = TritreeObjectCollection(Boundingbox(
          self._dimensions.bottom_left, (self._dimensions.width, bottom_height)),
          self._collision_relations, parent=self)
      self._middle_subnode = TritreeObjectCollection(None, self._collision_relations,
          parent=self)
      self._far_subnode = TritreeObjectCollection(Boundingbox(
          (self._dimensions.left, self._dimensions.bottom + bottom_height),
          (self._dimensions.width, top_height)), self._collision_relations,
          parent=self)
      for o in self._objects:
        self._add_to_subnode(o)
    h = len(self._objects)
    self._objects = []
    self._object_count -= h
    parent = self._parent
    while parent is not None:
      parent._object_count -= h
      parent = parent._parent
  
  def _merge(self):
    # print "_merge"
    h = self._object_count
    self._objects.extend(self._near_subnode._get_all_objects())
    self._objects.extend(self._middle_subnode._get_all_objects())
    self._objects.extend(self._far_subnode._get_all_objects())
    self._split_direction = None
    self._near_subnode._parent = None
    self._middle_subnode._parent = None
    self._far_subnode._parent = None
    self._near_subnode = None
    self._middle_subnode = None
    self._far_subnode = None
    self._object_count = h
    for gameobject in self._objects:
      gameobject.boundingbox.set_tree_node(self)
    
  
  def _add_to_subnode(self, o, supress_split=False):
    # print "_add_to_subnode", o
    #if (o.collision_group == 'bullets'
    #    ) or (o.collision_group == 'debris'):
    #  self._middle_subnode.add(o) # magic
    self._find_subnode_for_object(o).add(o, supress_split)
  
  def _find_subnode_for_object(self, o):
    # print "_find_subnode_for_object", o
    if self._split_direction == self.LEFT_RIGHT:
      bounds = o.boundingbox
      if bounds.left < self._dimensions.center_x:
        if bounds.right <= self._dimensions.center_x:
          return self._near_subnode
        else:
          return self._middle_subnode
      else:
        return self._far_subnode
    else:
      bounds = o.boundingbox
      if bounds.bottom < self._dimensions.center_y:
        if bounds.top <= self._dimensions.center_y:
          return self._near_subnode
        else:
          return self._middle_subnode
      else:
        return self._far_subnode
  
  def __len__(self):
    #retVal = len(self._objects)
    #if self._split_direction is not None:
    #  retVal += len(self._near_subnode) + len(self._middle_subnode) \
    #      + len(self._far_subnode)
    #return retVal
    #assert retVal == self._object_count, (retVal, self._object_count)
    return self._object_count
  
  def __iter__(self):
    #return self._get_all_objects().__iter__()
    """self._iterators += 1
    for o in self._objects:
      yield o
    if self._split_direction is not None:
      for o in self._near_subnode:
        yield o
      for o in self._middle_subnode:
        yield o
      for o in self._far_subnode:
        yield o
    self._iterators -= 1
    if self._iterators == 0:
      while self._has_objects_to_add:
        try:
          self.add(self._waiting_for_add.pop())
        except IndexError:
          # list is empty, exit loop:
          self._has_objects_to_add = False
      while self._has_objects_to_remove:
        try:
          self.remove(self._waiting_for_remove.pop())
        except IndexError:
          # list is empty, exit loop:
          self._has_objects_to_remove = False"""
    return TritreeObjectCollectionIterator(self)
  
  def get_all(self, cls):
    ret_val = []
    for obj in self:
      if isinstance(obj, cls):
        ret_val.append(obj)
    return ret_val
  
  def _get_all_objects(self):
    # print "_get_all_objects"
    # return a copy of the list, so self can be modified during iteration!
    all_objects = list(self._objects)
    if self._split_direction is not None:
      all_objects.extend(self._near_subnode._get_all_objects())
      all_objects.extend(self._middle_subnode._get_all_objects())
      all_objects.extend(self._far_subnode._get_all_objects())
    return all_objects
  
  def _get_collisions(self, list_from_parent=None):
    # print "_get_collisions"
    if list_from_parent is None:
      collisions = []
    else:
      collisions = list_from_parent
    c = list(self._objects)
    if self._split_direction is not None:
      c.extend(self._middle_subnode._get_all_objects())
    self._get_collisions_for_sequence(c, collisions)
    if self._split_direction is not None:
      for o in c:
        self._collide_object_with_subnodes(o, collisions, False)
      self._near_subnode._get_collisions(collisions)
      self._far_subnode._get_collisions(collisions)
    if list_from_parent is None:
      return collisions.__iter__()
  
  def _get_collisions_for_sequence(self, seq, collisions):
    # print "_get_collisions_for_sequence"
    for i in xrange(len(seq)):
      for j in xrange(i + 1, len(seq)):
        try:
          collisions.extend(self._evaluate_collison(seq[i], seq[j]))
        except TypeError:
          pass # don't extend when _evaluate_collison returned None
  
  def _collide_object_with_subnodes(self, o, collisions, include_middle=True):
    # print "_collide_object_with_subnodes"
    if o.is_dead:
      return
    if o.boundingbox.intersects(self._near_subnode._dimensions):
      self._near_subnode._collide_object_with_node(o, collisions)
    if o.boundingbox.intersects(self._far_subnode._dimensions):
      self._far_subnode._collide_object_with_node(o, collisions)
    if include_middle:
      self._middle_subnode._collide_object_with_node(o, collisions)
  
  def _collide_object_with_node(self, o1, collisions):
    # print "_collide_object_with_node"
    for o2 in self._objects:
      try:
        collisions.extend(self._evaluate_collison(o1, o2))
      except TypeError:
        pass # don't extend when _evaluate_collison returned None
    if self._split_direction is not None:
      for o2 in self._middle_subnode._get_all_objects():
        try:
          collisions.extend(self._evaluate_collison(o1, o2))
        except TypeError:
          pass # don't extend when _evaluate_collison returned None
      self._collide_object_with_subnodes(o1, collisions)
  
  def _evaluate_collison(self, o1, o2):
    result = []
    if (o1.collision_group in self._collision_relations) and (
        o2.collision_group in self._collision_relations[o1.collision_group]):
      if o1.boundingbox.intersects(o2.boundingbox) and (o1 != o2
          ) and (not o1.is_dead) and (not o2.is_dead):
        if (o2.collision_group in self._collision_relations) and (
            o1.collision_group in self._collision_relations[o2.collision_group]):
          result = self._evaluate_collision_details(o1, o2, plus_reverse=True)
        else:
          result = self._evaluate_collision_details(o1, o2)
    elif (o2.collision_group in self._collision_relations) and (
        o1.collision_group in self._collision_relations[o2.collision_group]):
      if o1.boundingbox.intersects(o2.boundingbox) and (o1 != o2
          ) and (not o1.is_dead) and (not o2.is_dead):
        result = self._evaluate_collision_details(o2, o1)
    if len(result) > 0:
      return result
    else:
      return None
  
  def _evaluate_collision_details(self, collider, target, plus_reverse=False):
    result = []
    if collider.container:
      for part in collider.get_parts():
        try:
          result.extend(self._evaluate_collison(part, target))
        except TypeError:
          pass # _evaluate_collison may return None, in this case there simply is nothing to extend
      return result
    if target.container:
      parts = []
      for part in target.get_parts():
        if collider.boundingbox.intersects(part.boundingbox) \
            and (collider != part) and (not part.is_dead):
          parts.append(part)
      if len(parts) > 0:
        result.append((collider, target, parts))
    else:
      result.append((collider, target, None))
    if plus_reverse:
      result.extend(_evaluate_collision_details(target, collider))
    return result
      
  
  collisions = property(_get_collisions)
  
  def __str__(self, indent=0):
    ins = "  " * indent
    if self._dimensions is None:
      bs = "no bounds"
    else:
      bs = str(self._dimensions)
    ls = str(len(self))
    s = ins + "<ObjectCollection (%s) containing %s objects" % (bs, ls)
    if len(self) > 0:
      s += ":\n"
    else:
      s += ">\n"
      return s
    s += ins + "- in this node:\n"
    for o in self._objects:
      s += ins + "  " + str(o) + " with " + str(o.boundingbox) + "\n"
    if self._split_direction is not None:
      if self._split_direction == self.LEFT_RIGHT:
        s += ins + "LEFT_RIGHT split\n"
      else:
        s += ins + "BOTTOM_TOP split\n"
      s += ins + "- in near subnode:\n"
      s += self._near_subnode.__str__(indent + 2)
      s += ins + "- in middle subnode:\n"
      s += self._middle_subnode.__str__(indent + 2)
      s += ins + "- in far subnode:\n"
      s += self._far_subnode.__str__(indent + 2)
    s += ins + ">\n"
    return s

class TritreeObjectCollectionIterator(object):
  def __init__(self, collection):
    self._index = 0
    self._last_index = -1
    self._next_collections = [collection]
    self._unhandled_collections_count = 1
    self._current_collection = None
    self._done_collections = []
  
  def __iter__(self):
    return self
  
  def next(self):
    if self._index > self._last_index:
      self._last_index = -1
      while self._last_index < 0:
        if self._current_collection is not None:
          self._done_collections.append(self._current_collection)
        if self._unhandled_collections_count > 0:
          self._current_collection = self._next_collections.pop()
          self._unhandled_collections_count -= 1
        else:
          for c in self._done_collections:
            c._iterators -= 1
            if c._iterators == 0:
              while c._has_objects_to_add:
                try:
                  c.add(c._waiting_for_add.pop(), True)
                except IndexError:
                  c._has_objects_to_add = False
              while c._has_objects_to_remove:
                try:
                  c.remove(c._waiting_for_remove.pop(), True)
                except IndexError:
                  c._has_objects_to_remove = False
          raise StopIteration
        self._current_collection._iterators += 1
        if self._current_collection._split_direction is not None:
          self._next_collections.append(self._current_collection._near_subnode)
          self._next_collections.append(self._current_collection._middle_subnode)
          self._next_collections.append(self._current_collection._far_subnode)
          self._unhandled_collections_count += 3
        self._last_index = len(self._current_collection._objects) - 1
      self._index = 0
    try:
      retVal = self._current_collection._objects[self._index]
    except IndexError:
      print self._current_collection._objects
      print self._index
      raise
    self._index += 1
    return retVal


if __name__ == '__main__':
  import unittest
  from puit.objects.gameobject import Gameobject
  
  class TestObjectCollection(unittest.TestCase):
    def setUp(self):
      ObjectCollection.SPLIT_THRESH = 6
      ObjectCollection.MERGE_THRESH = 3
      self.c1 = ObjectCollection(
          Boundingbox(bottom_left=(0, 0), size=(200, 100)))
      self.c2 = ObjectCollection(
          Boundingbox(bottom_left=(0, 0), size=(200, 60)))
      for x in (0, 90, 180):
        for y in (10, 40):
          o = Gameobject((x, y), 20, 10)
          self.c2.add(o)
    
    def test_split_merge(self):
      self.assertEqual(self.c1._split_direction, None)
      for i in range(5):
        o = Gameobject((i * 10, 0), 10, 10)
        self.c1.add(o)
      self.assertEqual(self.c1._split_direction, None)
      o = Gameobject((60, 0), 10, 10)
      self.c1.add(o)
      self.assertEqual(self.c1._split_direction, ObjectCollection.LEFT_RIGHT)
      all = self.c1._get_all_objects()
      for o in all[:3]:
        self.c1.remove(o)
      self.assertEqual(self.c1._split_direction, None)
    
    def test_subnode_sort(self):
      self.assertEqual(len(self.c2._near_subnode), 2)
      self.assertEqual(len(self.c2._far_subnode), 2)
      self.assertEqual(len(self.c2._middle_subnode), 2)
    
    def test_subsplit_intersection(self):
      for x in (30, 40):
        for y in (10, 40):
          o = Gameobject((x, y), 20, 10)
          self.c2.add(o)
      self.assertEqual(len(self.c2.collisions), 4)
      for y in (10, 40):
        o = Gameobject((80, y), 20, 10)
        self.c2.add(o)
      self.assertEqual(len(self.c2.collisions), 8)
      o = Gameobject((40, 40), 150, 10)
      self.c2.add(o)
      self.assertEqual(len(self.c2.collisions), 18)
      
  
  test_suite = unittest.TestLoader().loadTestsFromTestCase(TestObjectCollection)
  print "testing class ObjectCollection ...\n"
  unittest.TextTestRunner(verbosity=2).run(test_suite)