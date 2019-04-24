#!/usr/bin/python3

from csv import DictReader
from numpy import median
from pprint import pprint
from sys import argv as ARGV

ARGV = ARGV[1:]
ARGV = [[ARGV[2*i], ARGV[2*i+1]] for i in range(len(ARGV)//2)]
ARGS = len(ARGV)

for i in range(ARGS):
    with open(ARGV[i][1], newline='') as csv_file:
        ARGV[i][1] = []
        for row in DictReader(csv_file, delimiter=','):
            ARGV[i][1].append(row)
        ARGV[i][1].sort(key=lambda d: d['Benchmark'])

print(', '.join([' Grammar '] + [f"{ARGV[i][0]}_:_{ARGV[i+1][0]}" for i in range(ARGS-1)]))

for i in range(len(ARGV[0][1][0])-1):
    print(f"Grammar_{i+1}", end='')
    for j in range(ARGS-1):
        data = [float(ARGV[j][1][k][f"Grammar_{i+1}_Time"]) / float(ARGV[j+1][1][k][f"Grammar_{i+1}_Time"])
                for k in range(len(ARGV[j][1]))
                if not (ARGV[j][1][k][f"Grammar_{i+1}_Time"].strip() == 'FAIL'
                        or
                        ARGV[j+1][1][k][f"Grammar_{i+1}_Time"].strip() == 'FAIL')]
        print(f", {median(data):^34.3}", end='')
    print('')
