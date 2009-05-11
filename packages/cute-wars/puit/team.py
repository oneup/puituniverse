
class Team(object):
  """
  Teams are groups of Characters with the same color
  """

  def __init__(self, colours={}):
    self.colours = colours
    if (0, 0, 0) in colours:
      self.main_colour = colours[(0, 0, 0)]
      self.main_colour_gl = tuple([c / 255.0 for c in self.main_colour])

  # TODO: team should contain a list of (alive) characters
