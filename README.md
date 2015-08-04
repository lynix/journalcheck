journalcheck
============

2015 - Alexander Koch

### A simple replacement for logcheck for usage with journald

Journalcheck aims at being a simple replacement for
[_logcheck_](http://logcheck.org) when using journald for system logs. It calls
`journalctl` to obtain all messages that have been recorded since its last
invocation, pipes the output through `egrep` with a given set of filters, and
passes the remaining messages to stdout. Journalcheck therefore works with
volatile system logs as well.

## Dependencies
 * journald (`journalctl`)
 * `egrep`

## Usage
Journalcheck is best run as regular user (no need for root privileges!)
via cron:
```
MAILTO=user@localhost

# m  h  dom mon dow   command
*/30 *  *   *   *     journalcheck
```

With a local MTA/MDA set up correctly, you will receive all log entries not
matching the white-list by mail. In addition to the ones shipped with
journalcheck, it looks in _~/.journalcheck.d_ for user-defined filters.

## Configuration
Journalcheck is configurable through the following environment variables
(default values in brackets):

 * `FILTER_GLOBAL` (*/usr/lib/journalcheck*): System-wide filter directory
 * `FILTER_LOCAL` (*$HOME/.journalcheck.d*): User filter directory
 * `MERGE_FILE` (*/tmp/merged.ignore*): output file for merged filters
 * `STATE_FILE` (*$HOME/.journalcheck.state*): Last run timestamp file
 * `NCPU` (no. of CPUs/cores): Number of worker processes to spawn

## Help Wanted
As I only have a limited set of machines and applications running
to derive filters from, I rely heavily on contributions in order to provide a
universal filter set. Pull requests are welcome!

## License
Journalcheck is released under the terms of the MIT License, see
LICENSE file.
