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
#define Q 16
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
void export_proposal_num(int worker, int proposal) {
  char filename[100];
  sprintf(filename, "./gold/%d_proposal_num.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  fprintf(fptr, "%2x", proposal);
  // for(int itm = 7; itm >= 0; itm--){
  //   fprintf(fptr, "%d", (proposal >> itm) & 1);
  // }
  fprintf(fptr, "\n");
  fclose(fptr);
  if(worker == 0){
    FILE *tmp = fopen("./gold/tmp_propsal_num.dat", "a+");
    fprintf(tmp, "%d\n", proposal);
    fclose(tmp);
  }
}
void export_part(int worker, int batch, int sub, int part[][K]) {
  if(batch > 2) return;
  char filename[100];
  sprintf(filename, "./gold/%d_bat%d_part.dat", worker, batch);
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
void export_next(int worker, int batch, int next) {
  char filename[100];
  sprintf(filename, "./gold/%d_next.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  fprintf(fptr, "%2x", next);
  // for(int itm = 3; itm >= 0; itm--){
  //   fprintf(fptr, "%d", (next >> itm) & 1);
  // }
  fprintf(fptr, "\n");
  fclose(fptr);
  if(worker == 0){
    FILE *tmp = fopen("./gold/tmp.dat", "a+");
    fprintf(tmp, "%d\n", next);
    fclose(tmp);
  }
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
//   for(int i = 10; i < 11; i++) {
//     for(int j = 0; j < N; j++) {
//       if(j % 256 == 0 && j > 0) printf("\n");
//       printf("%d", dist[i][j]);
//     }
//     printf("\n");
//   }
  // export dist 
  /*FILE *fptr = fopen("./gold/dist.dat", "a+");
  
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
  */
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
//   dumploc(loc);
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
        // export_vid(worker, tmpvid);
        for (int sub = 0; sub < N / D; sub++) {
          for (int j = sub * D; j < (sub + 1) * D; j++) {
            assert(tmpvid < N && j < N);
            if (dist[tmpvid][j] == 1) {
              int at = loc[j];
              assert(worker < K && at < K);
              part[worker][at]++;
            }
          }
        //   export_part(worker, batch, sub, part);
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
        // export_next(worker, batch, next[worker][batch]);
        // export_proposal_num(worker, proposal_number[worker][batch]);
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
    // for(int i = 0; i < K; i++) {
    //     for(int j = 0; j < K; j++) {
    //         printf("%3d,", proposal_cntr[i][j]);
    //     }
    //     printf("\n");
    // }
    // master 
    printf("---=======----=====----\n");
    int buffer[K][2*Q] = {0};
    int accum[K] = {0};
    int buffaccum[K] = {0};
    int export_flg[K] = {0};
    int wdata[K][Q] = {0};
    int waddr[K] = {0};
    int epoch_num = 16;//N / Q;
    for(int epoch = 0; epoch < epoch_num; epoch++) {
        int banknum = epoch / Q;
        int idx = epoch % Q;
        int v_gidx[Q], next_arr[Q];
        int mi_j[K], mj_i[K];
        int proposal_nums[Q];
        int xijs[K];
        int real_next_arr[Q];
        for(int i = 0; i < Q; i++) {
            v_gidx[i] = vid[banknum][idx * Q + i];
            proposal_nums[i] = proposal_number[banknum][idx * Q + i];
            next_arr[i] = next[banknum][idx * Q + i];
        }
        for(int i = 0; i < K; i++) {
            mi_j[i] = proposal_cntr[banknum][i];
            mj_i[i] = proposal_cntr[i][banknum];
            xijs[i] = mi_j[i] < mj_i[i] ? mi_j[i] : mj_i[i];
            if(idx == 0) {
                // printf("%d %d, xij = %d\n", banknum, i, xijs[i]);
                // printf("i: %d, mi_j[%d] = %d, mj_i[%d] = %d\n",banknum, i, mi_j[i], i, mj_i[i]);
            }
        }
        for(int i = 0; i < Q; i++) {
            real_next_arr[i] = xijs[next_arr[i]] > proposal_nums[i] ?  next_arr[i] : banknum; 
        }
        int onehot[Q][K];
        for(int i = 0; i < Q; i++) {
            for(int j = 0; j < Q; j++) {
                onehot[i][j] = (real_next_arr[i] == j);
            }
        }
        // printf("partial sum:\n");
        int partial_sum[Q][K];
        for(int i = 0; i < Q; i++) {
            for(int j = 0; j < K; j++) {
                partial_sum[i][j] = 0;
                for(int r = 0; r <= i; r++) {
                    partial_sum[i][j] += onehot[r][j];
                }
                // printf("%2d,", partial_sum[i][j]);
            }
            // printf("\n");
        }
        // printf("-----------------\n");
        //---- same 
        int buffer_idx[Q];
        for(int i = 0; i < Q; i++) {
            buffer_idx[i] = (partial_sum[i][real_next_arr[i]] - 1) + 
                            (accum[real_next_arr[i]] >= Q ? accum[real_next_arr[i]] - Q : accum[real_next_arr[i]]);
            // printf("buffer_idx[%2d] = %3d; ",i, buffer_idx[i]);
            // printf("%3d, %3d\n", v_gidx[i], real_next_arr[i]);
            assert(buffer_idx[i] < 2 * Q);
        }
        // printf("-----------------\n");
        for(int i = 0; i < K; i++) {
            buffaccum[i] = (accum[i] >= Q ? accum[i] - Q : accum[i]);
            if(accum[i] >= Q) {
                accum[i] -= Q;
                accum[i] += partial_sum[Q-1][i];
                export_flg[i] = 1;
            } else {
                accum[i] += partial_sum[Q-1][i];
                export_flg[i] = 0;
            }
            // printf("(%3d, %3d),", accum[i], export_flg[i]);
        }

        // ------
        // printf("-----------------\n export ? :");
        for(int i = 0; i < K; i++) {
            if(export_flg[i] == 1) {
                printf("$$$$ i = %d:  ", i);
                for(int j = 0; j < Q; j++) {
                    wdata[i][j] = buffer[i][j];
                    buffer[i][j] = 0;
                    printf("%3d,", wdata[i][j]);
                }
                printf("\n");
                waddr[i]++;
            }
        }
        // printf("\n-----------\nbuffaccum:");
        // for(int i = 0; i < K; i++) {
        //     printf("%2d, ", buffaccum[i]);
        // }
        // printf("-----------------\n");
        // printf("----\n");
        for(int buffi = 0; buffi < K; buffi++) {
            for(int buffj = 0; buffj < 2*Q; buffj++) {
                if(export_flg[buffi] == 1 && buffj < buffaccum[buffi]) {
                    buffer[buffi][buffj] = buffer[buffi][buffj + Q];
                } else {
                    if(buffj < buffaccum[buffi]) {
                        buffer[buffi][buffj] = buffer[buffi][buffj];
                    } else {
                        buffer[buffi][buffj] = 0;
                        for(int tmp = 0; tmp < Q; tmp++) {
                            buffer[buffi][buffj] += (real_next_arr[tmp] == buffi) * (buffer_idx[tmp] == buffj) * v_gidx[tmp];
                        }
                        assert(buffer[buffi][buffj] <= vid[banknum][255]);
                    }
                }
                // printf("%3d,", buffer[buffi][buffj]);
            }
            // printf("\n");
        }
        
        // ----
        // printf("\n-----------\naccum:");
        // for(int i = 0; i < K; i++) {
        //     printf("%2d, ", accum[i]);
        // }
        // printf("-----------------\n");

        // if(idx == 0)
        // printf("-----------\n");
    }
    printf("-----------------\n waddr: ");
    for(int i = 0; i < K; i++) {
        printf("%2d, ", waddr[i]);
    }
    printf("\n-----------\naccum:");
    for(int i = 0; i < K; i++) {
        printf("%2d, ", accum[i]);
    }
    printf("\n-----------\nbuff:\n");
    for(int buffi = 0; buffi < K; buffi++) {
        for(int buffj = 0; buffj < 2*Q; buffj++) {
            printf("%3d,", buffer[buffi][buffj]);
        }
        printf("\n");
    }
  }
}
