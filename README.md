# CMSSW

## `cmsrel_all.sh`

A very simple script to list all available scram architectures for a specified CMSSW release number. Requires cvmfs.

## `peakMem.sh`

Parse the output of the CMSSW `SimpleMemoryCheck` service to determine the peak VSIZE and RSS values from a given process log.

## `scramProgress.sh`

Tracks the progress of compilation with scram, assuming the scram printouts are redirected into a log file. Output looks like:
```
scram status:
 in progress: 10 / 42
    finished: 32 / 42
```
The denominator counts all packages in the release area as directories matching `*/*`, e.g. "foo/bar".
"finished" counts all packages which scram has noted as "built".
"in progress" counts all packages which scram has noted as "Compiling" (but not yet "built").

# EOS/xrootd

## `eosdu`

Efficient and safe disk usage script for the EOS filesystem.
```
eosdu [options] <LFN>

Options:
-s              xrootd server name (default = root://cmseos.fnal.gov)
-f              count number of files instead of disk usage
-g              search for files matching specified string within directory
-h              print human readable sizes
-r              run eosdu for each file/directory in <LFN>
                ('recursive'/'wildcard' option, like 'du *')
```

## `xrdcpLocal.sh`

Script to copy a file over xrootd to specified directory (local area by default),
keeping the entire LFN as the local filename ('/' replaced with '_'). Arguments:
* `-f`: use `xrdcp -f`
* `-q`: use `xrdcp -q`
* `-x [redir]`: xrootd redirector (required)
* `-L [lfn]`: logical filename (LFN) (required)
* `-o [dir]`: output directory (default = `./`)

# HTCondor

## `allprio.sh`

A very simple script to sort the output of `condor_userprio -allusers` by the usage column.

## `condorq_all.sh`

Sums up the total number of jobs (with each status) over *all* accessible schedulers, for specified user:
```
./condorq_all.sh [username]
```

## `jobmon.py`

Monitors overall status of running, idle, and held jobs on the LPC batch farm.
```
PAGER='less -S' jobmon.py
```

# Git

## `git-datus`

Date + status = datus, i.e. `git status -s` output sorted by date modified.
Supports all untracked file display options of `git status`.
```
git datus [options]

Options:
-u[mode]                show untracked files (mode = no, normal, all)
-l,--long               show long timestamp
-h,--help               show this message and exit
--                      separator; anything after this will be passed to git status
```

## `git squash`

Squash the last N commits, i.e. `git squash HEAD~N`.
```
git squash [options] <REF>

Options:
-k, --keep              keep commit messages from squashed commits
```

## `git-sync`

Overwrites the current branch and working area with the branch version from a specified remote.
Can optionally stash and pop/apply uncommitted changes in the working area.
Useful when developing on one server and testing on another.
```
git sync [options] <remote>

Options:
-s, --stash             stash any uncommitted changes before syncing
-p, --pop               pop stashed changes after syncing
-a, --apply             apply stashed changes after syncing
```

# Other

## `cmde`

Wrapper to run a command that creates a new file, and then edit the new file. Usage:
```bash
cmde COMMAND [cmde options] [--] [COMMAND options] FILE1 FILE2
```

Options:
* `-e [editor]`: text editor (default: `nano`)
* `-f`: overwrite FILE2 (if it already exists)
* `-h`: display this message and exit
* `--`: optional separator (in case COMMAND uses same flags as `cmde`)

`cmde` does not work with all forms of all commands, but just those that end with `FILE1 FILE2` (i.e. `SRC DEST`) syntax.

It is most typically used with `cp` (but could also be used with `mv`, etc.). Useful alias:
```bash
alias cpe='cmde cp'
```

## `del_fast.sh`

Fast deletion of a directory containing *many* files, using rsync.

## `diffy`

Script to use diff side-by-side view (`diff -y`) with automatic width (max line length from input files), piped to `less -S` (no word wrap). Options:
* `-M [num]` - specify max width
* `-L` - shorthand for `--left-column` diff option

All other flags are passed directly to the `diff` command. (`-t` is enabled by default, so passing it explicitly instead disables it.).

## `runIgprof.sh`

Script to run igprof and produce a report. Currently only supports performance profiling and ASCII reports.
If a name is specified with no associated command but with sorting options, it will try to locate the
corresponding report and produce sorted reports.
Options:
* `-e [command]` - command to profile (enclose in "" if contains spaces)
* `-n [name]` - name for output files (default = test)
* `-t [exe]` - limit profiling to specified target executable
* `-s [modules]` - produce sorted reports of contributions, one for each module (comma-separated list)
* `-d [modules]` - produce sorted reports of contributions, one for each module's descendants (comma-separated list)
* `-x [args]` - any extra arguments to igprof (quoted)
* `-r` - profile a ROOT macro, prepends `root.exe -b -l -q ` to specified command (avoid quote nesting)
* `-c` - special settings for `cmsRun` (use `-t cmsRun`, sort descendants of `doEvent`)
* `-h` - print help message and exit

## `setupCert.sh`

Script to set up a grid certificate for use on a remote server. Usage:
```
setupCert.sh [options] [user@server] [p12 file]

Options:
-c              set up for cern-get-sso-cookie
-d              dry run (just print commands, don't execute)
```

## `tunn`

A simple utility to create and manage SSH tunnels.
```
tunn [operation] [options] [arguments]

Default settings are obtained from the config file at /home/pedrok/.tunnconfig.
To override the config file location, put this in your .bashrc or other login file:
    export TUNN_CONFIG=/my/preferred/file
The available config variables are: TUNN_PREFIX, TUNN_PORT, TUNN_VERBOSE.
Their values should be specified in the config file using bash syntax, e.g.:
    TUNN_PORT=8XXX
(If TUNN_PORT is not specified in the config file or via the command line option,
the default value is taken from the last three digits of your UID.)

Operations:

make         make new tunnel
    -n [name]        tunnel socket name prefix (default: /home/pedrok/.tsock)
    -p [port]        tunnel port (default: 8864)
    [destination]    ssh destination for tunnel (required)

list         list open tunnels

kill         kill specified tunnel
    [index]          index of tunnel (required)

Common options:
-u           (unclean) do not auto-remove closed tunnels from list
-v           toggle verbosity (default: false)
-h           print this message and exit
```

Useful aliases:
```
alias tmake='tunn make'
alias tlist='tunn list'
alias tkill='tunn kill'
```

## `wgetcern.sh`

Script to use `wget` with `cern-get-sso-cookie` ([ref](http://linux.web.cern.ch/linux/docs/cernssocookie.shtml)),
to download files protected by CERN single sign on.
CERN SSO authentication can proceed via kerberos (default) or via user certificates
with the arguments `--cert` and `--key` (see above link for more info).
