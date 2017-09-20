#!/usr/bin/env python
import os
import re
from optparse import OptionParser

parser = OptionParser()
parser.add_option('--depth', action='store', dest='depth', type='int', default=-1)
parser.add_option('--regex', action='store', dest='regex', type='string', default='.*')
parser.add_option('-d', action='store_true', dest='dirs_only', default=False)
parser.add_option('-f', action='store_true', dest='files_only', default=False)
(options, args) = parser.parse_args()

show_dirs = True
show_files = True
if not options.dirs_only and options.files_only:
  show_dirs = False
if not options.files_only and options.dirs_only:
  show_files = False

def walkdepth(path, depth=1):
  regex = re.compile(options.regex)
  path = path.rstrip(os.path.sep)
  assert os.path.isdir(path), "error: " + path + " is not a directory"
  sepcount = path.count(os.path.sep)
  if show_dirs:
    print(path)
  for root, dirs, files in os.walk(path):
    count = root.count(os.path.sep)
    if depth >= 0 and count >= sepcount + depth:
      dirs[:] = []
      break
    if show_dirs:
      for d in dirs:
        dname = os.path.join(root, d)
        if regex.match(dname):
          print(dname)
    if show_files:
      for f in files:
        fname = os.path.join(root, f)
        if regex.match(fname):
          print(fname)

for arg in args:
  walkdepth(arg, options.depth)
