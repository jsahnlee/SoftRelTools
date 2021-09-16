# arch_spec_qq.mk
#
# Original version:
# Jan 24 1998 P.Murat: Initial Version


extpkg:=qq
QQ_DIR_DEFAULT := /usr/local
ifndef QQ_DIR
    arch_spec_warning:=\
    "Using default value QQ_DIR = $(QQ_DIR_DEFAULT)"
    QQ_DIR := $(QQ_DIR_DEFAULT)
endif
ifndef QQ_INC 
    QQ_INC = $(QQ_DIR)/lib
endif
ifndef QQ_LIB
    QQ_LIB = $(QQ_DIR)/lib
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(QQ_INC)
override LDFLAGS   += -L$(QQ_LIB)
override LOADLIBES += -lqq
