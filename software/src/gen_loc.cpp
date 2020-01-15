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
  // print
  // export dist 
  FILE *fptr = fopen("./gold/dist.dat", "a+");
  
  for(int i = 0; i < N; i++) {
    int j = 0;
    while(j < N) {
    for(int tmp = 0; tmp < 64 && j < N; tmp++, j+=4) {
      // fprintf(fptr, "%", dist[i][j]);
      int a = dist[i][j] * 8 + dist[i][j+1] * 4 + dist[i][j+2] * 2 + dist[i][j+3];
      fprintf(fptr, "%1x", a);
      // if(j += 4 < N) fprintf(fptr, " ");
    }
    }
    fprintf(fptr, "\n");
  }
  fclose(fptr);
}
void dumploc(int *loc) {
  
  FILE *fptr = fopen("./gold/loc.dat", "a+");
  for(int i = 0; i < N; i++) {
    fprintf(fptr, "%02x\n", loc[i]);
  }
  fclose(fptr);
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
  FILE *fptr = fopen("./gold_master_s/loc_w0.dat", "w");
  for(int i = 0; i < N; i++) {
    fprintf(fptr, "1");
    for(int itm = 3; itm >= 0; itm--) {
      fprintf(fptr, "%d", (loc[i] >> itm) & 1);
    }
    // fprintf(fptr, "%02x\n", loc[i]);
    if(i % 256 == 255){ 
      fprintf(fptr, "\n");
      // fclose(fptr);
      // char fil[100]; sprintf(fil, "./gold/loc_w%d.dat",(i+1)/256);
      // fptr = fopen(fil, "w");
    } else {
      fprintf(fptr, "_");
    }
  }
  fclose(fptr);
  
}
