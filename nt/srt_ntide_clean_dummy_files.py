#
# srt_ntide_clean_dummy_files.py
#
#  Simple driver to clean out the dummy files created by a ntide_build
# command
#

import srt_ntide_dummy_files
import sys
import os

if __name__ == '__main__':
	srt_ntide_dummy_files.delete_temp_files()
	sys.stdout.close()
	os._exit(0)
