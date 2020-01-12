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
  for (int iter = 0; iter < 10; iter++) {
    std::cout << "------------- " << iter << " -------------\n";
    for (int i = 0; i < K; i++) { for (int j = 0; j < K; j++) { part[i][j] = 0; }}

    for (int worker = 0; worker < K; worker++) {
      for (int batch = 0; batch < N / K; batch++) {
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
        }
        int id = worker;
        int m = part[worker][worker];
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
    int locs_total[N];
    int epoch_num = N / Q;
    int locsram[16][16][256][2] = {0}; // 16 srams, 16 addr , 256 itesm per addr, 2: gidx & valid bit
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
        
        for(int i = 0; i < Q; i++) {
            real_next_arr[i] = xijs[next_arr[i]] > proposal_nums[i] ?  next_arr[i] : banknum; 
            locsram[i][(v_gidx[i]/256)][(v_gidx[i]%256)][0] = real_next_arr[i];//v_gidx[i];
            locsram[i][(v_gidx[i]/256)][(v_gidx[i]%256)][1] = 1;
            locs_total[v_gidx[i]] = real_next_arr[i];
        }

        int onehot[Q][K];
        for(int i = 0; i < Q; i++) {
            for(int j = 0; j < Q; j++) {
                onehot[i][j] = (real_next_arr[i] == j);
            }
        }
        
        for(int i = 0; i < Q; i++) {
            for(int j = 0; j < K; j++) {
                partial_sum[i][j] = 0;
                for(int r = 0; r <= i; r++) {
                    partial_sum[i][j] += onehot[r][j];
                } 
            }
        }
        int buffer_idx[Q];
        for(int i = 0; i < Q; i++) {
            buffer_idx[i] = (partial_sum[i][real_next_arr[i]] - 1) + 
                            (accum[real_next_arr[i]] >= Q ? accum[real_next_arr[i]] - Q : accum[real_next_arr[i]]);
            assert(buffer_idx[i] < 2 * Q);
        }
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
        }
        int wen = 0;
        for(int i = 0; i < K; i++) {
            if(export_flg[i] == 1) {
                wen = wen | (1 << i);
                for(int j = 0; j < Q; j++) {
                    wdata[i][j] = buffer[i][j];
                    buffer[i][j] = -1;
                }
                // export to checking 
                for(int j = 0; j < Q; j++) {
                  wdata_total[i].push_back(wdata[i][j]);
                }
                waddr[i]++;
            }
        }
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
            }
        }
    }


    // clean buffer 

    for(int i = 0; i < K; i++) {
        if(accum[i] >= Q) {
            accum[i] -= Q;
            accum[i] += partial_sum[Q-1][i];
            export_flg[i] = 1;
        } else {
            export_flg[i] = 0;
        }
    }

    int wen = 0;
    for(int i = 0; i < K; i++) {
        if(export_flg[i] == 1) {
            wen = wen | (1 << i);
            for(int j = 0; j < Q; j++) {
                wdata[i][j] = buffer[i][j];
                buffer[i][j] = -1;
            }
            for(int j = 0; j < Q; j++) {
              wdata_total[i].push_back(wdata[i][j]);
            }
            waddr[i]++;
        }
    }
    // for(int i = 0; i < N; i++) {
    //     loc[i] = locs_total[i];
    // }
    char iterflnm[100];
    sprintf(iterflnm, "./logs/hw_iter%d", iter);
    FILE *fpr= fopen(iterflnm, "w");
    for(int i = 0; i < K; i++) {
        printf("i = %d size %d\n", i, wdata_total[i].size());
      assert(wdata_total[i].size() == 256);
      for(int j = 0; j < wdata_total[i].size(); j++) {
        fprintf(fpr, "%d,", wdata_total[i][j]);
        vid[i][j] = wdata_total[i][j]; 
        loc[wdata_total[i][j]] = i;
      }
      fprintf(fpr, "\n");
    }
    fclose(fpr);
    
    // for(int i = 0; i < K; i++) {
    //     printf("wdata total: %d %ld\n",i, wdata_total[i].size());
    //     for(int j = 0; j < wdata_total[i].size(); j++) {
    //       printf("%d,", wdata_total[i][j]);
    //     }
    //     printf("\n");
    // }
  }
}
