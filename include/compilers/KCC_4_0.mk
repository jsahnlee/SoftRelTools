include SoftRelTools/compilers/KCC.mk

override DEFINES += -DEXTENSION_LONG_LONG_STREAM_OPERATOR

# Prelinker symlink, per Arch Robison 20010213

override CXXFLAGS += --COMPP_pl $(tmpdir)KAI_PRELINK_TMP


ifeq ($(SRT_ARCH),Linux2)
    override DEFINES += -DLINUX_2_0_KCC_4_0
endif
ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
    override DEFINES += -DIRIX_6_2_KCC_4_0
endif

ifeq ($(SRT_ARCH),Linux2)
    override CXXFLAGS:=$(filter-out --strict,$(CXXFLAGS)) --linux_strict
endif

