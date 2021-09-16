#
# srt_ntide_dummy_files_t.py
#
#  Test driver for the srt_ntide_dummy_files guy.
#

import os
import srt_ntide_dummy_files

os.environ["IDE_TEMP_FILE_LIST"] = "dummy_bad.txt"

temp_file = open ("junk1.txt", "w")
temp_file.close()
srt_ntide_dummy_files.record_temp_file ("junk1.txt")

temp_file = open ("junk2.txt", "w")
temp_file.close()
srt_ntide_dummy_files.record_temp_file ("junk2.txt")

print "Checking to see jun1 and 2 exist"
if os.path.exists ("junk1.txt"):
	print "junk1 exists"
else:
	print "no! junk1 does not exist!"
if os.path.exists ("junk2.txt"):
	print "junk1 exists"
else:
	print "no! junk2 does not exist!"

print "Going to delete them now..."
srt_ntide_dummy_files.delete_temp_files()

print "Ok, checking to see fi they are gone:"
if os.path.exists ("junk1.txt"):
	print "no! junk1 exists"
else:
	print "junk1 does not exist!"
if os.path.exists ("junk2.txt"):
	print "no! junk1 exists"
else:
	print "junk2 does not exist!"
