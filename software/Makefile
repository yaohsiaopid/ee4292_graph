CC = gcc
CXX = g++
CXXFLAGS = -O3 -std=c++11
CFLAGS = -O3 -lm 
TARGETS = graph gen check KaHIP
.PHONY: all
all: graph gen check KaHIP

graph: graph.cpp utility.h
	clang-format -i graph.cpp
	clang-format -i utility.h
	g++ $(CXXFLAGS) -o $@ graph.cpp
gen: gen.cpp
	clang-format -i gen.cpp
	g++ $(CXXFLAGS) -o $@ $? 
check: check.cpp
	clang-format -i check.cpp
	g++ $(CXXFLAGS) -o $@ $? 
KaHIP: KaHIP.cpp
	clang-format -i KaHIP.cpp
	g++ $(CXXFLAGS) -o $@ $? 
clean:
	rm -f $(TARGETS)
