NCDIR = /opt/NuvuCameras
CC = gcc
CFLAGS = -DLINUX
CFLAGS += -O2 -Wall -pipe
#CFLAGS += -I/usr/lib/x86_64-linux-gnu -I/usr/include
#CFLAGS += -fopenmp
CFLAGS += -I${NCDIR}/include
#CFLAGS += -I/usr/include/cfitsio -I/usr/local/src/cfitsio

LIBS = -L${NCDIR}/lib -lnuvu
LIBS += -ltiff
#LIBS += -lcfitsio
#LIBS += -ldl
#LIBS += -lgomp
#LIBS += -lncurses
#LIBS += -lstdc++
#LIBS += -lm

TARGETS = ncacquire nclist
default: ${TARGETS}

%: %.c
	$(CC) $(CFLAGS) -o "$@" "$<" $(LIBS)

clean:
	rm -f *.o *~ ${TARGETS}
