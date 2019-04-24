#!/bin/bash

VPIE_Calls=`grep "vpi_time_ms" $1 | wc -l`
Total_CEs=`grep -Eoe "lig_ce [[:digit:]]+" $1 | awk '{sum += $2} END {print sum}'`

echo $((VPIE_Calls + Total_CEs))
