#!/usr/bin/env python3

from csv import DictReader
from pprint import pprint
from sys import argv as ARGV

ARGS = len(ARGV) - 1
DATA = [ 0 ] * ARGS

ROUNDS_to_TIME = [ 0, 0, 0 ]
TIME_to_ROUNDS = [ 0, 0, 0 ]

for i in range(ARGS):
    DATA[i] = []
    with open(ARGV[i+1], newline='') as csv_file:
        for row in DictReader(csv_file, delimiter=','):
            row['Verdict'] = row['Verdict'].strip()
            if row['Verdict'] == 'PASS':
                row['Rounds'] = int(row['Rounds'])
                row['Time'] = float(row['Wall_Time(s)'])
            DATA[i].append(row)
    DATA[i].sort(key=lambda d: d['Benchmark'])

MAX_LEN = max(len(d) for d in DATA)

for i in range(ARGS):
    for j in range(i+1, ARGS):
        data_subset = [k for k in range(MAX_LEN)
                       if (DATA[i][k]['Verdict'] == 'PASS'
                           and
                           DATA[j][k]['Verdict'] == 'PASS')]
        inc_rounds_subset = [k for k in data_subset
                             if DATA[i][k]['Rounds'] < DATA[j][k]['Rounds']]
        inc_time_subset = [k for k in data_subset
                           if DATA[i][k]['Time'] < DATA[j][k]['Time']]
        ROUNDS_to_TIME[0] = len([k for k in inc_rounds_subset
                                 if DATA[i][k]['Time'] < DATA[j][k]['Time']])
        ROUNDS_to_TIME[1] = len([k for k in inc_rounds_subset
                                 if DATA[i][k]['Time'] == DATA[j][k]['Time']])
        ROUNDS_to_TIME[2] = len([k for k in inc_rounds_subset
                                 if DATA[i][k]['Time'] > DATA[j][k]['Time']])
        TIME_to_ROUNDS[0] = len([k for k in inc_time_subset
                                 if DATA[i][k]['Rounds'] < DATA[j][k]['Rounds']])
        TIME_to_ROUNDS[1] = len([k for k in inc_time_subset
                                 if DATA[i][k]['Rounds'] == DATA[j][k]['Rounds']])
        TIME_to_ROUNDS[2] = len([k for k in inc_time_subset
                                 if DATA[i][k]['Rounds'] > DATA[j][k]['Rounds']])
        ROUNDS_to_TIME = [(f * 100.0) / sum(ROUNDS_to_TIME) for f in ROUNDS_to_TIME]
        TIME_to_ROUNDS = [(f * 100.0) / sum(TIME_to_ROUNDS) for f in TIME_to_ROUNDS]

print('   On Increasing Expressiveness   | Increase | NoChange | Decrease')
print('----------------------------------+----------+----------+---------')
print(f" Increase(Time)   => ???(Rounds)  |   {TIME_to_ROUNDS[0]:04.1f}   |   {TIME_to_ROUNDS[1]:04.1f}   |   {TIME_to_ROUNDS[2]:04.1f}")
print(f" Increase(Rounds) =>   ???(Time)  |   {ROUNDS_to_TIME[0]:04.1f}   |   {ROUNDS_to_TIME[1]:04.1f}   |   {ROUNDS_to_TIME[2]:04.1f}")
