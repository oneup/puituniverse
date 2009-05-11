#! /usr/bin/env python
from pyglet import options as pyg_options
pyg_options['debug_gl'] = False

from puit.gamemaster import Gamemaster
import puit

#import psyco
#psyco.full()

def profile(what):
  import profile
  # setting profile.Profile.bias improves the performance measurement,
  # but you have to determine the correct value for your specific machine
  # first.
  # profile.Profile.bias = 0.0000106
  profile.run(what, 'profile')
  import pstats
  profile = pstats.Stats('profile')
  profile.strip_dirs().sort_stats('cumulative').print_stats(32)
  profile.strip_dirs().sort_stats('time').print_stats(20)

def main(start_state=None):
  puit.gamemaster = Gamemaster(start_state)
  puit.gamemaster.start()

if __name__ == '__main__':
  import getopt, sys
  options, args = getopt.getopt(sys.argv[1:], 'pt:', ['profile', 'test='])
  do_profile = False
  test = None
  for opt, arg in options:
    if opt in ('-p', '--profile'):
      do_profile = True
    elif opt in ('-t', '--test'):
      test = arg
  if do_profile:
    if test is None:
      profile('main()')
    else:
      profile('main(start_state="' + test + '")')
  else:
    main(start_state=test)