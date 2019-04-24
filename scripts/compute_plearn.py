#!/usr/bin/env python3

from argparse import ArgumentParser, FileType
from csv import DictReader
from pprint import pprint

parser = ArgumentParser()
parser.add_argument('files', metavar='RESULT_CSV', type=FileType('r'), nargs='+')
parser.add_argument('-c', '--combine-to', metavar='CSV_FILE',
                    type=FileType('w', encoding='UTF-8'))
parser.add_argument('-P', '--PLearn-combine-to', dest='plearn_combine_to',
                    metavar='CSV_FILE', type=FileType('w', encoding='UTF-8'))
args = parser.parse_args()

ARGS = len(args.files)
DATA = [ 0 ] * ARGS
OVER = [ 0 ] * ARGS
PASS = [ 0 ] * ARGS
PLRN = [ 0 ] * ARGS

for i in range(ARGS):
    DATA[i] = []
    for row in DictReader(args.files[i], delimiter=','):
        row['Verdict'] = row['Verdict'].strip()
        DATA[i].append(row)
    DATA[i].sort(key=lambda d: d['Benchmark'])
    PASS[i] = sum(0 if ('PASS' in d['Verdict']) else 1 for d in DATA[i])
    PLRN[i] = PASS[i]
    if i > 0:
        OVER[i] = sum(1 if ('PASS' not in d['Verdict']
                            and
                            any('PASS' in DATA[k][j]['Verdict'] for k in range(i)))
                      else 0
                    for (j, d) in enumerate(DATA[i]))
        PLRN[i] -= OVER[i]

if args.combine_to is not None:
    args.combine_to.write(','.join(['Benchmark'] + [f"Grammar_{i+1}_Time"
                                                    for i in range(ARGS)]))
    args.combine_to.write('\n')
    for i in range(len(DATA[0])):
        args.combine_to.write(
            ','.join([DATA[0][i]['Benchmark']]
                     + [DATA[j][i]['Wall_Time(s)']
                        if DATA[j][i]['Verdict'] == 'PASS'
                        else 'FAIL'
                        for j in range(ARGS)]))
        args.combine_to.write('\n')

def plearn_time(j, i):
    argmin, min_time = float('inf'), float('inf')
    for k in range(j + 1):
        if DATA[k][i]['Verdict'] == 'PASS':
            if float(DATA[k][i]['Wall_Time(s)']) < min_time:
                argmin = k
                min_time = float(DATA[k][i]['Wall_Time(s)'])
    return 'FAIL' if argmin > j else f"{(j + 1) * min_time:.2f}"

if args.plearn_combine_to is not None:
    args.plearn_combine_to.write(','.join(['Benchmark'] + [f"Grammar_{i+1}_Time"
                                                           for i in range(ARGS)]))
    args.plearn_combine_to.write('\n')
    for i in range(len(DATA[0])):
        args.plearn_combine_to.write(
            ','.join([DATA[0][i]['Benchmark']]
                     + [plearn_time(j, i) for j in range(ARGS)]))
        args.plearn_combine_to.write('\n')

print('Grammar,Fail_Count,Overfit_Count,PLearn_Fail_Count')
for i in range(ARGS):
    print(f"{i+1},{PASS[i]},{OVER[i]},{PLRN[i]}")
