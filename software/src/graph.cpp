#include "utility.h"
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <vector>
#define INF 1073741823
#define DUMP 0
#define PROPOSAL_METRIC 0
// 0 -> proposal number first come first serve
// 1 -> random
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
    part[i] = new int[3 + K];
    // K   : current partition
    // K+1 : proposal destination
    // K+2 : proposal #

    for (int j = 0; j < K; j++)
      part[i][j] = 0;

    part[i][K] = i / part_size >= K - 1 ? K - 1 : i / part_size;
#if DUMP == 1
    printf("%3d is at partition %d;", i, part[i][K]);
    if ((i + 1) % 5 == 4 && i > 0)
      std::cout << "\n";
    else
      std::cout << "\t";
#endif
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
#if DUMP == 1
  dumpGraph(dist, V);
#endif

  // gen proposals
  int **proposals = new int *[K];
  int *local = new int[K];
  int *outer = new int[K];
  for (int i = 0; i < K; i++) {
    proposals[i] = new int[K];
  }
  std::cout << "\n";
  for (int iter = 0; iter < 10; iter++) {
    std::cout << "------------- " << iter << " -------------\n";
    for (int i = 0; i < K; i++) {
      for (int j = 0; j < K; j++)
        proposals[i][j] = 0;

      for (int j = 0; j < V; j++)
        part[j][i] = 0;
    }

    for (int i = 0; i < V; i++) {
      for (int j = 0; j < V; j++) {
        if (dist[i][j] < INF) {
          int at = part[j][K];
          part[i][at]++;
        }
      }
      int mycurrent = part[i][K];
      // if(i == 22)?
      // printf("mycurrent = %d\n", mycurrent);
      int id = mycurrent;
      int m = part[i][mycurrent];
      for (int pt = 0; pt < K; pt++) {
        if (part[i][pt] > m) {
          id = pt;
          m = part[i][pt];
        }
      }
    //  if(iter > 0) printf("%d,%d\n", i, proposals[mycurrent][id]);
      part[i][K + 1] = id;
      part[i][K + 2] = proposals[mycurrent][id];
      // if (id != mycurrent) {
       // part[i][K + 2] = proposals[mycurrent][id];
        proposals[mycurrent][id]++;
      // }
      // printf("%3d,%3d,%3d\n", i, part[i][K+1],part[i][K+2]);
    }
// dump proposal
#if DUMP == 1
    // mij 
    dumpProposal(proposals, K);
#endif

    // check edge metrics
    int cntE = 0;

    for (int i = 0; i < K; i++) {
      local[i] = 0;
      outer[i] = 0;
    }
    for (int i = 0; i < V; i++) {
      int current = part[i][K];
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
      printf("%d,", local[i]);
    }
    std::cout << "\nouter: \t";
    for (int i = 0; i < K; i++) {
      printf("%d,", outer[i]);
    }
    // dump  mijs
    printf("---=======----=====----\n");
    for(int i = 0; i < K; i++) {
      for(int j = 0; j < K; j++) {
        printf("%3d,", proposals[i][j]);
      }
      printf("\n");
    }
    printf("---=======----=====----\n");
    // update
    std::cout << "\n -- moving -- \n";
    int movecnt = 0;
    for (int i = 0; i < V; i++) {
      int newdst = part[i][K + 1]; // proposal to newdst
      int current = part[i][K];
      if (newdst != current) {
        int mij = proposals[current][newdst], mji = proposals[newdst][current];
        int xij = mij < mji ? mij : mji;
// change partition randomly
// #if PROPOSAL_METRIC == 2
//         int rrr = std::rand() % mij;
//         if ((mij != xij && rrr < xij) || mij == xij) {
// #elif PROPOSAL_METRIC == 1
//         if ((mij != xij && (i / (V / mij)) < xij) || mij == xij) {
// #else
        if ((mij != xij && part[i][K + 2] < xij) || mij == xij) {
// #endif
          part[i][K] = newdst;
          movecnt++;
        }
      }
    }
    std::cout << "move cnt:" << movecnt << "\n";
    // if (movecnt == 0) {
    //   // dump proposal
    //   dumpProposal(proposals, K);
    // }
    // dump where they go
    // for(int i = 0; i < V; i++) {
    //   printf("%3d, %3d\n", i, part[i][K]);
    // }
    // partition count
    int *stat = new int[K];
    for (int i = 0; i < V; i++) {
      stat[part[i][K]]++;
    }
    // std::cout << "parition count: \n";
    // for (int i = 0; i < K; i++) {
    //   std::cout << stat[i] << "\t";
    // }
    // std::cout << "\n";
    // for(int i = 0; i < K; i++) {
    //   printf("%d: ", i);
    //   for(int j = 0; j < 256; j++) {
    //     if(part[j][K] == i) printf("%3d,", j);
    //   }
    //   printf("\n");
    // }
    char iterflnm[100];
    sprintf(iterflnm, "./logs/iter%d", iter);
    FILE *fpr= fopen(iterflnm, "w");  
    std::vector<std::vector<int>> wdata_total(K); // K rows 
    for(int i = 0; i < V; i++) {
      fprintf(fpr, "%d,%d\n", i, part[i][K]);
      wdata_total[part[i][K]].push_back(i);
    }
    // for(int i = 0; i < K; i++) {
    //   for(int j = 0; j < wdata_total[i].size(); j++) {
    //     fprintf(fpr, "%d,", wdata_total[i][j]);
    //   }
    //   fprintf(fpr, "\n");
    // }
    fclose(fpr);
  }
}
