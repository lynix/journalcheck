
PREFIX ?= /usr

install:
	install -d $(PREFIX)/bin
	install -m 755 journalcheck $(PREFIX)/bin/journalcheck
	install -d $(PREFIX)/share/journalcheck.d
	install -m 644 filters/*.ignore $(PREFIX)/share/journalcheck.d/


.PHONY: install

