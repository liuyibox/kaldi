# OpenBLAS specific MinGW configuration

ifndef DOUBLE_PRECISION
$(error DOUBLE_PRECISION not defined.)
endif
ifndef OPENFSTINC
$(error OPENFSTINC not defined.)
endif
ifndef OPENFSTLIBS
$(error OPENFSTLIBS not defined.)
endif
ifndef OPENBLASINC
$(error OPENBLASINC not defined.)
endif
ifndef OPENBLASLIBS
$(error OPENBLASLIBS not defined.)
endif

CXXFLAGS = -std=c++11 -I.. -I$(OPENFSTINC) -O1 $(EXTRA_CXXFLAGS) \
           -Wall -Wno-sign-compare -Wno-unused-local-typedefs \
           -Wno-deprecated-declarations -Winit-self -Wno-mismatched-tags \
           -DKALDI_DOUBLEPRECISION=$(DOUBLE_PRECISION) \
           -DHAVE_CXXABI_H -DHAVE_OPENBLAS \
           -I$(OPENBLASINC) -ftree-vectorize -pthread \
           -g # -O0 -DKALDI_PARANOID

ifeq ($(KALDI_FLAVOR), dynamic)
CXXFLAGS += -fPIC
endif

LDFLAGS = $(EXTRA_LDFLAGS) $(OPENFSTLDFLAGS)
LDLIBS = $(EXTRA_LDLIBS) $(OPENFSTLIBS) $(OPENBLASLIBS) -lm -ldl
