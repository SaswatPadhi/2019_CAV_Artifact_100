#!/usr/bin/python3

import matplotlib.pyplot as plt

from csv import DictReader
from pprint import pprint
from sys import argv as ARGV

P_DATA = []
N_DATA = []

with open(ARGV[2], newline='') as csv_file:
    for row in DictReader(csv_file, delimiter=','):
        N_DATA.append(int(row['Fail_Count']))
        P_DATA.append(int(row['PLearn_Fail_Count']))

f = plt.figure(figsize=(7,4))
ax = f.add_subplot(111)

ax.plot(range(len(N_DATA)), N_DATA, '-x', label=f"{ARGV[1]}")
ax.plot(range(len(P_DATA)), P_DATA, '-o', label=f"PLearn({ARGV[1]})")

ax.set_xticks([])
ax.set_xticklabels([])
ax.set_ylabel('Number of failures')

ax.table(cellText=[N_DATA, P_DATA],
         colLabels=[f"Grammar_{i+1}" for i in range(len(N_DATA))],
         rowLabels=[f"{ARGV[1]}", f"PLearn({ARGV[1]})"],
         loc='bottom')

ax.legend(loc='lower center', ncol=3, bbox_to_anchor=(0.5, 1))

plt.savefig(ARGV[3], bbox_inches='tight')
