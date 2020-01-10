#!/bin/bash
set -x
mkdir -p gold_master
mkdir -p build 
make master 
rm gold_master/*
./build/master ./build/test.in
