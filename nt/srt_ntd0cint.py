#!python
#
#  Python file to mung the include paths passed to d0cint for lame
#  systems which don't support symbolic links.
#
#  See the restriction in the srt_ntbashutil.py file for further warnings.
#
#  Created May 1998 sss
#

import sys
import os
import string
import tempfile

import srt_options_line
import srt_ntbashutil


#
# Main program to translate include paths.
#

def main():

	#
	# Setup and make sure command line stuff is there and cool.
	#

	cmd_options = srt_options_line.options_line (sys.argv[1:])

	if cmd_options.length() == 0:
		sys.stderr.write("Usage: " + sys.argv[0] + " <arguments>\n")
		return 1

	cmd_line = ""

	#
	# The local path cache variable
	#

	local_path = ""

	while cmd_options.has_more_options():
		option = cmd_options.get_next_option ("this should never fail!")
		if option[0] == "-":
			option = option[1:]
			#
			# I -- An include file
			#

			if option[0] == "I":
				raw_path = option[1:]
				if not srt_ntbashutil.is_absolute_path(raw_path):
					if local_path == "":
						local_path_h = os.popen("pwd", "r")
						buffer = local_path_h.readline()
						local_path = buffer[:-1]
						local_path_h.close()
					raw_path = local_path + "/" + raw_path
				translated_path = srt_ntbashutil.translate_path (raw_path)
				nt_path_list = srt_ntbashutil.resolve_bash_aliases (translated_path)
				for path in nt_path_list:
					c_path = srt_ntbashutil.compress_path(path)
					cmd_line = cmd_line + "-I" + c_path + " "

			else:
				cmd_line = cmd_line + "-" + option + " "
		else:
			if cmd_options.has_more_options():
				# print "option=", option
				# sys.stdout.flush()
				nt_path = srt_ntbashutil.translate_path (option)
				# print "nt_path=", nt_path
				# sys.stdout.flush()
				cmd_line = cmd_line + nt_path + " "
			else:
				cmd_line = cmd_line + option + " "

        cmd_line = string.translate (cmd_line, string.maketrans("\\", "/"))
	#print "d0cint " + cmd_line
	#sys.stdout.flush()
	cmd_filename = tempfile.mktemp()
	cmd_file_handle = open (cmd_filename, "w")
	#print cmd_line
	#xhandle = open ("/snyder/rel/test/xcmd", "w")
	#xhandle.write (cmd_line + "\n")
	#xhandle.close()
	cmd_file_handle.write (cmd_line + "\n")
	cmd_file_handle.close()
	cmd = "bash -c \"d0cint @" + cmd_filename + "\""
        cmd = string.translate (cmd, string.maketrans("\\", "/"))
	#print cmd
	#sys.stdout.flush()
	result = os.system(cmd)
	os.unlink (cmd_filename)

	return result

#
# Execute the routine and let the shell know what happened.
#
if __name__ == '__main__':
	result = main()
	sys.stdout.close()
	os._exit(result)
