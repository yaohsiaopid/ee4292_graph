#!/bin/bash
set -x
make top_module_gen
mkdir -p gold_top 
rm gold_top/*
./build/top_module_gen ./build/test.in
