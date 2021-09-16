include SoftRelTools/platforms/IRIX6.mk

override DEFINES := $(filter-out -DIRIX6_2,$(DEFINES)) -DIRIX6_5
