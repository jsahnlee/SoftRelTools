# rules for compiling java

pkgdocdir=$(SRT_TOP)$(CURPKG)doc/

#rules
jall: jbin jdoc
jlib: $(libdir)$(JLIB)
jbin: jlib $(bindir)$(JBIN)
jdoc: $(pkgdocdir)AllNames.html

#library
$(libdir)$(JLIB): $(JARFILES)
        @echo "<**creating library**> " $(JLIB)
        cd $(workdir); $(JAR) $(JARFLAGS) $(JARBASES)
#binary
$(bindir)$(JBIN): $(patsubst %.class, %.java, $(JBIN))
        @echo "<**compiling**> " $<
        $(JAVAC) $(JAVACFLAGS)  -classpath $(LIBCLASSPATH) -d $(bindir) $<

#java compilation rule
$(workdir)%.class: %.java
        @echo "<**compiling**> " $<
        $(JAVAC) $(JAVACFLAGS)  -classpath $(COMPCLASSPATH) -d $(workdir) $<

#javadoc
$(pkgdocdir)AllNames.html: $(JARFILES)
        @echo "<**creating html doc**> " $(pkgdocdir)
        $(JAVADOC) $(JAVADOCFLAGS) -classpath $(COMPCLASSPATH) $(PACKAGES)

#clean up rule
jclean:
        -rm $(libdir)$(JLIB)
        -rm $(JARFILES)
        -rmdir $(PACKDIRS)
        -rm $(pkgdocdir)*.html
		
# Add the rules to normal build cycle
bin: jbin
lib: jbin
clean: jclean

# Include the environment variables for java

include SoftRelTools/arch_spec_java.mk
