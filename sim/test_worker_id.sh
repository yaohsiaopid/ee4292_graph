#!/bin/bash
TESTNUM=$1
FILE=template_worker.v
for NUM in {0..15}
do
#NUM=0
    echo "----------${NUM}--------------"
    sed "s/CHECKID/${NUM}/" $FILE > test_worker.v
    ncverilog -f sim_worker.f > a.log 
    grep "test_worker\.v:" a.log
done 
#NNN=$(awk '/readmemh/{print NR;exit}' $FILE)
#sed -i "${NNN}s/0/${TESTNUM}/" $FILE
#NNN=$(expr "$NNN" + 1)
#sed -i "${NNN}s/0/${TESTNUM}/" $FILE
#NNN=$(expr "$NNN" + 8)
#sed -i "${NNN}s/0/${TESTNUM}/" $FILE
#NNN=$(expr "$NNN" + 2)
#sed -i "${NNN}s/0/${TESTNUM}/" $FILE

