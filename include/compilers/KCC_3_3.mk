include SoftRelTools/compilers/KCC.mk

# Warning! Yes, this is KCC_3_3. Yes we define -Dblah_KCC_3_2.
# Go figure.
#
ifeq ($(SRT_ARCH),Linux2)
    override DEFINES += -DLINUX_2_0_KCC_3_2
endif
ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
    override DEFINES += -DIRIX_6_2_KCC_3_2
endif

override DEFECTS += -DDEFECT_NO_STDC_NAMESPACES
