CC = gcc
CXX = g++
CXXFLAGS = -O3 -std=c++11
CFLAGS = -O3 -lm 
TARGETS = graph gen check KaHIP
all: master graph graph_hw top_module_gen #gen check KaHIP inter_data

top_module_gen: ./src/top_module_gen.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 

graph: ./src/graph.cpp ./src/utility.h
	#clang-format -i graph.cpp
	#clang-format -i utility.h
	g++ $(CXXFLAGS) -o ./build/$@ $?
gen_loc: ./src/gen_loc.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
gen: ./src/gen.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
check: ./src/check.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
KaHIP: ./src/KaHIP.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
inter_data_nonsram: ./src/inter_data_nonsram.cpp
	g++ $(CXXFLAGS) -o ./build/$@ $?
inter_data:	./src/inter_data.cpp
	#clang-format -i $^
	g++ $(CXXFLAGS) -o ./build/$@ $? 
master_sram: ./src/master_sram.cpp
	g++ $(CXXFLAGS) -o ./build/$@ $? 
master: ./src/master.cpp
	g++ $(CXXFLAGS) -o ./build/$@ $? 
graph_hw: ./src/graph_hw.cpp
	g++ $(CXXFLAGS) -o ./build/$@ $? 
clean:
	rm -f $(TARGETS)
