# arch_spec_java.mk
#
extpkg := java
JAVA_DIR_DEFAULT:=/usr/local/java
ifndef JAVA_DIR
    arch_spec_warning:=\
    "Using default value JAVA_DIR = $(JAVA_DIR_DEFAULT)"
    JAVA_DIR = $(JAVA_DIR_DEFAULT)
endif


JAVAC=javac
JAVACFLAGS=-g 
JAR=jar
JARFLAGS=cf $(libdir)$(JLIB)
JAVADOC=javadoc
JAVADOCFLAGS=-author -d $(pkgdocdir)
COMPCLASSPATH=.:$(JAVA_DIR)/lib/classes.zip
LIBCLASSPATH=.:$(libdir)/$(JLIB):$(JAVA_DIR)/lib/classes.zip

include SoftRelTools/specialize_arch_spec.mk
