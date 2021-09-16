# arch_spec_STL.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use STL package.
#
# For the moment, this is only set to use the current default
#  STL implementation:  RogueWave on AIX, Sun and HP; native on OSF1
#   On AIX, using RW 7.0.3; HP and Sun need 7.0.7; using the 
#    RogueWave STL include files requires loading a RW "std" lib.
#    STLBASE is defined to point at the RogueWave base directory.
# 
# The preprocessor macro STLTYPE is also defined here, which determines which
#  type of forward declaration files are used (fwd_vector.h, etc.).
#
# Philippe Canal 9 September 1998  

extpkg := STL
ifneq (,$(findstring NT4,$(BFARCH)))
  STLFLAG = -DSTLTYPE=1
else
ifneq (,$(findstring KCC,$(BFARCH)))
  STLFLAG = -DSTLTYPE=1
else
ifneq (,$(findstring SunOS5,$(BFARCH)))
  STLFLAG = -DSTLTYPE=3
else
ifneq (,$(findstring SunOS4,$(BFARCH)))
  STLFLAG = -DSTLTYPE=3
else
ifneq (,$(findstring AIX,$(BFARCH)))
  STLFLAG = -DSTLTYPE=4
else
ifneq (,$(findstring HP-UX,$(BFARCH)))
  STLFLAG = -DSTLTYPE=1 
else
ifneq (,$(findstring Linux,$(BFARCH)))
  STLFLAG = -DSTLTYPE=1
else
ifneq (,$(findstring OSF,$(BFARCH)))
  STLFLAG = -DSTLTYPE=1
else
ifneq (,$(findstring IRIX5,$(BFARCH)))
  STLFLAG = -DSTLTYPE=1
else
ifneq (,$(findstring IRIX6,$(BFARCH)))
  STLFLAG = -DSTLTYPE=1
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS += $(STLFLAG)
