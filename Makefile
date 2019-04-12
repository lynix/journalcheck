DESTDIR ?= 
PREFIX ?= /usr

install:
	install -D -m 755 journalcheck.sh $(DESTDIR)$(PREFIX)/bin/journalcheck
	install -D -m 644 -t $(DESTDIR)$(PREFIX)/lib/journalcheck filters/*.ignore

.PHONY: install
