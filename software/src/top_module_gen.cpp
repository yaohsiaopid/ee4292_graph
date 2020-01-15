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
int giter;
std::vector<std::vector<int>> wdata_total(K); // K rows 
void export_vid(int worker, int vid) {
  if(giter == 0) return;
  static int vidcnt = 0;
  char filename[100];
  sprintf(filename, "./gold_top/%d_vid.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  fprintf(fptr, "%04x", vid);
  if(vidcnt % 16 == 15)
    fprintf(fptr, "\n");
  vidcnt++;
  fclose(fptr);
}
void export_proposal_num(int worker, int batch, int proposal[]) {
  if(giter == 0) return;
  char filename[100];
  sprintf(filename, "./gold_top/%d_proposal_num.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  for(int i = batch, j = 0; j < K && i >= 0; j++, i--) {
    fprintf(fptr, "%02x", proposal[i]);
  }
  fprintf(fptr, "\n");
  fclose(fptr);
  // if(worker == 0){
  //   FILE *tmp = fopen("./gold_top/tmp_propsal_num.dat", "a+");
  //   fprintf(tmp, "%d\n", proposal);
  //   fclose(tmp);
  // }
}
void export_part(int worker, int batch, int part[][K], int end) {
  if(giter == 0) return;
  // if(batch > 2) return;
  char filename[100];
  if(end == 0) 
  sprintf(filename, "./gold_top/%d_bat_part_0sub.dat", worker);
  else 
  sprintf(filename, "./gold_top/%d_bat_part.dat", worker);
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
    FILE *tmp = fopen("./gold_top/tmp_bat.dat", "a+");
    for(int i = 0; i < K; i++) {
    fprintf(tmp, "%3d,", part[worker][i]);
    }
    fprintf(tmp, "\n");
    fclose(tmp);
  }
}
void export_next(int worker, int batch, int next[]) {
  if(giter == 0) return;
  char filename[100];
  sprintf(filename, "./gold_top/%d_next.dat", worker);
  FILE *fptr = fopen(filename, "a+");
  for(int i = batch, j = 0; j < K && i >= 0; j++, i--) {
    fprintf(fptr, "%1x", next[i]);
  }
  fprintf(fptr, "\n");
  fclose(fptr);
  // if(worker == 0){
  //   FILE *tmp = fopen("./gold_top/tmp.dat", "a+");
  //   fprintf(tmp, "%d\n", next);
  //   fclose(tmp);
  // }
}
void dumploc(int *loc) {
  if(giter == 0) return;
  FILE *fptr = fopen("./gold_top/loc.dat", "a+");
  for(int i = 0; i < N; i++) {
    fprintf(fptr, "%02x\n", loc[i]);
  }
  fclose(fptr);
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
  FILE *fptr = fopen("./gold_top/dist_sram.dat", "w");
  for(int i = 0; i < N; i++) {
    int j = 0;
    while(j < N) {
      for(int tmp = 0; tmp < 64 && j < N; tmp++, j+=4) {
        int a = dist[i][j] * 8 + dist[i][j+1] * 4 + dist[i][j+2] * 2 + dist[i][j+3];
        fprintf(fptr, "%1x", a);
      }
      fprintf(fptr, "\n");
    }
  }
  fclose(fptr);
}
void export_inputs(int v_gidx[], int proposal_nums[], int next_arr[], int mi_j[], int mj_i[]) {
  static int cntrs = 0;
  if(giter == 0) return;
  char filnm[100];
  sprintf(filnm, "./gold_top/proposal_nums_w%d.dat", cntrs/256);
  FILE *f_props_num = fopen(filnm, "a+");
  sprintf(filnm, "./gold_top/next_sram_w%d.dat", cntrs/256);
  FILE *f_next_arr = fopen(filnm, "a+");
  cntrs += Q;
  for(int i = 0; i < Q; i++) {
    // fprintf(f_v_gids, "%04x", v_gidx[i]);
    // if(i < Q - 1) fprintf(f_v_gids, "_");
    fprintf(f_props_num, "%02x", proposal_nums[i]);
    if(i < Q - 1) fprintf(f_props_num, "_");
    fprintf(f_next_arr, "%1x", next_arr[i]);
    if(i < Q - 1) fprintf(f_next_arr, "_");
  }
  
  fprintf(f_props_num, "\n");
  fprintf(f_next_arr, "\n");
  fclose(f_props_num);
  fclose(f_next_arr);
  FILE *f_mi_j = fopen("./gold_top/mi_j.dat", "a+");
  FILE *f_mj_i = fopen("./gold_top/mj_i.dat", "a+");
  for(int i = 0; i < K; i++) {
    fprintf(f_mi_j, "%02x", mi_j[i]);
    if(i < K - 1) fprintf(f_mi_j, "_");
    fprintf(f_mj_i, "%02x", mj_i[i]);
    if(i < K - 1) fprintf(f_mj_i, "_");
  }
  fprintf(f_mi_j, "\n");
  fprintf(f_mj_i, "\n");
  fclose(f_mi_j);
  fclose(f_mj_i);
}
void export_wdata(int epoch, int wen, int wdata[][Q]) {
  if(giter == 0) return;
  FILE *f_wdata = fopen("./gold_master/wdata.dat", "a+");
  assert(wen < 65536);
  fprintf(f_wdata, "%02x %04x\n", epoch, wen);
  for(int i = 0, bitselect = 1; i < K; i++, bitselect = bitselect << 1) {
    if(wen & bitselect) {
      fprintf(f_wdata, "%x\n", i);
      for(int j = 0; j < Q; j++) {  
        fprintf(f_wdata, "%04x", wdata[i][j]);
        if(j < Q - 1) 
        fprintf(f_wdata, "_");
      }
      fprintf(f_wdata, "\n");
    }
  }
  fclose(f_wdata);
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
  for (int iter = 0; iter < 2; iter++) {
    giter = iter;
    dumploc(loc);
    std::cout << "------------- " << iter << " -------------\n";
    for (int i = 0; i < K; i++) { 
        for (int j = 0; j < K; j++) { 
            part[i][j] = 0; 
            proposal_cntr[i][j] = 0;
        }
    }
    int cnte[K][K] = {0}, outer[K][K] = {0};
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
              cnte[worker][at]++;
              part[worker][at]++;
            }
          }
        //   if(sub == 0) export_part(worker, batch, part, 0);
        }
        // export_part(worker, batch, part, 1);
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
        if(batch % 16 == 15 && batch > 0) {
        export_next(worker, batch, next[worker]);
        export_proposal_num(worker, batch, proposal_number[worker]);
        }
      }
    }
    if(iter > 0) {
      int osum = 0, insum = 0;
      for(int i = 0; i < K; i++) {
        for(int j = 0; j < K; j++) {
          if(i != j) osum += cnte[i][j];
        }
      }
      printf("total: osum %d insum %d\n", osum, insum);
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
        export_inputs(v_gidx, proposal_nums, next_arr, mi_j, mj_i);
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
        export_wdata(epoch, wen, wdata);
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
                          if(buffer[buffi][buffj] != 0 && (real_next_arr[tmp] == buffi) && (buffer_idx[tmp] == buffj))
                            printf("conflict %d %d %d\n", buffer[buffi][buffj], buffi, buffj);
                          buffer[buffi][buffj] = buffer[buffi][buffj] + ((real_next_arr[tmp] == buffi) * (buffer_idx[tmp] == buffj) * v_gidx[tmp]);
                        }
                        
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
    export_wdata(epoch_num, wen, wdata);
    for(int i = 0; i < K; i++) {
      char flnm[100];
      sprintf(flnm, "./gold_top/vid_sram_w%d.dat", i);
      FILE *fsram = fopen(flnm, "w");
      for(int j = 0; j < wdata_total[i].size(); j += 16) {
        for(int tmp = 0; tmp < 16; tmp++) 
          fprintf(fsram, "%04x", wdata_total[i][j+tmp]);
        fprintf(fsram, "\n");
      }
      fclose(fsram);
    }
    
    for(int i = 0; i < N; i++) {
        loc[i] = locs_total[i];
    }
    char iterflnm[100];
    sprintf(iterflnm, "./gold_top/hw_iter%d", iter);
    FILE *fpr= fopen(iterflnm, "w");
    for(int i = 0; i < K; i++) {
      assert(wdata_total[i].size() == 256);
      for(int j = 0; j < wdata_total[i].size(); j++) {
        fprintf(fpr, "%d,%d\n", wdata_total[i][j],i);
        vid[i][j] = wdata_total[i][j]; 
        loc[wdata_total[i][j]] = i;
      }
      wdata_total[i].resize(0);
    }
    fclose(fpr);

    int stat[4096] = {0}, stat2[4096] = {0};
    for(int i = 0; i < K; i++) {
      char flnm[100]; 
      sprintf(flnm, "./gold_top/locsram_w%d.dat", i);
      FILE *fptr_loc = fopen(flnm, "w");
      for(int j = 0; j < K; j++) {
        // for(int q = 255; q >= 0; q--) {
        for(int q = 0; q < 256; q++) {
          fprintf(fptr_loc, "%d", locsram[i][j][q][1]);// locsram[i][j][q][0]);
          for(int itm = 3; itm >= 0; itm--) fprintf(fptr_loc, "%d", (locsram[i][j][q][0] >> itm) & 1);
          if(q < 255)fprintf(fptr_loc, "_");
        }
        fprintf(fptr_loc, "\n");
      }
      fclose(fptr_loc);
    } 

  }
}
