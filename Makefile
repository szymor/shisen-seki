ifeq ($(PLATFORM), gcw0)
	CC		:= /opt/gcw0-toolchain/usr/bin/mipsel-linux-gcc
	STRIP		:= /opt/gcw0-toolchain/usr/bin/mipsel-linux-strip
	SYSROOT		:= $(shell $(CC) --print-sysroot)
	CFLAGS		:= $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
	CFLAGS		+= -DNO_FRAMELIMIT
	LDFLAGS		:= $(shell $(SYSROOT)/usr/bin/sdl-config --libs) -lSDL_mixer -lm
	RELEASEDIR	:= release
endif

ifeq ($(PLATFORM), a320)
	CC		:= /opt/opendingux-toolchain/usr/bin/mipsel-linux-gcc
	STRIP		:= /opt/opendingux-toolchain/usr/bin/mipsel-linux-strip
	SYSROOT		:= $(shell $(CC) --print-sysroot)
	CFLAGS		:= $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
	CFLAGS		+= -DNO_FRAMELIMIT
	LDFLAGS		:= $(shell $(SYSROOT)/usr/bin/sdl-config --libs) -lSDL_mixer -lm
	TARGET		:= shisen.dge
endif

ifeq ($(PLATFORM), mingw32)
	CC		:= i486-mingw32-gcc
	STRIP		:= i486-mingw32-strip
	SYSROOT		:= $(shell $(CC) --print-sysroot)
	CFLAGS		:= -I/usr/i486-mingw32/include -I/usr/i486-mingw32/include/SDL
	LDFLAGS		:= -lmingw32 -lSDLmain -lSDL -lSDL_mixer -lm -mwindows
	TARGET		:= shisen.exe
endif

CC		?= gcc
STRIP		?= strip
CFLAGS		?= $(shell sdl-config --cflags)
LDFLAGS		?= $(shell sdl-config --libs) -lSDL_mixer -lm
TARGET		?= shisen.elf
SRCDIR		:= src
OBJDIR		:= obj
SRC		:= $(wildcard $(SRCDIR)/*.c)
OBJ		:= $(SRC:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

ifdef DEBUG
	CFLAGS	+= -Wall -ggdb -DDEBUG
else
	CFLAGS	+= -O2
endif

.PHONY: all opk clean

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@
ifndef DEBUG
	$(STRIP) $@
endif

$(OBJ): $(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) -c $(CFLAGS) $< -o $@

$(OBJDIR):
	mkdir -p $@

opk: $(TARGET)
ifeq ($(PLATFORM), gcw0)
	mkdir -p		$(RELEASEDIR)
	cp $(TARGET)		$(RELEASEDIR)
	cp -R data		$(RELEASEDIR)
	cp default.gcw0.desktop	$(RELEASEDIR)
	cp shisen.png		$(RELEASEDIR)
	cp LICENSE.txt		$(RELEASEDIR)
	mksquashfs		$(RELEASEDIR) ShisenSho.opk -all-root -noappend -no-exports -no-xattrs
endif

clean:
	rm -Rf $(TARGET) $(OBJDIR) $(RELEASEDIR)

