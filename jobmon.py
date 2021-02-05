#!/usr/bin/env python

import subprocess
import pydoc
from collections import defaultdict
from operator import add

class StatusItem(object):
    def __init__(self, cmd, header, separator, match, replace=[]):
        self.cmd = cmd
        self.header = header
        self.match = match
        self.replace = replace
        self.header_lines = []
        self.separator_lines = [separator]
        self.keep_lines = []
        self.rows = []
        
    def call(self):
        cmd_output = subprocess.check_output(self.cmd)
        self.header_lines = []
        self.keep_lines = []
        ctr = 0
        for line in cmd_output.split('\n'):
            linesplit = self.format(line)
            if ctr in self.header:
                self.header_lines.append(linesplit)
            elif self.match in line:
                self.keep_lines.append(linesplit)
            ctr += 1
        self.add_remove()
        self.rows = self.header_lines + self.separator_lines + self.keep_lines
        return self.output()

    # split, replace, etc.
    def format(self,line):
        for old,new in self.replace:
            line = line.replace(old,new)
        return line.split()

    # for derived content e.g. computed totals, and/or excluding lines based on split content
    def add_remove(self):
        pass

    def output(self):
        # transpose to find max length for each column
        column_lengths = [max(len(row[i]) if i<len(row) else 0 for row in self.rows) for i in range(max(len(header) for header in self.header_lines))]
        lines = []
        for row in self.rows:
            line = ""
            for row_item,col_len in zip(row,column_lengths):
                line += "{0:>{1}}  ".format(row_item,col_len)
            # remove trailing spaces
            line = line[:-2]
            lines.append(line)
        return lines
        
class StatusItemSchedd(StatusItem):
    def add_remove(self):
        totals = ['','']
        sums = [sum(int(line[i]) for line in self.keep_lines) for i in [2,3,4]]
        totals.extend(str(s) for s in sums)
        # separation between total & entries
        self.keep_lines.extend(self.separator_lines)
        self.keep_lines.append(totals)

class StatusItemSubmitters(StatusItem):
    def add_remove(self):
        self.keep_lines = [line for line in self.keep_lines if line[2:5]!=['0']*3]
        # aggregate over schedds
        aggr_dict = defaultdict(lambda: [0,0,0])
        for line in self.keep_lines:
            aggr_dict[line[0]] = list(map(add,aggr_dict[line[0]],[int(x) for x in line[2:5]]))
        # use aggr results, sorted by running
        self.keep_lines = [[key]+[str(v) for v in val] for key,val in aggr_dict.iteritems()]
        self.keep_lines = sorted(self.keep_lines, key = lambda x: int(x[1]), reverse=True)
        # remove machine from header
        self.header_lines = [[line[0]]+line[2:] for line in self.header_lines]
        # compute totals
        totals = ['']
        sums = [sum(int(line[i]) for line in self.keep_lines) for i in [1,2,3]]
        totals.extend(str(s) for s in sums)
        # separation between total & entries
        self.keep_lines.extend(self.separator_lines)
        self.keep_lines.append(totals)

class StatusItemUserprio(StatusItem):
    def add_remove(self):
        totals = next(line for line in self.keep_lines if line[0]=="group_cmslpc")
        self.keep_lines.remove(totals)
        self.keep_lines = sorted(self.keep_lines, key = lambda x: float(x[3]))
        self.keep_lines.extend(self.separator_lines)
        self.keep_lines.append(totals)
    def format(self,line):
        # swap out underscores used to prevent splitting header lines
        linesplit = super(StatusItemUserprio,self).format(line)
        linesplit = [line.replace("__"," ") for line in linesplit]
        # insert blanks for missing column entries
        if len(linesplit)>0:
            if linesplit[0]=="group_cmslpc":
                linesplit = linesplit[0:3] + [''] + linesplit[3:]
            elif linesplit[0]=="Config":
                linesplit = [''] + linesplit[:]
            elif not linesplit[0].startswith("User"):
                linesplit = [linesplit[0],'',''] + linesplit[1:] + ['']
        return linesplit

# env PAGER='less -S' ./jobmon.py
if __name__=="__main__":
    items = [
        StatusItemSchedd(
            cmd=["condor_status","-schedd"],
            header=[0],
            separator="",
            match="lpcschedd",
        ),
        StatusItemSubmitters(
            cmd=["condor_status","-submitters"],
            header=[0],
            separator="",
            match="lpcschedd",
            replace=[("group_cmslpc.",""),("@fnal.gov","")],
        ),
        StatusItemUserprio(
            cmd=["condor_userprio","-grouporder"],
            header=[1,2],
            separator="",
            match="group_cmslpc",
            replace=[("group_cmslpc.",""),("@fnal.gov",""),("User Name","User__Name"),("In Use","In__Use"),("Total Usage","Total__Usage"),("Time Since","Time__Since"),("Last Usage","Last__Usage")],
        ),
    ]
    
    result = []
    for item in items:
        result.extend(item.call())
        result.extend([''])
        
    pydoc.pager('\n'.join(result))

