#!/bin/bash
set -x
make graph_hw
make graph
mkdir -p gold_master
mkdir -p gold
rm gold_master/*
rm gold/*
./build/graph_hw ./build/test.in
./build/graph ./build/test.in
