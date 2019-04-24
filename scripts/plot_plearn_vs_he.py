#!/usr/bin/python3

import matplotlib.pyplot as plt

from csv import DictReader
from pprint import pprint
from sys import argv as ARGV

P_DATA = []
H_DATA = []
L_DATA = []

with open(ARGV[1], newline='') as csv_file:
    for row in DictReader(csv_file, delimiter=','):
        L_DATA.append(int(row['Fail_Count']))
        P_DATA.append(int(row['PLearn_Fail_Count']))

with open(ARGV[2], newline='') as csv_file:
    for row in DictReader(csv_file, delimiter=','):
        H_DATA.append(int(row['Fail_Count']))

f = plt.figure(figsize=(7,4))
ax = f.add_subplot(111)

ax.plot(range(len(L_DATA)), L_DATA, '-o', label='LoopInvGen')
ax.plot(range(len(P_DATA)), P_DATA, '-s', label='PLearn(LoopInvGen)')
ax.plot(range(len(H_DATA)), H_DATA, '-x', label='LoopInvGen+HE')

ax.set_xticks([])
ax.set_xticklabels([])
ax.set_ylabel('Number of failures')

ax.table(cellText=[L_DATA, H_DATA, P_DATA],
         colLabels=[f"Grammar_{i+1}" for i in range(len(L_DATA))],
         rowLabels=['LoopInvGen', 'LoopInvGen+HE', 'PLearn(LoopInvGen)'],
         loc='bottom')

ax.legend(loc='lower center', ncol=3, bbox_to_anchor=(0.5, 1))

plt.savefig(ARGV[3], bbox_inches='tight')
