#!/bin/bash
set -x
make graph_hw
make graph
./build/graph_hw ./build/test.in
./build/graph ./build/test.in
