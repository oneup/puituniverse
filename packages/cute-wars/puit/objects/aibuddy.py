from puit.objects.aiplayer import AiPlayer

class AiBuddy(AiPlayer):
  """Computer controlled player character that can play instead of a human.
  
  For now I've subclassed AiPlayer becaue an AiBuddy is mostly the same.
  The difference is that an AiBuddy is an ersatz human, which the game uses
  to fill vacant slots in game modes made for multiple human players; an
  AiPlayer, on the other hand, is treated exactly like a human player by the
  rest of the game and used to make the game play itself in test runs.
  """
  def __init__(self, *args, **kwds):
    super(AiBuddy, self).__init__(*args, **kwds)
    self.local_human = False