#!/usr/bin/env python
import json
import os
import subprocess
import sys
from optparse import OptionParser

# This script runs pkg-config and returns the result.
# The result will be a gn scope.

parser = OptionParser()
parser.add_option('-p', action='store', dest='pkg_config', type='string', default='pkg-config')
parser.add_option('--static', action='store_true', dest='static')
parser.add_option('--cflags', action='store_true', dest='cflags')
parser.add_option('--libs', action='store_true', dest='libs')
parser.add_option('--lib-switch', action='store', dest='lib_switch', type='string', default='-l')
parser.add_option('--lib-dir-switch', action='store', dest='lib_dir_switch', type='string', default='-L')
parser.add_option('--variable', action='store', dest='variable', type='string', default=None)
(options, args) = parser.parse_args()

if options.variable:
  try:
    variable = subprocess.check_output([options.pkg_config,
                                        "--variable", options.variable] +
                                       args,
                                       env=os.environ)
    print(variable.strip().decode('utf-8'))
  except:
    print("Error running pkg-config.")
    sys.exit(1)
  sys.exit(0)

static = []
if options.static:
  static.append("--static")

if options.cflags:
  try:
    cflagsString = subprocess.check_output([options.pkg_config,
                                            "--cflags"] +
                                            static + args, env=os.environ)
    all_cflags = cflagsString.strip().decode('utf-8').split(' ')
  except:
    print("Error running pkg-config.")
    sys.exit(1)

if options.libs:
  try:
    ldflagsString = subprocess.check_output([options.pkg_config,
                                             "--libs"] +
                                            static + args, env=os.environ)
    all_ldflags = ldflagsString.strip().decode('utf-8').split(' ')
  except:
    print("Error running pkg-config.")
    sys.exit(1)

defines = []
includes = []
cflags = []
libs = []
lib_dirs = []
ldflags = []

if options.libs:
  lib_switch = options.lib_switch
  lib_switch_len = len(lib_switch)
  lib_dir_switch = options.lib_dir_switch
  lib_dir_switch_len = len(lib_dir_switch)
  for flag in all_ldflags[:]:
    if len(flag) == 0:
      continue;

    if flag[:lib_switch_len] == lib_switch:
      libs.append(flag[lib_switch_len:])
    elif flag[:lib_dir_switch_len] == lib_dir_switch:
      lib_dirs.append(flag[lib_dir_switch_len:])
    elif flag[1] == '/':
      libs.append(flag)
    else:
      ldflags.append(flag)

for flag in all_cflags[:]:
  if len(flag) == 0:
    continue;

  if flag[:2] == '-D':
    defines.append(flag[2:])
  elif flag[:2] == '-I':
    includes.append(flag[2:])
  else:
    cflags.append(flag)

# Output a GN scope. The JSON formatter prints GN compatible lists when
# everything is a list of strings.
print("defines = " + json.dumps(defines))
print("include_dirs = " + json.dumps(includes))
print("cflags = " + json.dumps(cflags))
print("libs = " + json.dumps(libs))
print("lib_dirs = " + json.dumps(lib_dirs))
print("ldflags = " + json.dumps(ldflags))
