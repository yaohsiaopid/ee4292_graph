#!/bin/bash
set -x
make inter_data
make graph
rm gold/*
./build/inter_data ./build/test.in > a.log
./build/graph ./build/test.in > b.log
