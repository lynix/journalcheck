
PREFIX ?= /usr

install:
	install -d $(PREFIX)/bin
	install -m 755 journalcheck $(PREFIX)/bin/journalcheck
	install -d $(PREFIX)/lib/journalcheck
	install -m 644 filters/*.ignore $(PREFIX)/lib/journalcheck/


.PHONY: install

