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

# Git

## `git-datus`

Date + status = datus, i.e. `git status -s` output sorted by date modified.
Supports all untracked file display options of `git status`.
```
git datus [options]

Options:
-u[mode]                show untracked files (mode = no, normal, all)
-h,--help               show this message and exit
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

## `del_fast.sh`

Fast deletion of a directory containing *many* files, using rsync.

## `wgetcern.sh`

Script to use `wget` with `cern-get-sso-cookie` ([ref](http://linux.web.cern.ch/linux/docs/cernssocookie.shtml)),
to download files protected by CERN single sign on.
