#
# srt_ntide_dummy_files.py
#
#  This guy will keep track of dummy files created by the ntide_builder.
# One function, in particular, will delete all the files that are listed
# in this temp file, thus cleaning up.
#
#  The package uses the env symbol IDE_TEMP_FILE_LIST to store the filename
# where this information can be written. If this isn't defined, nothing is
# done (and no error message is printed).
#
import os
import srt_ntbashutil


def record_temp_file (file):
	if os.environ.has_key("IDE_TEMP_FILE_LIST"):
		fname = os.environ["IDE_TEMP_FILE_LIST"]
		fname = srt_ntbashutil.translate_path(fname)
		temp_file = open (fname, "a+")
		temp_file.write (file + "\n")
		temp_file.close()

def delete_temp_files ():
	if os.environ.has_key("IDE_TEMP_FILE_LIST"):
		fname = os.environ["IDE_TEMP_FILE_LIST"]
		fname = srt_ntbashutil.translate_path(fname)
		if os.path.exists(fname):
			temp_file = open (fname)
			line = " "
			while line != "":
				line = temp_file.readline()
				fname = line[:-1]
				if os.path.exists(fname):
					os.unlink (fname)
			temp_file.close()
