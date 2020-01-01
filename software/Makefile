CC = gcc
CXX = g++
CXXFLAGS = -O3 -std=c++11
CFLAGS = -O3 -lm 
TARGETS = graph gen check KaHIP
all: graph gen check KaHIP inter_data

graph: graph.cpp utility.h
	#clang-format -i graph.cpp
	#clang-format -i utility.h
	g++ $(CXXFLAGS) -o ./build/$@ graph.cpp
gen: gen.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
check: check.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
KaHIP: KaHIP.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
inter_data:	inter_data.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
clean:
	rm -f $(TARGETS)
