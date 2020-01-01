#include "utility.h"
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>
#define INF 1073741823
#define DUMP 0
#define PROPOSAL_METRIC 0
// 0 -> proposal number first come first serve
int dist[10000][10000] = {0};
int N, E;
const int K = 16;
void input(char filename[]) {
  std::fstream fs;
  fs.open(filename, std::ios::in | std::ios::binary);
  fs.read((char *)&N, sizeof(int));
  fs.read((char *)&E, sizeof(int));

  memset(dist, 0, sizeof(int) * N * N);
  for (int i = 0; i < N; i++)
    dist[i][i] = 1;
  int tmp[3];
  for (int j = 0; j < E; j++) {
    fs.read((char *)tmp, sizeof(int) * 3);
    int src_id = tmp[0], dst_id = tmp[1];
    dist[src_id][dst_id] = 1;
    dist[dst_id][src_id] = 1;
  }
}
void dumploc(int *loc, int dump) {
  if (dump == 0)
    return;
  for(int i = 0; i < N; i++) {
    printf("%3d at %d;", i, loc[i]);
    if ((i + 1) % 5 == 4 && i > 0)
      std::cout << "\n";
    else
      std::cout << "\t";
  }
}
int main(int argc, char *argv[]) {
  assert(argc == 2);
  input(argv[1]);
  std::cout << "N = " << N << ", E = " << E << "\n";
  int part_size = N / K;

  // dist (N x N), part (K x K), vid (K x N/K), loc (N by 1), proposal_cntr (K,
  // K) next (K x N/K), proposal number (K, N/K)
  int **vid = new int *[K], *loc = new int[N]();
  int part[K][K];
  int **next = new int *[N]; // proposal destination
  int **proposal_cntr = new int *[K];
  int **proposal_number = new int *[K];
  for (int i = 0; i < N; i++) {
    loc[i] = (i / part_size >= K - 1) ? K - 1 : i / part_size;
  }
  dumploc(loc, DUMP);
  for (int i = 0; i < K; i++) {
    next[i] = new int[N / K]();
    vid[i] = new int[N / K]();
    proposal_cntr[i] = new int[K]();
    proposal_number[i] = new int[N / K]();
    for (int j = 0; j < N / K; j++) {
      vid[i][j] = i * (N / K) + j;
    }
  }

  int *local = new int[K], *outer = new int[K];
  int D = 256;
  for (int iter = 0; iter < 1; iter++) {
    std::cout << "------------- " << iter << " -------------\n";
    for (int i = 0; i < K; i++) { for (int j = 0; j < K; j++) { part[i][j] = 0; }}

    for (int worker = 0; worker < K; worker++) {
      for (int batch = 0; batch < N / K; batch++) {
        // std::fstream sub_part;
        // char tmpfs[100];
        // sprintf(tmpfs, "./gold/part_bat%d_worker%d.dat", batch, worker);
        // sub_part.open(tmpfs, std::ios::out);
        for(int i = 0; i < K; i++) part[worker][i] = 0;
        int tmpvid = vid[worker][batch];
        for (int sub = 0; sub < N / D; sub++) {
          for (int j = sub * D; j < (sub + 1) * D; j++) {
            assert(tmpvid < N && j < N);
            if (dist[tmpvid][j] == 1) {
              int at = loc[j];
              assert(worker < K && at < K);
              part[worker][at]++;
            }
          }
          // if(tmpvid == 22){
          // printf("worker %2d batch %2d sub %3d: ", worker, batch, sub);
          // for (int i = 0; i < K; i++) {
          //   printf("%3d,", part[worker][i]);
          // }
          // printf("\n");
          // }
        }
        int id = worker;
        int m = part[worker][worker];
        // find max of part[worker][0-K-1];
        for (int pt = 0; pt < K; pt++) {
          if (part[worker][pt] > m) {
            id = pt;
            m = part[worker][pt];
          }
        }
        // TODO: if max = in-edge stay !!!
        next[worker][batch] = id;
        proposal_number[worker][batch] = proposal_cntr[worker][id];
        proposal_cntr[worker][id]++;
        printf("%3d,%3d\n", tmpvid, next[worker][batch]);
        // printf("batch %3d vid = %3d next = %3d proposal number %3d\n", batch,
              //  tmpvid, next[worker][batch], proposal_number[worker][batch]);
      }
      // printf("proposal cntr from %d to 0 - K-1", worker);
      // for (int i = 0; i < K; i++) {
      //   printf("%3d,", proposal_cntr[worker][i]);
      // }
      // printf("\n");
    }
  }
}