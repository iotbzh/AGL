#!/usr/bin/python
# -*- coding: utf8 -*-

from __future__ import print_function

import os
import string
import subprocess
import sys
from optparse import OptionParser

# ----------------------------------------------------------------------------
# System functions

# Launch external process and return an array of (stdout, stderr)
def run(command, quiet=True):
	#print ("run = ", command, "from", os.getcwd())
	p = subprocess.Popen(command,
		stdout=subprocess.PIPE,
		stderr=subprocess.STDOUT)

	out = ''
	while True:
		l = p.stdout.readline()
		if l == '' and p.poll() != None:
			break

		out += l

		if not quiet:
			sys.stdout.write(l)
			sys.stdout.flush()

	p.communicate()

	# split lines
	res = out.split('\n')

	# Drop last line if len is 0:
	if len(res[len(res)-1]) == 0:
		return res[:-1]

	return res

# Return full path of a binary (equivalent to "which" command line tool)
def which(program):
    import os
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

# ----------------------------------------------------------------------------
# Git related stuff

# Return True if git submodule in "repo" directory is clean
def git_submod_status (repo):
	cwd = os.getcwd()
	os.chdir(os.path.join(cwd, repo))
	res = run([which("git"), "status", "-s" ])
	os.chdir(cwd)

	return len(res) == 0

# Checkout git submodule in "repo" directory to revision "rev".
def git_submod_checkout (repo, rev, localbranch):
	cwd = os.getcwd()
	os.chdir(os.path.join(cwd, repo))
	res = run([which("git"), "checkout", "-B", localbranch, rev ])
	os.chdir(cwd)

# ----------------------------------------------------------------------------

# Short help message
def print_usage():
	print ("""Usage:
   yocto-switch <base-file>

where base-file is a list of repos with related SHA-1 to checkout""")

# Script entry point
if __name__ == "__main__":
	stopLater = False

	opts = OptionParser()
	(options, args) = opts.parse_args()

	# Check args
	if len(args) != 1:
		print ("Invalid args\n")
		print_usage()
		sys.exit (1)

	basefile = args[0]
	if not os.path.exists(basefile):
		print ("Invalid arg: %s not found" % basefile)
		sys.exit (1)

	# Parse the "base-xxx" file
	with open(basefile) as fd:

		# Catch all info from basefile
		submod = []
		for line in fd:
			tokens = line.rstrip(" \t\n").split ()
			mod = {"dir": tokens[0], "rev": tokens[1]}
			submod.append(mod)

	# Check all git submodules are clean
	for mod in submod:
		if not git_submod_status(mod["dir"]):
			print ("Error: '%s' must be clean" % mod["dir"])
			print ("   can't switch to %s" % mod["rev"])
			stopLater = True
	if stopLater:
		sys.exit(1)

	# Let's checkout all submodule to basefile revision
	print ("Align all submodules to SHA-1 in %s file" % basefile)
	for mod in submod:
		print ("switch %s to %s revision" %
				(mod["dir"], mod["rev"][:7]))
		# NOTE: branch name in submodules are set to 'basefile'
		git_submod_checkout(mod["dir"], mod["rev"], basefile)

