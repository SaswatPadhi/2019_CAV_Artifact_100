#!/usr/bin/python3

import matplotlib.pyplot as plt

from csv import DictReader
from pprint import pprint
from sys import argv as ARGV

OUTF = ARGV[-1]
ARGV = ARGV[1:-1]
ARGV = [[ARGV[2*i], ARGV[2*i+1]] for i in range(len(ARGV)//2)]

for i in range(len(ARGV)):
    with open(ARGV[i][1], newline='') as csv_file:
        ARGV[i][1] = []
        csv_reader = DictReader(csv_file, delimiter=',')
        next(csv_reader)
        for row in csv_reader:
            ARGV[i][1].append(int(row['Overfit_Count']))

WIDTH = 1.0 / (len(ARGV)+1)
X = list(range(len(ARGV[0][1])))

f = plt.figure(figsize=(10,4))
ax = f.add_subplot(111)

def autolabel(bars):
    for bar in bars:
        h = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2, h+0.25, f"{int(h)}",
                ha='center', va='bottom')
    return bars

series = [autolabel(ax.bar([j + (i*WIDTH) for j in X], ARGV[i][1], WIDTH, align='center'))
          for i in range(len(ARGV))]

ymin, ymax = ax.get_ylim()
ax.set_ylim(ymin, ymax+2.5)

ax.set_xticks([j + (((len(ARGV) - 1) * WIDTH)/2) for j in X])
ax.set_xticklabels([f"Grammar_{i+2}" for i in range(len(ARGV[0][1])+1)])

ax.set_ylabel('Overfitting failures')
ax.set_xlabel('Our integer grammars')

ax.legend(series, [a[0] for a in ARGV], loc='lower center', ncol=len(ARGV),
          bbox_to_anchor=(0.5, 1))

plt.savefig(OUTF, bbox_inches='tight')
