#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <vector>
#define INF 1073741823
// check KaHIP parition
int main(int argc, char *argv[]) {
  assert(argc == 3);
  std::string in_file = argv[1];
  std::fstream fs;
  fs.open(in_file, std::ios::in | std::ios::binary);

  std::string part_file = argv[2];

  int V, E;
  int K = 16;
  fs.read((char *)&V, sizeof(int));
  fs.read((char *)&E, sizeof(int));
  std::cout << "V = " << V << ", E = " << E << "\n";
  int part_size = V / K;
  int **dist = new int *[V], **part = new int *[V];

  for (int i = 0; i < V; i++) {
    dist[i] = new int[V];
    for (int j = 0; j < V; j++)
      dist[i][j] = INF;
    dist[i][i] = 0;
    part[i] = new int[2 + K];
    for (int j = 0; j < K; j++)
      part[i][j] = 0;

    part[i][K] = -1;
    part[i][K + 1] = 0;
  }

  std::fstream ifs;
  ifs.open(part_file, std::ios::in);

  for (int i = 0; i < V; i++) {
    int tmppartid;
    ifs >> tmppartid;
    if (i > V - 3)
      std::cout << tmppartid << "\n";
    part[i][K] = tmppartid;
  }

  int tmp[3];
  for (int j = 0; j < E; j++) {
    fs.read((char *)tmp, sizeof(int) * 3);
    int src_id = tmp[0], dst_id = tmp[1], w = tmp[2];
    dist[src_id][dst_id] = w;
    dist[dst_id][src_id] = w;
  }

  int *local = new int[K];
  int *outer = new int[K];

  for (int i = 0; i < V; i++) {
    for (int j = 0; j < V; j++) {
      if (dist[i][j] < INF && i != j) {
        int at = part[j][K];
        part[i][at]++;
      }
    }
  }

  // check edge metrics
  int cntE = 0;

  for (int i = 0; i < K; i++) {
    local[i] = 0;
    outer[i] = 0;
  }
  for (int i = 0; i < V; i++) {
    int current = part[i][K];
    assert(current >= 0 && current < K);
    for (int j = 0; j < K; j++) {
      if (j != current) {
        cntE += part[i][j];
        outer[current] += part[i][j];
      } else
        local[current] += part[i][j];
    }
  }
  cntE /= 2;
  assert(cntE <= E);
  std::cout << "cost: " << cntE << "\n";
  std::cout << "local: \t";
  for (int i = 0; i < K; i++) {
    printf("%d\t", local[i] / 2);
  }
  std::cout << "\nouter: \t";
  for (int i = 0; i < K; i++) {
    printf("%d\t", outer[i] / 2);
  }

  // partition count
  int *stat = new int[K];
  for (int i = 0; i < V; i++) {
    stat[part[i][K]]++;
  }
  std::cout << "parition count: \n";
  for (int i = 0; i < K; i++) {
    std::cout << stat[i] << "\t";
  }
  std::cout << "\n";
}