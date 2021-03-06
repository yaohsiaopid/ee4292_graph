#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <iostream>
#include <vector>
#include <ctime>
#include <cassert>
#define INF 1073741823
int main(int argc, char *argv[]) {
  assert(argc >= 2);
  std::srand(std::time(nullptr));
  std::fstream fs;
  fs.open("test.in", std::ios::out | std::ios::binary);
  std::vector<std::vector<int> > dist;
  int v = atoi(argv[1]);
  int e = std::rand() % (v * (v - 1) / 2); //(8 * (v * (v - 1) / 2)) / 10;
  fs.write((char *)&v, sizeof(int));
  fs.write((char *)&e, sizeof(int));
  std::cout << "V = " << v << ", E = " << e << "\n";
  dist.resize(v);
  for (int i = 0; i < v; i++) {
    dist[i].resize(v, INF);
  }
  for (int eid = 0; eid < e; eid++) {
    int src_id, dst_id;
    while (1) {
      src_id = std::rand() % v;
      dst_id = std::rand() % v;
      if (src_id != dst_id && dist[src_id][dst_id] == INF)
        break;
    }
    fs.write((char *)&src_id, sizeof(int));
    fs.write((char *)&dst_id, sizeof(int));
    int w = 1; // std::rand() % 100;
    dist[src_id][dst_id] = w;
    dist[dst_id][src_id] = w;
    fs.write((char *)&w, sizeof(int));
    fs.write((char *)&dst_id, sizeof(int));
    fs.write((char *)&src_id, sizeof(int));
    fs.write((char *)&w, sizeof(int));
    if (argc == 3)
      std::cout << "(" << src_id << "," << dst_id << ") = " << w << "\n";
  }
  std::fstream tmpfs;
  tmpfs.open("test2.graph", std::ios::out);
  tmpfs << v << " " << e << "\n";
  for (int i = 0; i < v; i++) {
    for (int j = 0; j < v; j++) {
      if (i != j && dist[i][j] < INF) {
        tmpfs << j + 1 << " ";
      }
    }
    tmpfs << "\n";
  }
  tmpfs.close();
  fs.close();
}
