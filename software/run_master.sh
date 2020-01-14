#!/bin/bash
set -x
mkdir -p gold_master_s
mkdir -p gold_master
mkdir -p build 
make master_sram 
make master 
rm gold_master/*
rm gold_master_s/*
./build/master ./build/test.in
./build/master_sram ./build/test.in
