#!python
#
#  This guy will drive the test for the template module.
#

def do_test():
	import srt_file_template

	mydict = {}

	#
	#  Setup everything for the simple subsitution tests
	#

	mydict["one_line"] = "This is just a line"
	mydict["second_line"] = "thingy"
	mydict["first_word"] = "two"
	mydict["second_word"] = "on it"
	mydict["in_string"] = "with quoted text"
	mydict["first_on_line"] = "This is the first word"
	mydict["last_on_line"] = "this is the last word."

	#
	# For conditional subsitution
	#
	mydict["do_this"] = 1
	mydict["in_sub"] = "subed thing"

	#
	# Great, now run it
	#

	output = open ("srt_file_template_test.txt", "w")
	srt_file_template.file_template (output, "srt_file_template_test.template", mydict)
	output.close()

#
# Execute the routine and let the shell know what happened.
#
if __name__ == '__main__':
	do_test()
