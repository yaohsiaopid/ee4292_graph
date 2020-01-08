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
std::vector<std::vector<int>> wdata_total(K); // K rows 
void export_inputs(int v_gidx[], int proposal_nums[], int next_arr[], int mi_j[], int mj_i[]) {
  FILE *f_v_gids = fopen("./gold_master/v_gidx.dat", "a+");
  FILE *f_props_num = fopen("./gold_master/proposal_nums.dat", "a+");
  FILE *f_next_arr = fopen("./gold_master/next_arr.dat", "a+");
  FILE *f_mi_j = fopen("./gold_master/mi_j.dat", "a+");
  FILE *f_mj_i = fopen("./gold_master/mj_i.dat", "a+");
  for(int i = 0; i < Q; i++) {
    fprintf(f_v_gids, "%03x", v_gidx[i]);
    if(i < Q - 1) fprintf(f_v_gids, "_");
    fprintf(f_props_num, "%02x", proposal_nums[i]);
    if(i < Q - 1) fprintf(f_props_num, "_");
    fprintf(f_next_arr, "%1x", next_arr[i]);
    if(i < Q - 1) fprintf(f_next_arr, "_");
  }
  for(int i = 0; i < K; i++) {
    fprintf(f_mi_j, "%02x", mi_j[i]);
    if(i < K - 1) fprintf(f_mi_j, "_");
    fprintf(f_mj_i, "%02x", mj_i[i]);
    if(i < K - 1) fprintf(f_mj_i, "_");
  }
  fprintf(f_v_gids, "\n");
  fprintf(f_props_num, "\n");
  fprintf(f_next_arr, "\n");
  fprintf(f_mi_j, "\n");
  fprintf(f_mj_i, "\n");
  fclose(f_v_gids);
  fclose(f_props_num);
  fclose(f_next_arr);
  fclose(f_mi_j);
  fclose(f_mj_i);
}
void export_wdata(int epoch, int wen, int wdata[][Q]) {
  FILE *f_wdata = fopen("./gold_master/wdata.dat", "a+");
  assert(wen < 65536);
  fprintf(f_wdata, "%02x_%04x\n", epoch, wen);
  for(int i = 0, bitselect = 1 << (K-1); i < K; i++, bitselect = bitselect >> 1) {
    if(wen & bitselect) {
      fprintf(f_wdata, "%x\n", i);
      for(int j = 0; j < Q; j++) {  
        fprintf(f_wdata, "%03x", wdata[i][j]);
      }  
    }
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
      }
    }
    
    // master 
    printf("---=======----=====----\n");
    int buffer[K][2*Q] = {0};
    int accum[K] = {0};
    int buffaccum[K] = {0};
    int export_flg[K] = {0};
    int wdata[K][Q] = {0};
    int waddr[K] = {0};
    int partial_sum[Q][K];
    int epoch_num = N / Q;
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
        }
        // export next_arr, mi_j, mj_i, v_gidx, proposal_nums
        export_inputs(v_gidx, proposal_nums, next_arr, mi_j, mj_i);
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
        int wen = 0;
        for(int i = 0; i < K; i++) {
            if(export_flg[i] == 1) {
                // printf("$$$$ i = %d:  ", i);
                wen = wen | (1 << (15-i));
                for(int j = 0; j < Q; j++) {
                    wdata[i][j] = buffer[i][j];
                    buffer[i][j] = -1;
                    // printf("%3d,", wdata[i][j]);
                }
                // export to checking 
                for(int j = 0; j < Q; j++) {
                  wdata_total[i].push_back(wdata[i][j]);
                }
                // printf("\n");
                waddr[i]++;
            }
        }
        export_wdata(epoch, wen, wdata);
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
                            buffer[buffi][buffj] = buffer[buffi][buffj] | ((real_next_arr[tmp] == buffi) * (buffer_idx[tmp] == buffj) * v_gidx[tmp]);
                        }
                        assert(buffer[buffi][buffj] <= vid[banknum][255]);
                    }
                }
                assert(buffer[buffi][buffj] >= 0);
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


    // clean buffer 

    for(int i = 0; i < K; i++) {
        // buffaccum[i] = (accum[i] >= Q ? accum[i] - Q : accum[i]);
        if(accum[i] >= Q) {
            accum[i] -= Q;
            accum[i] += partial_sum[Q-1][i];
            export_flg[i] = 1;
        } else {
        //     accum[i] += partial_sum[Q-1][i];
            export_flg[i] = 0;
        }
        // printf("(%3d, %3d),", accum[i], export_flg[i]);
    }

    // ------
    // printf("-----------------\n export ? :");
    for(int i = 0; i < K; i++) {
        if(export_flg[i] == 1) {
            // printf("$$$$ i = %d:  ", i);
            for(int j = 0; j < Q; j++) {
                wdata[i][j] = buffer[i][j];
                buffer[i][j] = 0;
                // printf("%3d,", wdata[i][j]);
            }
            // export to checking 
            for(int j = 0; j < Q; j++) {
              wdata_total[i].push_back(wdata[i][j]);
            }
            // printf("\n");
            waddr[i]++;
        }
    }

    // ----- 
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

    FILE *fpr= fopen("out.csv", "w");  
    for(int i = 0; i < K; i++) {
      for(int j = 0; j < wdata_total[i].size(); j++) {
        fprintf(fpr, "%d,", wdata_total[i][j]);
      }
      fprintf(fpr, "\n");
    }
  }
}
