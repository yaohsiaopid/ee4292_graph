CC = gcc
CXX = g++
CXXFLAGS = -O3 -std=c++11
CFLAGS = -O3 -lm 
TARGETS = graph

graph: graph.cpp
	clang-format -i graph.cpp
	g++ $(CXXFLAGS) -o $@ $? 
gen: gen.cpp
	clang-format -i gen.cpp
	g++ $(CXXFLAGS) -o $@ $? 
clean:
	rm -f $(TARGETS)
