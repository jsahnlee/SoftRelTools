CPP:= CC
CXX:= CC
CC:= CC
AR:= CC
SHAREDAR:=$(AR)
PICFLAG:=-pic
#ARFLAGS += -xar
AROFLAG := -xar -o

# Inline deps are turned off because I don't know how to do them with
# Sun CC. This should probably be changed.
INLINE_DEP_CAPABLE=
INLINE_DEP =
STANDALONE_DEP= -M $< > $(dir $@)/$(basename $(notdir $<)).d
CSTANDALONE_DEP=$(STANDALONE_DEP)
