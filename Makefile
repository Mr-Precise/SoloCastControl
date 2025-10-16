PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
DESTDIR ?=

SCRIPT = SoloCastControl.sh

all:
	@echo "Nothing to build. Use 'make install' to install the script."

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(SCRIPT) $(DESTDIR)$(BINDIR)/solocastcontrol

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/solocastcontrol

clean:
	@echo "Nothing to clean."

.PHONY: all install uninstall clean
