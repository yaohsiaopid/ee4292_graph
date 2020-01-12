#!/bin/bash
set -x
make graph_hw
./build/graph_hw ./build/test.in
