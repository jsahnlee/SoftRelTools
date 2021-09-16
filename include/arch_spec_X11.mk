# arch_spec_X11.mk
#
# X11_INC and X11_LIB are environment variables
#   containing (or optionally loaded with) the
#   location of the various files on the local machine.
#
# Original version:
#   First version         Bob Jacobsen   Dec 94
#   Updated (for CMS)                     Lucas Taylor   30/11/1998
#   Put X11 after Xpm in link list        Pasha Murat    4-Feb-1999

ifndef ARCH_SPEC_X11
ARCH_SPEC_X11 = ONCE

X11_INC_DEFAULT   = /usr/include/X11
X11_LIB_DEFAULT   = /usr/lib/X11

ifneq (,$(findstring SunOS5,$(BFARCH)))
   X11_INC_DEFAULT   = /usr/openwin/include 
   X11_LIB_DEFAULT   = /usr/openwin/lib    
else
ifneq (,$(findstring SunOS4,$(BFARCH)))
   X11_INC_DEFAULT    = /usr/local/X11R5/include
   X11_LIB_DEFAULT    = /usr/local/lib/X11R5
else
ifneq (,$(findstring Linux2,$(BFARCH)))
   X11_INC_DEFAULT    = /usr/X11R6/include
   X11_LIB_DEFAULT    = /usr/X11R6/lib
else
ifneq (,$(findstring HP-UX,$(BFARCH)))
   X11_INC_DEFAULT    = /usr/include/X11R5
   X11_LIB_DEFAULT    = /usr/lib/X11R5
endif
endif
endif
endif

ifndef X11_INC
    X11_INC = $(X11_INC_DEFAULT)
endif
ifndef X11_LIB
    X11_LIB = $(X11_LIB_DEFAULT)
endif

override CPPFLAGS  += -I$(X11_INC) 
override LDFLAGS   += -L$(X11_LIB)

X11_LOADLIBES := -lXt -lXpm -lX11

ifneq (,$(findstring SunOS5,$(BFARCH)))
   X11_LOADLIBES :=  -lXt -lX11 -lXi -lXext -lsocket 
endif

ifneq (,$(findstring SunOS4,$(BFARCH)))
   X11_LOADLIBES :=  -lXt -lX11 -lXi -lXext -lsocket 
endif

ifneq (,$(findstring Linux2,$(BFARCH)))
   X11_LOADLIBES :=  -lXp -lXt -lSM -lICE -lXpm -lX11 -lXi -lXext
endif

ifneq (,$(findstring HP-UX,$(BFARCH)))
   X11_LOADLIBES :=  -lXt -lX11 -lXi -lXext
endif

ifneq (,$(findstring AIX,$(BFARCH)))
   X11_LOADLIBES :=  -lXt -lX11 -lPW
endif

ifneq (,$(findstring IRIX6,$(BFARCH)))
   X11_LOADLIBES := -lXt -lXpm -lX11 -lXext -lSM -lICE -lm 
endif

ifneq (,$(findstring IRIX5,$(BFARCH)))
   X11_LOADLIBES := -lXt -lXpm -lX11 -lXext -lSM -lICE -lm 
endif

ifneq (,$(findstring OSF,$(BFARCH)))
   X11_LOADLIBES := -lXt -lX11 -lm
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(X11_INC) 
override LDFLAGS   += -L$(X11_LIB)
override LOADLIBES += $(X11_LOADLIBES)

endif
