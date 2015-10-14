#!/usr/bin/env python

import sys
from subprocess import Popen,PIPE

# Gather the version of python on this box
out,err = Popen(['python', '--version'], stderr=PIPE).communicate()
print("pythonversion=%s" % err.replace('Python ', ''))

# Find the site-packages for the current python install
for dir in sys.path:
    if dir.endswith('site-packages'):
        print("pythonsitedir=%s" % dir)
        sys.exit(0)