#
# Makefile --
#
# Rules to build utilities and wrapper for the Nüvü Camēras.
#
#-------------------------------------------------------------------------------
#
# This file is part of the `NuvuCameras.jl` package which is licensed under
# the MIT "Expat" License.
#
# Copyright (C) 2018, Éric Thiébaut.
#

srcdir = .

# Macros for compiling with Activevision Phoenix library:
NUVU_DIR = /opt/NuvuCameras
NUVU_LIBDIR = $(NUVU_DIR)/lib
NUVU_INCDIR = $(NUVU_DIR)/include -DLINUX
NUVU_DEFS = -I$(NUVU_INCDIR)
NUVU_DLL = $(NUVU_LIBDIR)/libnuvu.so
#NUVU_LIBS = -L$(NUVU_LIBDIR) -lnuvu ... -lpthread -ldl

PIC_FLAGS = -fPIC
CC = gcc
CPPFLAGS = -I.
CFLAGS = -O2 -Wall
LDFLAGS =

default: deps.jl

clean:
	rm -f *~ *.o

all: $(srcdir)/../src/constants.jl ccalls-auto.jl deps.jl

deps.jl: Makefile
	echo >"$@" "const libnuvu = \"$(NUVU_DLL)\""

$(srcdir)/../src/constants.jl: constants-begin.jl extract_errors.sed
	rm -f "$@"
	cp constants-begin.jl "$@"
	echo >>"$@" ""
	echo >>"$@" "# Error codes."
	./extract_errors.sed >>"$@" < "$(NUVU_DIR)/include/nc_error.h"

ccalls-auto.jl: extract_ccalls.sed ccalls-begin.jl
	rm -f "$@"
	cp ccalls-begin.jl "$@"
	echo >>"$@" ""
	./extract_ccalls.sed >>"$@" < "$(NUVU_DIR)/include/nc_api.h"
