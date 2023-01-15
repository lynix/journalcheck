journalcheck
============

(C) Alexander Koch

### A simple replacement for logcheck for usage with journald

Journalcheck aims at being a simple replacement for
[_logcheck_](http://logcheck.org) when using journald for system logs. It calls
`journalctl` to obtain all messages that have been recorded since its last
invocation, pipes the output through `egrep` with a given set of filters, and
passes the remaining messages to stdout. Journalcheck therefore works with
volatile system logs as well.

## Dependencies
 * systemd (`journalctl`)
 * coreutils (`split`)
 * grep (`egrep`)

## Installation
Journalcheck is best run as regular user account (no need for root privileges!).

As root: add the user account to the group 'systemd-journal', in order to authorize it to read all logs:
```
usermod -a -G systemd-journal UserAccountName
```

Then add to your crontab a line invoking journalcheck:
```
MAILTO=UserAccountName@localhost

# m  h  dom mon dow   command
*/30 *  *   *   *     journalcheck
```

## Usage

With a local MTA/MDA set up correctly, you will then receive by mail all log entries not
matching the white-list. In addition to the ones shipped with
journalcheck, it looks in _~/.journalcheck.d_ for user-defined filters.

For cron-less systems making use of systemd .timer units instead, there are
example units in _example_. They rely on
[checkrun.sh](https://github.com/lynix/checkrun.sh) for mail functionality.

## Configuration
Journalcheck is configurable through the following environment variables
(default values in brackets):

 * `JC_FILTERS_GLOBAL` (*/usr/lib/journalcheck*): Directory for system-wide filters
 * `JC_FILTERS_USER` (*~/.journalcheck.d*): Directory for user-defined filters
 * `JC_CURSOR_FILE` (*~/.journalcheck.cursor*): Last run timestamp file
 * `JC_NUM_THREADS` (no. of logical CPUs): Number of worker threads to spawn
 * `JC_LOGLEVEL` (0..5): Priority (loglevel) filter

## Help Wanted
As I only have a limited set of machines and applications running to derive
filters from, I rely heavily on contributions in order to provide a universal
filter set. Pull requests are welcome!

## License
Journalcheck is released under the terms of the MIT License, see LICENSE file.
