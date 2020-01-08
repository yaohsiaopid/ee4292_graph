#!/bin/bash
set -x
mkdir -p gold
mkdir -p build 
make inter_data
make graph
rm gold/*
./build/inter_data ./build/test.in > a.log
./build/graph ./build/test.in > b.log
