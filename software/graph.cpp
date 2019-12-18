#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <vector>
#define INF 1073741823
int main(int argc, char *argv[]) {
  assert(argc == 2);
  std::string in_file = argv[1];
  std::fstream fs;
  fs.open(in_file, std::ios::in | std::ios::binary);

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

    part[i][K] = i / part_size >= K - 1 ? K - 1 : i / part_size;
    printf("%3d is at partition %d;", i, part[i][K]);
    if ((i + 1) % 5 == 4 && i > 0)
      std::cout << "\n";
    else
      std::cout << "\t";
    part[i][K + 1] = 0; // i / part_size;
    // current partition which it belongs to
    // part[i][0- K-1] = number of neighbors in that partition
  }

  int tmp[3];
  for (int j = 0; j < E; j++) {
    fs.read((char *)tmp, sizeof(int) * 3);
    int src_id = tmp[0], dst_id = tmp[1], w = tmp[2];
    dist[src_id][dst_id] = w;
    dist[dst_id][src_id] = w;
  }

  // dump graph
  // for(int i = 0; i < V; i++) {
  //     for(int j = 0; j < V; j++) {
  //         if(dist[i][j] == INF)
  //         std::cout << "INF\t";
  //         else
  //         std::cout << dist[i][j] << "\t";
  //         assert(dist[i][j] == dist[j][i]);
  //     }
  //     std::cout << "\n";
  // }

  // gen proposals
  int **proposals = new int *[K];
  for (int i = 0; i < K; i++) {
    proposals[i] = new int[K];
    for (int j = 0; j < K; j++)
      proposals[i][j] = 0;
  }

  for (int i = 0; i < V; i++) {
    for (int j = 0; j < V; j++) {
      if (dist[i][j] < INF) {
        int at = part[j][K];
        part[i][at]++;
      }
    }
    int id = 0;
    int m = part[i][0];
    for (int pt = 1; pt < K; pt++) {
      if (part[i][pt] > m) {
        id = pt;
        m = part[i][pt];
      }
    }
    int mycurrent = part[i][K];
    part[i][K + 1] = id;
    if (id != mycurrent) {
      proposals[mycurrent][id]++;
    }
  }

  // check edge metrics
  int cntE = 0;
  for (int i = 0; i < V; i++) {
    int current = part[i][K];
    std::cout << i << "," << current << "\n";
    for (int j = 0; j < K; j++) {
      if (j != current)
        cntE += part[i][j];
    }
  }
  cntE /= 2;
  assert(cntE <= E);
  std::cout << "cost: " << cntE << "\n";

  // // pass proposal
  // int **pass = new int*[K];
  // for(int i = 0; i < K; i++) {
  //     pass[i] = new int[K];
  //     for(int j = i + 1; j < K; j++) {
  //         int xij = proposals[i][j] < proposals[j][i] ? proposals[i][j] :
  //         proposals[j][i]; pass[i][j] = xij; pass[j][i] = xij;
  //     }
  // }

  // update
  std::cout << "\n -- moving -- \n";
  for (int i = 0; i < V; i++) {
    int newdst = part[i][K + 1]; // proposal to newdst
    int current = part[i][K];
    if (newdst != current) {
      int mij = proposals[current][newdst], mji = proposals[newdst][current];
      int xij = mij < mji ? mij : mji;

      // change partition randomly
      if ((mij != xij && (i / (V / mij)) < xij) || mij == xij) {
        part[i][K] = newdst;
        std::cout << i << "  moves from " << current << " to " << newdst
                  << "\n";
      }
    }
  }

  // check edge metrics
  cntE = 0;
  for (int i = 0; i < V; i++) {
    int current = part[i][K];
    std::cout << i << "," << current << "\n";
    for (int j = 0; j < K; j++) {
      if (j != current)
        cntE += part[i][j];
    }
  }
  cntE /= 2;
  assert(cntE <= E);
  std::cout << "cost: " << cntE << "\n";
}