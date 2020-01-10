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
void export_vid(int worker, int vid) {
  char filename[100];
  sprintf(filename, "./gold/%d_vid.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  fprintf(fptr, "%2x", vid);
  // for(int itm = 16; itm >= 0; itm--){
  //   fprintf(fptr, "%d", (proposal >> itm) & 1);
  // }
  fprintf(fptr, "\n");
  fclose(fptr);
  if(worker == 0){
    FILE *tmp = fopen("./gold/tmp_vid_num.dat", "a+");
    fprintf(tmp, "%d\n", vid);
    fclose(tmp);
  }
}
void export_proposal_num(int worker, int batch, int proposal[]) {
  char filename[100];
  sprintf(filename, "./gold/%d_proposal_num.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  for(int i = batch, j = 0; j < K && i >= 0; j++, i--) {
    fprintf(fptr, "%02x", proposal[i]);
  }
  fprintf(fptr, "\n");
  fclose(fptr);
  // if(worker == 0){
  //   FILE *tmp = fopen("./gold/tmp_propsal_num.dat", "a+");
  //   fprintf(tmp, "%d\n", proposal);
  //   fclose(tmp);
  // }
}
void export_part(int worker, int batch, int part[][K], int end) {
  // if(batch > 2) return;
  char filename[100];
  if(end == 0) 
  sprintf(filename, "./gold/%d_bat_part_0sub.dat", worker);
  else 
  sprintf(filename, "./gold/%d_bat_part.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  for(int i = 0; i < K; i++) {
    int p = part[worker][i];
    fprintf(fptr, "%02x", p);
    // for(int itm = 7; itm >= 0; itm--){
    //   fprintf(fptr, "%d", (p >> itm) & 1);
    // }
    if(i != K-1)
    fprintf(fptr, "_");
  }
  fprintf(fptr, "\n");
  fclose(fptr);
  if(worker == 0 && batch == 0){
    FILE *tmp = fopen("./gold/tmp_bat.dat", "a+");
    for(int i = 0; i < K; i++) {
    fprintf(tmp, "%3d,", part[worker][i]);
    }
    fprintf(tmp, "\n");
    fclose(tmp);
  }
}
void export_next(int worker, int batch, int next[]) {
  char filename[100];
  sprintf(filename, "./gold/%d_next.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  for(int i = batch, j = 0; j < K && i >= 0; j++, i--) {
    fprintf(fptr, "%1x", next[i]);
  }
  fprintf(fptr, "\n");
  fclose(fptr);
  // if(worker == 0){
  //   FILE *tmp = fopen("./gold/tmp.dat", "a+");
  //   fprintf(tmp, "%d\n", next);
  //   fclose(tmp);
  // }
}
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
  printf("JJJJJJ\n");
  for(int i = 0; i < 1; i++) {
    for(int j = 0; j < N; j++) {
      if(j % 256 == 0 && j > 0) printf("\n");
      printf("%d", dist[i][j]);
    }
    printf("\n");
  }
  printf("JJJJJJ\n");
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
  dumploc(loc);
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
        for(int i = 0; i < K; i++) part[worker][i] = 0;
        int tmpvid = vid[worker][batch];
        export_vid(worker, tmpvid);
        for (int sub = 0; sub < N / D; sub++) {
          for (int j = sub * D; j < (sub + 1) * D; j++) {
            assert(tmpvid < N && j < N);
            if (dist[tmpvid][j] == 1) {
              int at = loc[j];
              assert(worker < K && at < K);
              part[worker][at]++;
            }
          }
          if(sub == 0) export_part(worker, batch, part, 0);
        }
        export_part(worker, batch, part, 1);
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
        if(batch % 16 == 15 && batch > 0) {
        export_next(worker, batch, next[worker]);
        export_proposal_num(worker, batch, proposal_number[worker]);
        }
        // if(worker == 0)
        // printf("%3d,%3d,%3d\n", tmpvid, next[worker][batch], proposal_number[worker][batch]);
      }
      // export_proposal_cntr();
      // printf("proposal cntr from %d to 0 - K-1", worker);
      // for (int i = 0; i < K; i++) {
      //   printf("%3d,", proposal_cntr[worker][i]);
      // }
      // printf("\n");
    }
  }
}
