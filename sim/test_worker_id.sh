#!/bin/bash
TESTNUM=$1
FILE=test_worker.v
NNN=$(awk '/readmemh/{print NR;exit}' $FILE)
sed -i "${NNN}s/0/${TESTNUM}/" $FILE
NNN=$(expr "$NNN" + 1)
sed -i "${NNN}s/0/${TESTNUM}/" $FILE
NNN=$(expr "$NNN" + 8)
sed -i "${NNN}s/0/${TESTNUM}/" $FILE
NNN=$(expr "$NNN" + 2)
sed -i "${NNN}s/0/${TESTNUM}/" $FILE

