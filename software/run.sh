#!/bin/bash
set -x
./build/inter_data ./build/test.in > a.log
./build/graph ./build/test.in > b.log