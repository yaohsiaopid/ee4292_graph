#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <vector>
#define INF 1073741823
void dumpGraph(int **dist, int V) {
  std::cout << "\n graph\n";
  for (int i = 0; i < V; i++) {
    for (int j = 0; j < V; j++) {
      if (dist[i][j] == INF)
        std::cout << "INF\t";
      else
        std::cout << dist[i][j] << "\t";
      assert(dist[i][j] == dist[j][i]);
    }
    std::cout << "\n";
  }
}
void dumpProposal(int **proposals, int K) {
  for (int i = 0; i < K; i++) {
    for (int j = 0; j < K; j++) {
      std::cout << proposals[i][j] << "\t";
    }
    std::cout << "\n";
  }
}