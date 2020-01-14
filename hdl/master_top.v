module master_top #(
parameter Q = 16,
parameter PRO_BW = 8,
parameter NEXT_BW = 4,
parameter K = 16,
parameter VID_BW = 16,
parameter BUF_BW = 5, // log(2*Q)
parameter OFFSET_BW = 5, // 0-16 partial sum
parameter VID_ADDR_SPACE = 5,
parameter LOC_BW = 5,
parameter D = 256,
parameter LOC_ADDR_SPACE = 8 //4 2^16/256
) (
input clk,
input rst_n_in, 
input enable_in,
// inputs 
input [NEXT_BW*Q-1:0] in_next_arr,
input [PRO_BW*K-1:0] in_mi_j, 
input [PRO_BW*K-1:0] in_mj_i, 
input [VID_BW*Q-1:0] in_v_gidx, 
input [PRO_BW*Q-1:0] in_proposal_nums,
input pingpong,
// outputs 
output reg [7:0] epoch,
output reg [K-1:0] vidsram_wen, // 0 at MSB
output reg locsram_wen,
output reg ready,
output reg finish,
// vidsram writing  
output [VID_BW*Q-1:0] vid_sram_wdata0,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr0,
output [VID_BW*Q-1:0] vid_sram_wdata1,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr1,
output [VID_BW*Q-1:0] vid_sram_wdata2,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr2,
output [VID_BW*Q-1:0] vid_sram_wdata3,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr3,
output [VID_BW*Q-1:0] vid_sram_wdata4,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr4,
output [VID_BW*Q-1:0] vid_sram_wdata5,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr5,
output [VID_BW*Q-1:0] vid_sram_wdata6,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr6,
output [VID_BW*Q-1:0] vid_sram_wdata7,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr7,
output [VID_BW*Q-1:0] vid_sram_wdata8,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr8,
output [VID_BW*Q-1:0] vid_sram_wdata9,  output [VID_ADDR_SPACE-1:0] vid_sram_waddr9,
output [VID_BW*Q-1:0] vid_sram_wdata10, output [VID_ADDR_SPACE-1:0] vid_sram_waddr10,
output [VID_BW*Q-1:0] vid_sram_wdata11, output [VID_ADDR_SPACE-1:0] vid_sram_waddr11,
output [VID_BW*Q-1:0] vid_sram_wdata12, output [VID_ADDR_SPACE-1:0] vid_sram_waddr12,
output [VID_BW*Q-1:0] vid_sram_wdata13, output [VID_ADDR_SPACE-1:0] vid_sram_waddr13,
output [VID_BW*Q-1:0] vid_sram_wdata14, output [VID_ADDR_SPACE-1:0] vid_sram_waddr14,
output [VID_BW*Q-1:0] vid_sram_wdata15, output [VID_ADDR_SPACE-1:0] vid_sram_waddr15,
// loc sram writing 
output [D*LOC_BW-1:0] loc_sram_wdata0,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr0,    output [D-1:0] locsram_wbytemask0,
output [D*LOC_BW-1:0] loc_sram_wdata1,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr1,    output [D-1:0] locsram_wbytemask1,
output [D*LOC_BW-1:0] loc_sram_wdata2,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr2,    output [D-1:0] locsram_wbytemask2,
output [D*LOC_BW-1:0] loc_sram_wdata3,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr3,    output [D-1:0] locsram_wbytemask3,
output [D*LOC_BW-1:0] loc_sram_wdata4,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr4,    output [D-1:0] locsram_wbytemask4,
output [D*LOC_BW-1:0] loc_sram_wdata5,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr5,    output [D-1:0] locsram_wbytemask5,
output [D*LOC_BW-1:0] loc_sram_wdata6,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr6,    output [D-1:0] locsram_wbytemask6,
output [D*LOC_BW-1:0] loc_sram_wdata7,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr7,    output [D-1:0] locsram_wbytemask7,
output [D*LOC_BW-1:0] loc_sram_wdata8,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr8,    output [D-1:0] locsram_wbytemask8,
output [D*LOC_BW-1:0] loc_sram_wdata9,  output [LOC_ADDR_SPACE-1:0] loc_sram_waddr9,    output [D-1:0] locsram_wbytemask9,
output [D*LOC_BW-1:0] loc_sram_wdata10, output [LOC_ADDR_SPACE-1:0] loc_sram_waddr10,   output [D-1:0] locsram_wbytemask10,
output [D*LOC_BW-1:0] loc_sram_wdata11, output [LOC_ADDR_SPACE-1:0] loc_sram_waddr11,   output [D-1:0] locsram_wbytemask11,
output [D*LOC_BW-1:0] loc_sram_wdata12, output [LOC_ADDR_SPACE-1:0] loc_sram_waddr12,   output [D-1:0] locsram_wbytemask12,
output [D*LOC_BW-1:0] loc_sram_wdata13, output [LOC_ADDR_SPACE-1:0] loc_sram_waddr13,   output [D-1:0] locsram_wbytemask13,
output [D*LOC_BW-1:0] loc_sram_wdata14, output [LOC_ADDR_SPACE-1:0] loc_sram_waddr14,   output [D-1:0] locsram_wbytemask14,
output [D*LOC_BW-1:0] loc_sram_wdata15, output [LOC_ADDR_SPACE-1:0] loc_sram_waddr15,   output [D-1:0] locsram_wbytemask15
);
// wire pingpong = 0;
localparam IDLE=2'd0, RUNS=2'd1, DELAY=2'd2, FINISH=2'd3;
localparam PSUM_READY = 3;
localparam DONEII = 6;
reg [1:0] nstate, state;
reg rst_n, enable;
// localparam WDATII = 6; // WDATII = PSUM_READY + 3
// epoch[7:4] -> i, current partition
reg [2:0] delay, n_delay;
reg [7:0] n_epoch;
reg [NEXT_BW-1:0] next_arr[0:Q-1];      // register             
reg [PRO_BW-1:0] proposal_nums[0:Q-1];  // register         
reg [PRO_BW-1:0] mi_j[0:K-1];           // register 
reg [PRO_BW-1:0] mj_i[0:K-1];           // register 
reg [NEXT_BW-1:0] real_next_arr[0:Q-1], nreal_next_arr[0:Q-1], buff_1_next[0:Q-1], buff_next[0:Q-1];

// vid sram
// reg [Q*VID_BW-1:0] vidsram_wdata[0:K-1];

reg [Q*VID_BW-1:0] vidsram_wdata_0,vidsram_wdata_1,vidsram_wdata_2,vidsram_wdata_3,vidsram_wdata_4,vidsram_wdata_5,vidsram_wdata_6,vidsram_wdata_7,vidsram_wdata_8,vidsram_wdata_9,vidsram_wdata_10,vidsram_wdata_11,vidsram_wdata_12,vidsram_wdata_13,vidsram_wdata_14,vidsram_wdata_15;

reg [VID_ADDR_SPACE-1:0] vidsram_waddr[0:K-1];
// loc sram
reg [NEXT_BW-1:0] locsram_wdata[0:Q-1];
// reg [D*LOC_BW-1:0] locsram_wdata0,locsram_wdata1,locsram_wdata2,locsram_wdata3,locsram_wdata4;
// reg [D*LOC_BW-1:0] locsram_wdata5,locsram_wdata6,locsram_wdata7,locsram_wdata8,locsram_wdata9;
// reg [D*LOC_BW-1:0] locsram_wdata10,locsram_wdata11,locsram_wdata12,locsram_wdata13,locsram_wdata14,locsram_wdata15;
reg [D-1:0] locsram_wbytemask[0:Q-1], n_locsram_wbytemask[0:Q-1];
reg [LOC_ADDR_SPACE-1:0] locsram_addr[0:Q-1];

// sram wire connect
assign vid_sram_wdata0 = vidsram_wdata_0;    assign vid_sram_waddr0 =   vidsram_waddr[0];   
assign vid_sram_wdata1 = vidsram_wdata_1;    assign vid_sram_waddr1 =   vidsram_waddr[1];   
assign vid_sram_wdata2 = vidsram_wdata_2;    assign vid_sram_waddr2 =   vidsram_waddr[2];   
assign vid_sram_wdata3 = vidsram_wdata_3;    assign vid_sram_waddr3 =   vidsram_waddr[3];   
assign vid_sram_wdata4 = vidsram_wdata_4;    assign vid_sram_waddr4 =   vidsram_waddr[4];   
assign vid_sram_wdata5 = vidsram_wdata_5;    assign vid_sram_waddr5 =   vidsram_waddr[5];   
assign vid_sram_wdata6 = vidsram_wdata_6;    assign vid_sram_waddr6 =   vidsram_waddr[6];   
assign vid_sram_wdata7 = vidsram_wdata_7;    assign vid_sram_waddr7 =   vidsram_waddr[7];   
assign vid_sram_wdata8 = vidsram_wdata_8;    assign vid_sram_waddr8 =   vidsram_waddr[8];   
assign vid_sram_wdata9 = vidsram_wdata_9;    assign vid_sram_waddr9 =   vidsram_waddr[9];   
assign vid_sram_wdata10 = vidsram_wdata_10;  assign vid_sram_waddr10 =  vidsram_waddr[10];       
assign vid_sram_wdata11 = vidsram_wdata_11;  assign vid_sram_waddr11 =  vidsram_waddr[11];       
assign vid_sram_wdata12 = vidsram_wdata_12;  assign vid_sram_waddr12 =  vidsram_waddr[12];       
assign vid_sram_wdata13 = vidsram_wdata_13;  assign vid_sram_waddr13 =  vidsram_waddr[13];       
assign vid_sram_wdata14 = vidsram_wdata_14;  assign vid_sram_waddr14 =  vidsram_waddr[14];       
assign vid_sram_wdata15 = vidsram_wdata_15;  assign vid_sram_waddr15 =  vidsram_waddr[15];       

assign loc_sram_wdata0 = {D{1'b1,locsram_wdata[0]}}  ;  assign loc_sram_waddr0 = locsram_addr[0];
assign loc_sram_wdata1 = {D{1'b1,locsram_wdata[1]}}  ;  assign loc_sram_waddr1 = locsram_addr[1];
assign loc_sram_wdata2 = {D{1'b1,locsram_wdata[2]}}  ;  assign loc_sram_waddr2 = locsram_addr[2];
assign loc_sram_wdata3 = {D{1'b1,locsram_wdata[3]}}  ;  assign loc_sram_waddr3 = locsram_addr[3];
assign loc_sram_wdata4 = {D{1'b1,locsram_wdata[4]}}  ;  assign loc_sram_waddr4 = locsram_addr[4];
assign loc_sram_wdata5 = {D{1'b1,locsram_wdata[5]}}  ;  assign loc_sram_waddr5 = locsram_addr[5];
assign loc_sram_wdata6 = {D{1'b1,locsram_wdata[6]}}  ;  assign loc_sram_waddr6 = locsram_addr[6];
assign loc_sram_wdata7 = {D{1'b1,locsram_wdata[7]}}  ;  assign loc_sram_waddr7 = locsram_addr[7];
assign loc_sram_wdata8 = {D{1'b1,locsram_wdata[8]}}  ;  assign loc_sram_waddr8 = locsram_addr[8];
assign loc_sram_wdata9 = {D{1'b1,locsram_wdata[9]}}  ;  assign loc_sram_waddr9 = locsram_addr[9];
assign loc_sram_wdata10 = {D{1'b1,locsram_wdata[10]}};  assign loc_sram_waddr10 = locsram_addr[10];
assign loc_sram_wdata11 = {D{1'b1,locsram_wdata[11]}};  assign loc_sram_waddr11 = locsram_addr[11];
assign loc_sram_wdata12 = {D{1'b1,locsram_wdata[12]}};  assign loc_sram_waddr12 = locsram_addr[12];
assign loc_sram_wdata13 = {D{1'b1,locsram_wdata[13]}};  assign loc_sram_waddr13 = locsram_addr[13];
assign loc_sram_wdata14 = {D{1'b1,locsram_wdata[14]}};  assign loc_sram_waddr14 = locsram_addr[14];
assign loc_sram_wdata15 = {D{1'b1,locsram_wdata[15]}};  assign loc_sram_waddr15 = locsram_addr[15];

assign locsram_wbytemask0 = locsram_wbytemask[0];
assign locsram_wbytemask1 = locsram_wbytemask[1];
assign locsram_wbytemask2 = locsram_wbytemask[2];
assign locsram_wbytemask3 = locsram_wbytemask[3];
assign locsram_wbytemask4 = locsram_wbytemask[4];
assign locsram_wbytemask5 = locsram_wbytemask[5];
assign locsram_wbytemask6 = locsram_wbytemask[6];
assign locsram_wbytemask7 = locsram_wbytemask[7];
assign locsram_wbytemask8 = locsram_wbytemask[8];
assign locsram_wbytemask9 = locsram_wbytemask[9];
assign locsram_wbytemask10 = locsram_wbytemask[10];
assign locsram_wbytemask11 = locsram_wbytemask[11];
assign locsram_wbytemask12 = locsram_wbytemask[12];
assign locsram_wbytemask13 = locsram_wbytemask[13];
assign locsram_wbytemask14 = locsram_wbytemask[14];
assign locsram_wbytemask15 = locsram_wbytemask[15];
// ================================================
// TOOD: prepare: next_arr, mi_j, mj_i, v_gidx , proposal_nums

// ================================================
reg [VID_BW-1:0] v_gidx[0:Q-1]; // registers, from vid sram
// K buffers, each of Q 
// reg [VID_BW-1:0] buffer [0:K-1] [0:2*Q-1], n_buffer[0:K-1][0:2*Q-1];
reg [VID_BW-1:0] buffer_0[0:2*Q-1],buffer_1[0:2*Q-1],buffer_2[0:2*Q-1],buffer_3[0:2*Q-1],
buffer_4[0:2*Q-1],buffer_5[0:2*Q-1],buffer_6[0:2*Q-1],buffer_7[0:2*Q-1],
buffer_8[0:2*Q-1],buffer_9[0:2*Q-1],buffer_10[0:2*Q-1],buffer_11[0:2*Q-1],
buffer_12[0:2*Q-1],buffer_13[0:2*Q-1],buffer_14[0:2*Q-1],buffer_15[0:2*Q-1];
reg [VID_BW-1:0] n_buffer_0[0:2*Q-1],n_buffer_1[0:2*Q-1],n_buffer_2[0:2*Q-1],n_buffer_3[0:2*Q-1],
n_buffer_4[0:2*Q-1],n_buffer_5[0:2*Q-1],n_buffer_6[0:2*Q-1],n_buffer_7[0:2*Q-1],
n_buffer_8[0:2*Q-1],n_buffer_9[0:2*Q-1],n_buffer_10[0:2*Q-1],n_buffer_11[0:2*Q-1],
n_buffer_12[0:2*Q-1],n_buffer_13[0:2*Q-1],n_buffer_14[0:2*Q-1],n_buffer_15[0:2*Q-1];

reg [BUF_BW-1:0] accum[0:K-1], n_accum[0:K-1]; // buffer size for each of K buffers
reg [BUF_BW-1:0] buffer_idx[0:Q-1], nbuffer_idx[0:Q-1]; // additioanl bit??
reg export[0:K-1], n_export[0:K-1];
reg [BUF_BW-1:0] buffaccum[0:K-1], n_buffaccum[0:K-1]; // for buffer indexing's accum
reg [K-1:0] onehot[0:Q-1];
reg [OFFSET_BW-1:0] partial_sum[0:Q-1][0:K-1],n_partial_sum[0:Q-1][0:K-1];
reg psum_set, n_psum_set;
integer o_idx, in_idx;
integer accumidx;
integer partial_i, partial_j, check_i;
integer buffi,buffj;

always @* begin 
    if(~enable) n_psum_set = 0;
    else begin 
        if(state == RUNS && epoch == PSUM_READY) n_psum_set = 1;
        else n_psum_set = psum_set;
    end 
    if(~enable) n_delay = 0;
    else begin 
        if(state == DELAY)  n_delay = delay + 1;
        else                n_delay = delay;
    end 
    if(~enable) n_epoch = 0;
    else begin 
        if(state == RUNS && epoch < 8'd255) n_epoch = epoch + 1;
        else              n_epoch = epoch; 
    end 

    for(o_idx = 0; o_idx < Q; o_idx = o_idx + 1) begin 
        for(in_idx = 0; in_idx < K; in_idx = in_idx + 1) begin
            onehot[o_idx][in_idx] = real_next_arr[o_idx] == in_idx;
        end 
    end 
    
    for(partial_j = 0; partial_j < K; partial_j = partial_j + 1) begin
        n_partial_sum[0][partial_j] =  onehot[0][partial_j];
        n_partial_sum[1][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j];
        n_partial_sum[2][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j];
        n_partial_sum[3][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j];
        n_partial_sum[4][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j];
        n_partial_sum[5][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j];
        n_partial_sum[6][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j];
        n_partial_sum[7][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j];
        n_partial_sum[8][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j];
        n_partial_sum[9][partial_j] =  onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j];
        n_partial_sum[10][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j];
        n_partial_sum[11][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j];
        n_partial_sum[12][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j]+onehot[12][partial_j];
        n_partial_sum[13][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j]+onehot[12][partial_j]+onehot[13][partial_j];
        n_partial_sum[14][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j]+onehot[12][partial_j]+onehot[13][partial_j]+onehot[14][partial_j];
        n_partial_sum[15][partial_j] = onehot[0][partial_j]+onehot[1][partial_j]+onehot[2][partial_j]+onehot[3][partial_j]+onehot[4][partial_j]+onehot[5][partial_j]+onehot[6][partial_j]+onehot[7][partial_j]+onehot[8][partial_j]+onehot[9][partial_j]+onehot[10][partial_j]+onehot[11][partial_j]+onehot[12][partial_j]+onehot[13][partial_j]+onehot[14][partial_j]+onehot[15][partial_j];
    
    end 
    // ----------- same time to write into ----------------
    for(partial_i = 0; partial_i < Q; partial_i = partial_i + 1) begin
        if(psum_set) 
        nbuffer_idx[partial_i] = (partial_sum[partial_i][buff_1_next[partial_i]] - 1) + (accum[buff_1_next[partial_i]] >= Q ? accum[buff_1_next[partial_i]] - Q : accum[buff_1_next[partial_i]]) ;
        else 
        nbuffer_idx[partial_i] = buffer_idx[partial_i];
        // TODO: accum[q] == Q also update to partial_sum[15][q], / transfer out 
    end
       
    for(accumidx = 0; accumidx < K; accumidx = accumidx + 1) begin 
        n_buffaccum[accumidx] = accum[accumidx] >= Q ? accum[accumidx] - Q : accum[accumidx]; // retain the offset that to be FIFOed

        if(psum_set) begin 
            if(accum[accumidx] >= 5'd16) begin 
                n_accum[accumidx] = accum[accumidx] - 5'd16 + partial_sum[Q-1][accumidx]; // partial sum !!!! ;// check_acc[accumidx] - Q;
                n_export[accumidx] = 1;
            end else begin 
                n_accum[accumidx] = accum[accumidx] + partial_sum[Q-1][accumidx];//accum[accumidx];//check_acc[accumidx];
                n_export[accumidx] = 0;
            end
        end else begin 
            n_export[accumidx] = export[accumidx];
            n_accum[accumidx] = accum[accumidx];
        end  
    
    end 
    // -------------------------------------------
    // for(buffi = 0; buffi < K; buffi = buffi + 1) begin 
    //     for(buffj = 0; buffj < 2*Q; buffj = buffj + 1) begin  
    //         if(psum_set) begin 
    //             if(buffj < Q && export[buffi] == 1 && buffj < buffaccum[buffi]) begin 
    //                 // shift 
    //                 n_buffer[buffi][buffj] = buffer[buffi][buffj + Q];
    //             end else begin 
    //                 // take new 
    //                 if(buffj < buffaccum[buffi]) begin
    //                     n_buffer[buffi][buffj] = buffer[buffi][buffj]; 
    //                 end else begin 
    //                     n_buffer[buffi][buffj] =
    //                                         ((buff_next[0] == buffi) * (buffer_idx[0] == buffj) * v_gidx[0]) |
    //                                         ((buff_next[1] == buffi) * (buffer_idx[1] == buffj) * v_gidx[1]) |
    //                                         ((buff_next[2] == buffi) * (buffer_idx[2] == buffj) * v_gidx[2]) |
    //                                         ((buff_next[3] == buffi) * (buffer_idx[3] == buffj) * v_gidx[3]) |
    //                                         ((buff_next[4] == buffi) * (buffer_idx[4] == buffj) * v_gidx[4]) |
    //                                         ((buff_next[5] == buffi) * (buffer_idx[5] == buffj) * v_gidx[5]) |
    //                                         ((buff_next[6] == buffi) * (buffer_idx[6] == buffj) * v_gidx[6]) |
    //                                         ((buff_next[7] == buffi) * (buffer_idx[7] == buffj) * v_gidx[7]) |
    //                                         ((buff_next[8] == buffi) * (buffer_idx[8] == buffj) * v_gidx[8]) |
    //                                         ((buff_next[9] == buffi) * (buffer_idx[9] == buffj) * v_gidx[9]) |
    //                                         ((buff_next[10] == buffi) * (buffer_idx[10] == buffj) * v_gidx[10]) |
    //                                         ((buff_next[11] == buffi) * (buffer_idx[11] == buffj) * v_gidx[11]) |
    //                                         ((buff_next[12] == buffi) * (buffer_idx[12] == buffj) * v_gidx[12]) |
    //                                         ((buff_next[13] == buffi) * (buffer_idx[13] == buffj) * v_gidx[13]) |
    //                                         ((buff_next[14] == buffi) * (buffer_idx[14] == buffj) * v_gidx[14]) |
    //                                         ((buff_next[15] == buffi) * (buffer_idx[15] == buffj) * v_gidx[15]);
    //                 end 
    //             end 
    //         end else begin 
    //             n_buffer[buffi][buffj] = buffer[buffi][buffj];
    //         end 
    //     end 
    // end 
end 


// handle n_buffer_0~15[0:31]
always @* begin
    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd0) begin 
            n_buffer_0[0] = buffer_0[0 + Q];
        end else begin 
            if(buffaccum[0] > 5'd0) 
                n_buffer_0[0] = buffer_0[0]; 
            else  
                n_buffer_0[0] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[0] = buffer_0[0];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd1) begin 
            n_buffer_0[1] = buffer_0[1 + Q];
        end else begin 
            if(buffaccum[0] > 5'd1) 
                n_buffer_0[1] = buffer_0[1]; 
            else  
                n_buffer_0[1] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[1] = buffer_0[1];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd2) begin 
            n_buffer_0[2] = buffer_0[2 + Q];
        end else begin 
            if(buffaccum[0] > 5'd2) 
                n_buffer_0[2] = buffer_0[2]; 
            else  
                n_buffer_0[2] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[2] = buffer_0[2];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd3) begin 
            n_buffer_0[3] = buffer_0[3 + Q];
        end else begin 
            if(buffaccum[0] > 5'd3) 
                n_buffer_0[3] = buffer_0[3]; 
            else  
                n_buffer_0[3] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[3] = buffer_0[3];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd4) begin 
            n_buffer_0[4] = buffer_0[4 + Q];
        end else begin 
            if(buffaccum[0] > 5'd4) 
                n_buffer_0[4] = buffer_0[4]; 
            else  
                n_buffer_0[4] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[4] = buffer_0[4];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd5) begin 
            n_buffer_0[5] = buffer_0[5 + Q];
        end else begin 
            if(buffaccum[0] > 5'd5) 
                n_buffer_0[5] = buffer_0[5]; 
            else  
                n_buffer_0[5] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[5] = buffer_0[5];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd6) begin 
            n_buffer_0[6] = buffer_0[6 + Q];
        end else begin 
            if(buffaccum[0] > 5'd6) 
                n_buffer_0[6] = buffer_0[6]; 
            else  
                n_buffer_0[6] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[6] = buffer_0[6];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd7) begin 
            n_buffer_0[7] = buffer_0[7 + Q];
        end else begin 
            if(buffaccum[0] > 5'd7) 
                n_buffer_0[7] = buffer_0[7]; 
            else  
                n_buffer_0[7] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[7] = buffer_0[7];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd8) begin 
            n_buffer_0[8] = buffer_0[8 + Q];
        end else begin 
            if(buffaccum[0] > 5'd8) 
                n_buffer_0[8] = buffer_0[8]; 
            else  
                n_buffer_0[8] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[8] = buffer_0[8];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd9) begin 
            n_buffer_0[9] = buffer_0[9 + Q];
        end else begin 
            if(buffaccum[0] > 5'd9) 
                n_buffer_0[9] = buffer_0[9]; 
            else  
                n_buffer_0[9] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[9] = buffer_0[9];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd10) begin 
            n_buffer_0[10] = buffer_0[10 + Q];
        end else begin 
            if(buffaccum[0] > 5'd10) 
                n_buffer_0[10] = buffer_0[10]; 
            else  
                n_buffer_0[10] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[10] = buffer_0[10];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd11) begin 
            n_buffer_0[11] = buffer_0[11 + Q];
        end else begin 
            if(buffaccum[0] > 5'd11) 
                n_buffer_0[11] = buffer_0[11]; 
            else  
                n_buffer_0[11] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[11] = buffer_0[11];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd12) begin 
            n_buffer_0[12] = buffer_0[12 + Q];
        end else begin 
            if(buffaccum[0] > 5'd12) 
                n_buffer_0[12] = buffer_0[12]; 
            else  
                n_buffer_0[12] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[12] = buffer_0[12];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd13) begin 
            n_buffer_0[13] = buffer_0[13 + Q];
        end else begin 
            if(buffaccum[0] > 5'd13) 
                n_buffer_0[13] = buffer_0[13]; 
            else  
                n_buffer_0[13] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[13] = buffer_0[13];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd14) begin 
            n_buffer_0[14] = buffer_0[14 + Q];
        end else begin 
            if(buffaccum[0] > 5'd14) 
                n_buffer_0[14] = buffer_0[14]; 
            else  
                n_buffer_0[14] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[14] = buffer_0[14];


    if(psum_set) begin 
        if(export[0] == 1'b1 && buffaccum[0] > 5'd15) begin 
            n_buffer_0[15] = buffer_0[15 + Q];
        end else begin 
            if(buffaccum[0] > 5'd15) 
                n_buffer_0[15] = buffer_0[15]; 
            else  
                n_buffer_0[15] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_0[15] = buffer_0[15];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd16) 
            n_buffer_0[16] = buffer_0[16]; 
        else  
            n_buffer_0[16] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_0[16] = buffer_0[16];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd17) 
            n_buffer_0[17] = buffer_0[17]; 
        else  
            n_buffer_0[17] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_0[17] = buffer_0[17];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd18) 
            n_buffer_0[18] = buffer_0[18]; 
        else  
            n_buffer_0[18] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_0[18] = buffer_0[18];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd19) 
            n_buffer_0[19] = buffer_0[19]; 
        else  
            n_buffer_0[19] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_0[19] = buffer_0[19];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd20) 
            n_buffer_0[20] = buffer_0[20]; 
        else  
            n_buffer_0[20] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_0[20] = buffer_0[20];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd21) 
            n_buffer_0[21] = buffer_0[21]; 
        else  
            n_buffer_0[21] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_0[21] = buffer_0[21];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd22) 
            n_buffer_0[22] = buffer_0[22]; 
        else  
            n_buffer_0[22] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_0[22] = buffer_0[22];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd23) 
            n_buffer_0[23] = buffer_0[23]; 
        else  
            n_buffer_0[23] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_0[23] = buffer_0[23];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd24) 
            n_buffer_0[24] = buffer_0[24]; 
        else  
            n_buffer_0[24] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_0[24] = buffer_0[24];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd25) 
            n_buffer_0[25] = buffer_0[25]; 
        else  
            n_buffer_0[25] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_0[25] = buffer_0[25];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd26) 
            n_buffer_0[26] = buffer_0[26]; 
        else  
            n_buffer_0[26] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_0[26] = buffer_0[26];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd27) 
            n_buffer_0[27] = buffer_0[27]; 
        else  
            n_buffer_0[27] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_0[27] = buffer_0[27];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd28) 
            n_buffer_0[28] = buffer_0[28]; 
        else  
            n_buffer_0[28] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_0[28] = buffer_0[28];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd29) 
            n_buffer_0[29] = buffer_0[29]; 
        else  
            n_buffer_0[29] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_0[29] = buffer_0[29];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd30) 
            n_buffer_0[30] = buffer_0[30]; 
        else  
            n_buffer_0[30] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_0[30] = buffer_0[30];


    if(psum_set) begin 
        if(buffaccum[0] > 5'd31) 
            n_buffer_0[31] = buffer_0[31]; 
        else  
            n_buffer_0[31] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_0[31] = buffer_0[31];

    //============================

    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd0) begin 
            n_buffer_1[0] = buffer_1[0 + Q];
        end else begin 
            if(buffaccum[1] > 5'd0) 
                n_buffer_1[0] = buffer_1[0]; 
            else  
                n_buffer_1[0] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[0] = buffer_1[0];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd1) begin 
            n_buffer_1[1] = buffer_1[1 + Q];
        end else begin 
            if(buffaccum[1] > 5'd1) 
                n_buffer_1[1] = buffer_1[1]; 
            else  
                n_buffer_1[1] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[1] = buffer_1[1];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd2) begin 
            n_buffer_1[2] = buffer_1[2 + Q];
        end else begin 
            if(buffaccum[1] > 5'd2) 
                n_buffer_1[2] = buffer_1[2]; 
            else  
                n_buffer_1[2] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[2] = buffer_1[2];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd3) begin 
            n_buffer_1[3] = buffer_1[3 + Q];
        end else begin 
            if(buffaccum[1] > 5'd3) 
                n_buffer_1[3] = buffer_1[3]; 
            else  
                n_buffer_1[3] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[3] = buffer_1[3];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd4) begin 
            n_buffer_1[4] = buffer_1[4 + Q];
        end else begin 
            if(buffaccum[1] > 5'd4) 
                n_buffer_1[4] = buffer_1[4]; 
            else  
                n_buffer_1[4] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[4] = buffer_1[4];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd5) begin 
            n_buffer_1[5] = buffer_1[5 + Q];
        end else begin 
            if(buffaccum[1] > 5'd5) 
                n_buffer_1[5] = buffer_1[5]; 
            else  
                n_buffer_1[5] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[5] = buffer_1[5];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd6) begin 
            n_buffer_1[6] = buffer_1[6 + Q];
        end else begin 
            if(buffaccum[1] > 5'd6) 
                n_buffer_1[6] = buffer_1[6]; 
            else  
                n_buffer_1[6] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[6] = buffer_1[6];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd7) begin 
            n_buffer_1[7] = buffer_1[7 + Q];
        end else begin 
            if(buffaccum[1] > 5'd7) 
                n_buffer_1[7] = buffer_1[7]; 
            else  
                n_buffer_1[7] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[7] = buffer_1[7];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd8) begin 
            n_buffer_1[8] = buffer_1[8 + Q];
        end else begin 
            if(buffaccum[1] > 5'd8) 
                n_buffer_1[8] = buffer_1[8]; 
            else  
                n_buffer_1[8] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[8] = buffer_1[8];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd9) begin 
            n_buffer_1[9] = buffer_1[9 + Q];
        end else begin 
            if(buffaccum[1] > 5'd9) 
                n_buffer_1[9] = buffer_1[9]; 
            else  
                n_buffer_1[9] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[9] = buffer_1[9];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd10) begin 
            n_buffer_1[10] = buffer_1[10 + Q];
        end else begin 
            if(buffaccum[1] > 5'd10) 
                n_buffer_1[10] = buffer_1[10]; 
            else  
                n_buffer_1[10] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[10] = buffer_1[10];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd11) begin 
            n_buffer_1[11] = buffer_1[11 + Q];
        end else begin 
            if(buffaccum[1] > 5'd11) 
                n_buffer_1[11] = buffer_1[11]; 
            else  
                n_buffer_1[11] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[11] = buffer_1[11];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd12) begin 
            n_buffer_1[12] = buffer_1[12 + Q];
        end else begin 
            if(buffaccum[1] > 5'd12) 
                n_buffer_1[12] = buffer_1[12]; 
            else  
                n_buffer_1[12] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[12] = buffer_1[12];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd13) begin 
            n_buffer_1[13] = buffer_1[13 + Q];
        end else begin 
            if(buffaccum[1] > 5'd13) 
                n_buffer_1[13] = buffer_1[13]; 
            else  
                n_buffer_1[13] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[13] = buffer_1[13];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd14) begin 
            n_buffer_1[14] = buffer_1[14 + Q];
        end else begin 
            if(buffaccum[1] > 5'd14) 
                n_buffer_1[14] = buffer_1[14]; 
            else  
                n_buffer_1[14] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[14] = buffer_1[14];


    if(psum_set) begin 
        if(export[1] == 1'b1 && buffaccum[1] > 5'd15) begin 
            n_buffer_1[15] = buffer_1[15 + Q];
        end else begin 
            if(buffaccum[1] > 5'd15) 
                n_buffer_1[15] = buffer_1[15]; 
            else  
                n_buffer_1[15] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_1[15] = buffer_1[15];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd16) 
            n_buffer_1[16] = buffer_1[16]; 
        else  
            n_buffer_1[16] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_1[16] = buffer_1[16];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd17) 
            n_buffer_1[17] = buffer_1[17]; 
        else  
            n_buffer_1[17] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_1[17] = buffer_1[17];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd18) 
            n_buffer_1[18] = buffer_1[18]; 
        else  
            n_buffer_1[18] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_1[18] = buffer_1[18];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd19) 
            n_buffer_1[19] = buffer_1[19]; 
        else  
            n_buffer_1[19] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_1[19] = buffer_1[19];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd20) 
            n_buffer_1[20] = buffer_1[20]; 
        else  
            n_buffer_1[20] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_1[20] = buffer_1[20];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd21) 
            n_buffer_1[21] = buffer_1[21]; 
        else  
            n_buffer_1[21] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_1[21] = buffer_1[21];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd22) 
            n_buffer_1[22] = buffer_1[22]; 
        else  
            n_buffer_1[22] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_1[22] = buffer_1[22];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd23) 
            n_buffer_1[23] = buffer_1[23]; 
        else  
            n_buffer_1[23] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_1[23] = buffer_1[23];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd24) 
            n_buffer_1[24] = buffer_1[24]; 
        else  
            n_buffer_1[24] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_1[24] = buffer_1[24];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd25) 
            n_buffer_1[25] = buffer_1[25]; 
        else  
            n_buffer_1[25] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_1[25] = buffer_1[25];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd26) 
            n_buffer_1[26] = buffer_1[26]; 
        else  
            n_buffer_1[26] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_1[26] = buffer_1[26];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd27) 
            n_buffer_1[27] = buffer_1[27]; 
        else  
            n_buffer_1[27] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_1[27] = buffer_1[27];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd28) 
            n_buffer_1[28] = buffer_1[28]; 
        else  
            n_buffer_1[28] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_1[28] = buffer_1[28];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd29) 
            n_buffer_1[29] = buffer_1[29]; 
        else  
            n_buffer_1[29] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_1[29] = buffer_1[29];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd30) 
            n_buffer_1[30] = buffer_1[30]; 
        else  
            n_buffer_1[30] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_1[30] = buffer_1[30];


    if(psum_set) begin 
        if(buffaccum[1] > 5'd31) 
            n_buffer_1[31] = buffer_1[31]; 
        else  
            n_buffer_1[31] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_1[31] = buffer_1[31];

    //============================

    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd0) begin 
            n_buffer_2[0] = buffer_2[0 + Q];
        end else begin 
            if(buffaccum[2] > 5'd0) 
                n_buffer_2[0] = buffer_2[0]; 
            else  
                n_buffer_2[0] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[0] = buffer_2[0];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd1) begin 
            n_buffer_2[1] = buffer_2[1 + Q];
        end else begin 
            if(buffaccum[2] > 5'd1) 
                n_buffer_2[1] = buffer_2[1]; 
            else  
                n_buffer_2[1] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[1] = buffer_2[1];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd2) begin 
            n_buffer_2[2] = buffer_2[2 + Q];
        end else begin 
            if(buffaccum[2] > 5'd2) 
                n_buffer_2[2] = buffer_2[2]; 
            else  
                n_buffer_2[2] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[2] = buffer_2[2];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd3) begin 
            n_buffer_2[3] = buffer_2[3 + Q];
        end else begin 
            if(buffaccum[2] > 5'd3) 
                n_buffer_2[3] = buffer_2[3]; 
            else  
                n_buffer_2[3] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[3] = buffer_2[3];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd4) begin 
            n_buffer_2[4] = buffer_2[4 + Q];
        end else begin 
            if(buffaccum[2] > 5'd4) 
                n_buffer_2[4] = buffer_2[4]; 
            else  
                n_buffer_2[4] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[4] = buffer_2[4];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd5) begin 
            n_buffer_2[5] = buffer_2[5 + Q];
        end else begin 
            if(buffaccum[2] > 5'd5) 
                n_buffer_2[5] = buffer_2[5]; 
            else  
                n_buffer_2[5] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[5] = buffer_2[5];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd6) begin 
            n_buffer_2[6] = buffer_2[6 + Q];
        end else begin 
            if(buffaccum[2] > 5'd6) 
                n_buffer_2[6] = buffer_2[6]; 
            else  
                n_buffer_2[6] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[6] = buffer_2[6];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd7) begin 
            n_buffer_2[7] = buffer_2[7 + Q];
        end else begin 
            if(buffaccum[2] > 5'd7) 
                n_buffer_2[7] = buffer_2[7]; 
            else  
                n_buffer_2[7] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[7] = buffer_2[7];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd8) begin 
            n_buffer_2[8] = buffer_2[8 + Q];
        end else begin 
            if(buffaccum[2] > 5'd8) 
                n_buffer_2[8] = buffer_2[8]; 
            else  
                n_buffer_2[8] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[8] = buffer_2[8];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd9) begin 
            n_buffer_2[9] = buffer_2[9 + Q];
        end else begin 
            if(buffaccum[2] > 5'd9) 
                n_buffer_2[9] = buffer_2[9]; 
            else  
                n_buffer_2[9] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[9] = buffer_2[9];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd10) begin 
            n_buffer_2[10] = buffer_2[10 + Q];
        end else begin 
            if(buffaccum[2] > 5'd10) 
                n_buffer_2[10] = buffer_2[10]; 
            else  
                n_buffer_2[10] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[10] = buffer_2[10];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd11) begin 
            n_buffer_2[11] = buffer_2[11 + Q];
        end else begin 
            if(buffaccum[2] > 5'd11) 
                n_buffer_2[11] = buffer_2[11]; 
            else  
                n_buffer_2[11] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[11] = buffer_2[11];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd12) begin 
            n_buffer_2[12] = buffer_2[12 + Q];
        end else begin 
            if(buffaccum[2] > 5'd12) 
                n_buffer_2[12] = buffer_2[12]; 
            else  
                n_buffer_2[12] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[12] = buffer_2[12];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd13) begin 
            n_buffer_2[13] = buffer_2[13 + Q];
        end else begin 
            if(buffaccum[2] > 5'd13) 
                n_buffer_2[13] = buffer_2[13]; 
            else  
                n_buffer_2[13] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[13] = buffer_2[13];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd14) begin 
            n_buffer_2[14] = buffer_2[14 + Q];
        end else begin 
            if(buffaccum[2] > 5'd14) 
                n_buffer_2[14] = buffer_2[14]; 
            else  
                n_buffer_2[14] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[14] = buffer_2[14];


    if(psum_set) begin 
        if(export[2] == 1'b1 && buffaccum[2] > 5'd15) begin 
            n_buffer_2[15] = buffer_2[15 + Q];
        end else begin 
            if(buffaccum[2] > 5'd15) 
                n_buffer_2[15] = buffer_2[15]; 
            else  
                n_buffer_2[15] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_2[15] = buffer_2[15];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd16) 
            n_buffer_2[16] = buffer_2[16]; 
        else  
            n_buffer_2[16] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_2[16] = buffer_2[16];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd17) 
            n_buffer_2[17] = buffer_2[17]; 
        else  
            n_buffer_2[17] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_2[17] = buffer_2[17];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd18) 
            n_buffer_2[18] = buffer_2[18]; 
        else  
            n_buffer_2[18] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_2[18] = buffer_2[18];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd19) 
            n_buffer_2[19] = buffer_2[19]; 
        else  
            n_buffer_2[19] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_2[19] = buffer_2[19];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd20) 
            n_buffer_2[20] = buffer_2[20]; 
        else  
            n_buffer_2[20] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_2[20] = buffer_2[20];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd21) 
            n_buffer_2[21] = buffer_2[21]; 
        else  
            n_buffer_2[21] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_2[21] = buffer_2[21];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd22) 
            n_buffer_2[22] = buffer_2[22]; 
        else  
            n_buffer_2[22] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_2[22] = buffer_2[22];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd23) 
            n_buffer_2[23] = buffer_2[23]; 
        else  
            n_buffer_2[23] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_2[23] = buffer_2[23];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd24) 
            n_buffer_2[24] = buffer_2[24]; 
        else  
            n_buffer_2[24] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_2[24] = buffer_2[24];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd25) 
            n_buffer_2[25] = buffer_2[25]; 
        else  
            n_buffer_2[25] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_2[25] = buffer_2[25];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd26) 
            n_buffer_2[26] = buffer_2[26]; 
        else  
            n_buffer_2[26] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_2[26] = buffer_2[26];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd27) 
            n_buffer_2[27] = buffer_2[27]; 
        else  
            n_buffer_2[27] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_2[27] = buffer_2[27];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd28) 
            n_buffer_2[28] = buffer_2[28]; 
        else  
            n_buffer_2[28] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_2[28] = buffer_2[28];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd29) 
            n_buffer_2[29] = buffer_2[29]; 
        else  
            n_buffer_2[29] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_2[29] = buffer_2[29];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd30) 
            n_buffer_2[30] = buffer_2[30]; 
        else  
            n_buffer_2[30] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_2[30] = buffer_2[30];


    if(psum_set) begin 
        if(buffaccum[2] > 5'd31) 
            n_buffer_2[31] = buffer_2[31]; 
        else  
            n_buffer_2[31] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_2[31] = buffer_2[31];

    //============================

    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd0) begin 
            n_buffer_3[0] = buffer_3[0 + Q];
        end else begin 
            if(buffaccum[3] > 5'd0) 
                n_buffer_3[0] = buffer_3[0]; 
            else  
                n_buffer_3[0] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[0] = buffer_3[0];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd1) begin 
            n_buffer_3[1] = buffer_3[1 + Q];
        end else begin 
            if(buffaccum[3] > 5'd1) 
                n_buffer_3[1] = buffer_3[1]; 
            else  
                n_buffer_3[1] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[1] = buffer_3[1];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd2) begin 
            n_buffer_3[2] = buffer_3[2 + Q];
        end else begin 
            if(buffaccum[3] > 5'd2) 
                n_buffer_3[2] = buffer_3[2]; 
            else  
                n_buffer_3[2] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[2] = buffer_3[2];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd3) begin 
            n_buffer_3[3] = buffer_3[3 + Q];
        end else begin 
            if(buffaccum[3] > 5'd3) 
                n_buffer_3[3] = buffer_3[3]; 
            else  
                n_buffer_3[3] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[3] = buffer_3[3];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd4) begin 
            n_buffer_3[4] = buffer_3[4 + Q];
        end else begin 
            if(buffaccum[3] > 5'd4) 
                n_buffer_3[4] = buffer_3[4]; 
            else  
                n_buffer_3[4] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[4] = buffer_3[4];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd5) begin 
            n_buffer_3[5] = buffer_3[5 + Q];
        end else begin 
            if(buffaccum[3] > 5'd5) 
                n_buffer_3[5] = buffer_3[5]; 
            else  
                n_buffer_3[5] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[5] = buffer_3[5];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd6) begin 
            n_buffer_3[6] = buffer_3[6 + Q];
        end else begin 
            if(buffaccum[3] > 5'd6) 
                n_buffer_3[6] = buffer_3[6]; 
            else  
                n_buffer_3[6] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[6] = buffer_3[6];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd7) begin 
            n_buffer_3[7] = buffer_3[7 + Q];
        end else begin 
            if(buffaccum[3] > 5'd7) 
                n_buffer_3[7] = buffer_3[7]; 
            else  
                n_buffer_3[7] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[7] = buffer_3[7];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd8) begin 
            n_buffer_3[8] = buffer_3[8 + Q];
        end else begin 
            if(buffaccum[3] > 5'd8) 
                n_buffer_3[8] = buffer_3[8]; 
            else  
                n_buffer_3[8] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[8] = buffer_3[8];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd9) begin 
            n_buffer_3[9] = buffer_3[9 + Q];
        end else begin 
            if(buffaccum[3] > 5'd9) 
                n_buffer_3[9] = buffer_3[9]; 
            else  
                n_buffer_3[9] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[9] = buffer_3[9];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd10) begin 
            n_buffer_3[10] = buffer_3[10 + Q];
        end else begin 
            if(buffaccum[3] > 5'd10) 
                n_buffer_3[10] = buffer_3[10]; 
            else  
                n_buffer_3[10] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[10] = buffer_3[10];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd11) begin 
            n_buffer_3[11] = buffer_3[11 + Q];
        end else begin 
            if(buffaccum[3] > 5'd11) 
                n_buffer_3[11] = buffer_3[11]; 
            else  
                n_buffer_3[11] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[11] = buffer_3[11];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd12) begin 
            n_buffer_3[12] = buffer_3[12 + Q];
        end else begin 
            if(buffaccum[3] > 5'd12) 
                n_buffer_3[12] = buffer_3[12]; 
            else  
                n_buffer_3[12] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[12] = buffer_3[12];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd13) begin 
            n_buffer_3[13] = buffer_3[13 + Q];
        end else begin 
            if(buffaccum[3] > 5'd13) 
                n_buffer_3[13] = buffer_3[13]; 
            else  
                n_buffer_3[13] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[13] = buffer_3[13];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd14) begin 
            n_buffer_3[14] = buffer_3[14 + Q];
        end else begin 
            if(buffaccum[3] > 5'd14) 
                n_buffer_3[14] = buffer_3[14]; 
            else  
                n_buffer_3[14] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[14] = buffer_3[14];


    if(psum_set) begin 
        if(export[3] == 1'b1 && buffaccum[3] > 5'd15) begin 
            n_buffer_3[15] = buffer_3[15 + Q];
        end else begin 
            if(buffaccum[3] > 5'd15) 
                n_buffer_3[15] = buffer_3[15]; 
            else  
                n_buffer_3[15] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_3[15] = buffer_3[15];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd16) 
            n_buffer_3[16] = buffer_3[16]; 
        else  
            n_buffer_3[16] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_3[16] = buffer_3[16];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd17) 
            n_buffer_3[17] = buffer_3[17]; 
        else  
            n_buffer_3[17] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_3[17] = buffer_3[17];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd18) 
            n_buffer_3[18] = buffer_3[18]; 
        else  
            n_buffer_3[18] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_3[18] = buffer_3[18];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd19) 
            n_buffer_3[19] = buffer_3[19]; 
        else  
            n_buffer_3[19] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_3[19] = buffer_3[19];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd20) 
            n_buffer_3[20] = buffer_3[20]; 
        else  
            n_buffer_3[20] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_3[20] = buffer_3[20];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd21) 
            n_buffer_3[21] = buffer_3[21]; 
        else  
            n_buffer_3[21] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_3[21] = buffer_3[21];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd22) 
            n_buffer_3[22] = buffer_3[22]; 
        else  
            n_buffer_3[22] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_3[22] = buffer_3[22];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd23) 
            n_buffer_3[23] = buffer_3[23]; 
        else  
            n_buffer_3[23] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_3[23] = buffer_3[23];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd24) 
            n_buffer_3[24] = buffer_3[24]; 
        else  
            n_buffer_3[24] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_3[24] = buffer_3[24];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd25) 
            n_buffer_3[25] = buffer_3[25]; 
        else  
            n_buffer_3[25] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_3[25] = buffer_3[25];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd26) 
            n_buffer_3[26] = buffer_3[26]; 
        else  
            n_buffer_3[26] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_3[26] = buffer_3[26];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd27) 
            n_buffer_3[27] = buffer_3[27]; 
        else  
            n_buffer_3[27] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_3[27] = buffer_3[27];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd28) 
            n_buffer_3[28] = buffer_3[28]; 
        else  
            n_buffer_3[28] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_3[28] = buffer_3[28];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd29) 
            n_buffer_3[29] = buffer_3[29]; 
        else  
            n_buffer_3[29] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_3[29] = buffer_3[29];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd30) 
            n_buffer_3[30] = buffer_3[30]; 
        else  
            n_buffer_3[30] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_3[30] = buffer_3[30];


    if(psum_set) begin 
        if(buffaccum[3] > 5'd31) 
            n_buffer_3[31] = buffer_3[31]; 
        else  
            n_buffer_3[31] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_3[31] = buffer_3[31];

    //============================

    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd0) begin 
            n_buffer_4[0] = buffer_4[0 + Q];
        end else begin 
            if(buffaccum[4] > 5'd0) 
                n_buffer_4[0] = buffer_4[0]; 
            else  
                n_buffer_4[0] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[0] = buffer_4[0];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd1) begin 
            n_buffer_4[1] = buffer_4[1 + Q];
        end else begin 
            if(buffaccum[4] > 5'd1) 
                n_buffer_4[1] = buffer_4[1]; 
            else  
                n_buffer_4[1] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[1] = buffer_4[1];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd2) begin 
            n_buffer_4[2] = buffer_4[2 + Q];
        end else begin 
            if(buffaccum[4] > 5'd2) 
                n_buffer_4[2] = buffer_4[2]; 
            else  
                n_buffer_4[2] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[2] = buffer_4[2];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd3) begin 
            n_buffer_4[3] = buffer_4[3 + Q];
        end else begin 
            if(buffaccum[4] > 5'd3) 
                n_buffer_4[3] = buffer_4[3]; 
            else  
                n_buffer_4[3] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[3] = buffer_4[3];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd4) begin 
            n_buffer_4[4] = buffer_4[4 + Q];
        end else begin 
            if(buffaccum[4] > 5'd4) 
                n_buffer_4[4] = buffer_4[4]; 
            else  
                n_buffer_4[4] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[4] = buffer_4[4];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd5) begin 
            n_buffer_4[5] = buffer_4[5 + Q];
        end else begin 
            if(buffaccum[4] > 5'd5) 
                n_buffer_4[5] = buffer_4[5]; 
            else  
                n_buffer_4[5] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[5] = buffer_4[5];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd6) begin 
            n_buffer_4[6] = buffer_4[6 + Q];
        end else begin 
            if(buffaccum[4] > 5'd6) 
                n_buffer_4[6] = buffer_4[6]; 
            else  
                n_buffer_4[6] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[6] = buffer_4[6];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd7) begin 
            n_buffer_4[7] = buffer_4[7 + Q];
        end else begin 
            if(buffaccum[4] > 5'd7) 
                n_buffer_4[7] = buffer_4[7]; 
            else  
                n_buffer_4[7] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[7] = buffer_4[7];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd8) begin 
            n_buffer_4[8] = buffer_4[8 + Q];
        end else begin 
            if(buffaccum[4] > 5'd8) 
                n_buffer_4[8] = buffer_4[8]; 
            else  
                n_buffer_4[8] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[8] = buffer_4[8];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd9) begin 
            n_buffer_4[9] = buffer_4[9 + Q];
        end else begin 
            if(buffaccum[4] > 5'd9) 
                n_buffer_4[9] = buffer_4[9]; 
            else  
                n_buffer_4[9] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[9] = buffer_4[9];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd10) begin 
            n_buffer_4[10] = buffer_4[10 + Q];
        end else begin 
            if(buffaccum[4] > 5'd10) 
                n_buffer_4[10] = buffer_4[10]; 
            else  
                n_buffer_4[10] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[10] = buffer_4[10];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd11) begin 
            n_buffer_4[11] = buffer_4[11 + Q];
        end else begin 
            if(buffaccum[4] > 5'd11) 
                n_buffer_4[11] = buffer_4[11]; 
            else  
                n_buffer_4[11] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[11] = buffer_4[11];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd12) begin 
            n_buffer_4[12] = buffer_4[12 + Q];
        end else begin 
            if(buffaccum[4] > 5'd12) 
                n_buffer_4[12] = buffer_4[12]; 
            else  
                n_buffer_4[12] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[12] = buffer_4[12];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd13) begin 
            n_buffer_4[13] = buffer_4[13 + Q];
        end else begin 
            if(buffaccum[4] > 5'd13) 
                n_buffer_4[13] = buffer_4[13]; 
            else  
                n_buffer_4[13] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[13] = buffer_4[13];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd14) begin 
            n_buffer_4[14] = buffer_4[14 + Q];
        end else begin 
            if(buffaccum[4] > 5'd14) 
                n_buffer_4[14] = buffer_4[14]; 
            else  
                n_buffer_4[14] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[14] = buffer_4[14];


    if(psum_set) begin 
        if(export[4] == 1'b1 && buffaccum[4] > 5'd15) begin 
            n_buffer_4[15] = buffer_4[15 + Q];
        end else begin 
            if(buffaccum[4] > 5'd15) 
                n_buffer_4[15] = buffer_4[15]; 
            else  
                n_buffer_4[15] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_4[15] = buffer_4[15];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd16) 
            n_buffer_4[16] = buffer_4[16]; 
        else  
            n_buffer_4[16] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_4[16] = buffer_4[16];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd17) 
            n_buffer_4[17] = buffer_4[17]; 
        else  
            n_buffer_4[17] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_4[17] = buffer_4[17];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd18) 
            n_buffer_4[18] = buffer_4[18]; 
        else  
            n_buffer_4[18] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_4[18] = buffer_4[18];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd19) 
            n_buffer_4[19] = buffer_4[19]; 
        else  
            n_buffer_4[19] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_4[19] = buffer_4[19];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd20) 
            n_buffer_4[20] = buffer_4[20]; 
        else  
            n_buffer_4[20] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_4[20] = buffer_4[20];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd21) 
            n_buffer_4[21] = buffer_4[21]; 
        else  
            n_buffer_4[21] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_4[21] = buffer_4[21];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd22) 
            n_buffer_4[22] = buffer_4[22]; 
        else  
            n_buffer_4[22] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_4[22] = buffer_4[22];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd23) 
            n_buffer_4[23] = buffer_4[23]; 
        else  
            n_buffer_4[23] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_4[23] = buffer_4[23];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd24) 
            n_buffer_4[24] = buffer_4[24]; 
        else  
            n_buffer_4[24] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_4[24] = buffer_4[24];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd25) 
            n_buffer_4[25] = buffer_4[25]; 
        else  
            n_buffer_4[25] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_4[25] = buffer_4[25];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd26) 
            n_buffer_4[26] = buffer_4[26]; 
        else  
            n_buffer_4[26] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_4[26] = buffer_4[26];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd27) 
            n_buffer_4[27] = buffer_4[27]; 
        else  
            n_buffer_4[27] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_4[27] = buffer_4[27];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd28) 
            n_buffer_4[28] = buffer_4[28]; 
        else  
            n_buffer_4[28] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_4[28] = buffer_4[28];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd29) 
            n_buffer_4[29] = buffer_4[29]; 
        else  
            n_buffer_4[29] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_4[29] = buffer_4[29];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd30) 
            n_buffer_4[30] = buffer_4[30]; 
        else  
            n_buffer_4[30] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_4[30] = buffer_4[30];


    if(psum_set) begin 
        if(buffaccum[4] > 5'd31) 
            n_buffer_4[31] = buffer_4[31]; 
        else  
            n_buffer_4[31] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_4[31] = buffer_4[31];

    //============================

    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd0) begin 
            n_buffer_5[0] = buffer_5[0 + Q];
        end else begin 
            if(buffaccum[5] > 5'd0) 
                n_buffer_5[0] = buffer_5[0]; 
            else  
                n_buffer_5[0] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[0] = buffer_5[0];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd1) begin 
            n_buffer_5[1] = buffer_5[1 + Q];
        end else begin 
            if(buffaccum[5] > 5'd1) 
                n_buffer_5[1] = buffer_5[1]; 
            else  
                n_buffer_5[1] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[1] = buffer_5[1];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd2) begin 
            n_buffer_5[2] = buffer_5[2 + Q];
        end else begin 
            if(buffaccum[5] > 5'd2) 
                n_buffer_5[2] = buffer_5[2]; 
            else  
                n_buffer_5[2] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[2] = buffer_5[2];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd3) begin 
            n_buffer_5[3] = buffer_5[3 + Q];
        end else begin 
            if(buffaccum[5] > 5'd3) 
                n_buffer_5[3] = buffer_5[3]; 
            else  
                n_buffer_5[3] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[3] = buffer_5[3];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd4) begin 
            n_buffer_5[4] = buffer_5[4 + Q];
        end else begin 
            if(buffaccum[5] > 5'd4) 
                n_buffer_5[4] = buffer_5[4]; 
            else  
                n_buffer_5[4] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[4] = buffer_5[4];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd5) begin 
            n_buffer_5[5] = buffer_5[5 + Q];
        end else begin 
            if(buffaccum[5] > 5'd5) 
                n_buffer_5[5] = buffer_5[5]; 
            else  
                n_buffer_5[5] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[5] = buffer_5[5];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd6) begin 
            n_buffer_5[6] = buffer_5[6 + Q];
        end else begin 
            if(buffaccum[5] > 5'd6) 
                n_buffer_5[6] = buffer_5[6]; 
            else  
                n_buffer_5[6] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[6] = buffer_5[6];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd7) begin 
            n_buffer_5[7] = buffer_5[7 + Q];
        end else begin 
            if(buffaccum[5] > 5'd7) 
                n_buffer_5[7] = buffer_5[7]; 
            else  
                n_buffer_5[7] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[7] = buffer_5[7];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd8) begin 
            n_buffer_5[8] = buffer_5[8 + Q];
        end else begin 
            if(buffaccum[5] > 5'd8) 
                n_buffer_5[8] = buffer_5[8]; 
            else  
                n_buffer_5[8] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[8] = buffer_5[8];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd9) begin 
            n_buffer_5[9] = buffer_5[9 + Q];
        end else begin 
            if(buffaccum[5] > 5'd9) 
                n_buffer_5[9] = buffer_5[9]; 
            else  
                n_buffer_5[9] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[9] = buffer_5[9];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd10) begin 
            n_buffer_5[10] = buffer_5[10 + Q];
        end else begin 
            if(buffaccum[5] > 5'd10) 
                n_buffer_5[10] = buffer_5[10]; 
            else  
                n_buffer_5[10] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[10] = buffer_5[10];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd11) begin 
            n_buffer_5[11] = buffer_5[11 + Q];
        end else begin 
            if(buffaccum[5] > 5'd11) 
                n_buffer_5[11] = buffer_5[11]; 
            else  
                n_buffer_5[11] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[11] = buffer_5[11];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd12) begin 
            n_buffer_5[12] = buffer_5[12 + Q];
        end else begin 
            if(buffaccum[5] > 5'd12) 
                n_buffer_5[12] = buffer_5[12]; 
            else  
                n_buffer_5[12] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[12] = buffer_5[12];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd13) begin 
            n_buffer_5[13] = buffer_5[13 + Q];
        end else begin 
            if(buffaccum[5] > 5'd13) 
                n_buffer_5[13] = buffer_5[13]; 
            else  
                n_buffer_5[13] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[13] = buffer_5[13];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd14) begin 
            n_buffer_5[14] = buffer_5[14 + Q];
        end else begin 
            if(buffaccum[5] > 5'd14) 
                n_buffer_5[14] = buffer_5[14]; 
            else  
                n_buffer_5[14] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[14] = buffer_5[14];


    if(psum_set) begin 
        if(export[5] == 1'b1 && buffaccum[5] > 5'd15) begin 
            n_buffer_5[15] = buffer_5[15 + Q];
        end else begin 
            if(buffaccum[5] > 5'd15) 
                n_buffer_5[15] = buffer_5[15]; 
            else  
                n_buffer_5[15] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_5[15] = buffer_5[15];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd16) 
            n_buffer_5[16] = buffer_5[16]; 
        else  
            n_buffer_5[16] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_5[16] = buffer_5[16];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd17) 
            n_buffer_5[17] = buffer_5[17]; 
        else  
            n_buffer_5[17] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_5[17] = buffer_5[17];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd18) 
            n_buffer_5[18] = buffer_5[18]; 
        else  
            n_buffer_5[18] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_5[18] = buffer_5[18];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd19) 
            n_buffer_5[19] = buffer_5[19]; 
        else  
            n_buffer_5[19] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_5[19] = buffer_5[19];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd20) 
            n_buffer_5[20] = buffer_5[20]; 
        else  
            n_buffer_5[20] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_5[20] = buffer_5[20];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd21) 
            n_buffer_5[21] = buffer_5[21]; 
        else  
            n_buffer_5[21] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_5[21] = buffer_5[21];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd22) 
            n_buffer_5[22] = buffer_5[22]; 
        else  
            n_buffer_5[22] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_5[22] = buffer_5[22];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd23) 
            n_buffer_5[23] = buffer_5[23]; 
        else  
            n_buffer_5[23] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_5[23] = buffer_5[23];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd24) 
            n_buffer_5[24] = buffer_5[24]; 
        else  
            n_buffer_5[24] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_5[24] = buffer_5[24];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd25) 
            n_buffer_5[25] = buffer_5[25]; 
        else  
            n_buffer_5[25] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_5[25] = buffer_5[25];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd26) 
            n_buffer_5[26] = buffer_5[26]; 
        else  
            n_buffer_5[26] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_5[26] = buffer_5[26];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd27) 
            n_buffer_5[27] = buffer_5[27]; 
        else  
            n_buffer_5[27] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_5[27] = buffer_5[27];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd28) 
            n_buffer_5[28] = buffer_5[28]; 
        else  
            n_buffer_5[28] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_5[28] = buffer_5[28];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd29) 
            n_buffer_5[29] = buffer_5[29]; 
        else  
            n_buffer_5[29] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_5[29] = buffer_5[29];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd30) 
            n_buffer_5[30] = buffer_5[30]; 
        else  
            n_buffer_5[30] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_5[30] = buffer_5[30];


    if(psum_set) begin 
        if(buffaccum[5] > 5'd31) 
            n_buffer_5[31] = buffer_5[31]; 
        else  
            n_buffer_5[31] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_5[31] = buffer_5[31];

    //============================

    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd0) begin 
            n_buffer_6[0] = buffer_6[0 + Q];
        end else begin 
            if(buffaccum[6] > 5'd0) 
                n_buffer_6[0] = buffer_6[0]; 
            else  
                n_buffer_6[0] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[0] = buffer_6[0];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd1) begin 
            n_buffer_6[1] = buffer_6[1 + Q];
        end else begin 
            if(buffaccum[6] > 5'd1) 
                n_buffer_6[1] = buffer_6[1]; 
            else  
                n_buffer_6[1] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[1] = buffer_6[1];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd2) begin 
            n_buffer_6[2] = buffer_6[2 + Q];
        end else begin 
            if(buffaccum[6] > 5'd2) 
                n_buffer_6[2] = buffer_6[2]; 
            else  
                n_buffer_6[2] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[2] = buffer_6[2];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd3) begin 
            n_buffer_6[3] = buffer_6[3 + Q];
        end else begin 
            if(buffaccum[6] > 5'd3) 
                n_buffer_6[3] = buffer_6[3]; 
            else  
                n_buffer_6[3] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[3] = buffer_6[3];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd4) begin 
            n_buffer_6[4] = buffer_6[4 + Q];
        end else begin 
            if(buffaccum[6] > 5'd4) 
                n_buffer_6[4] = buffer_6[4]; 
            else  
                n_buffer_6[4] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[4] = buffer_6[4];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd5) begin 
            n_buffer_6[5] = buffer_6[5 + Q];
        end else begin 
            if(buffaccum[6] > 5'd5) 
                n_buffer_6[5] = buffer_6[5]; 
            else  
                n_buffer_6[5] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[5] = buffer_6[5];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd6) begin 
            n_buffer_6[6] = buffer_6[6 + Q];
        end else begin 
            if(buffaccum[6] > 5'd6) 
                n_buffer_6[6] = buffer_6[6]; 
            else  
                n_buffer_6[6] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[6] = buffer_6[6];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd7) begin 
            n_buffer_6[7] = buffer_6[7 + Q];
        end else begin 
            if(buffaccum[6] > 5'd7) 
                n_buffer_6[7] = buffer_6[7]; 
            else  
                n_buffer_6[7] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[7] = buffer_6[7];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd8) begin 
            n_buffer_6[8] = buffer_6[8 + Q];
        end else begin 
            if(buffaccum[6] > 5'd8) 
                n_buffer_6[8] = buffer_6[8]; 
            else  
                n_buffer_6[8] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[8] = buffer_6[8];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd9) begin 
            n_buffer_6[9] = buffer_6[9 + Q];
        end else begin 
            if(buffaccum[6] > 5'd9) 
                n_buffer_6[9] = buffer_6[9]; 
            else  
                n_buffer_6[9] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[9] = buffer_6[9];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd10) begin 
            n_buffer_6[10] = buffer_6[10 + Q];
        end else begin 
            if(buffaccum[6] > 5'd10) 
                n_buffer_6[10] = buffer_6[10]; 
            else  
                n_buffer_6[10] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[10] = buffer_6[10];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd11) begin 
            n_buffer_6[11] = buffer_6[11 + Q];
        end else begin 
            if(buffaccum[6] > 5'd11) 
                n_buffer_6[11] = buffer_6[11]; 
            else  
                n_buffer_6[11] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[11] = buffer_6[11];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd12) begin 
            n_buffer_6[12] = buffer_6[12 + Q];
        end else begin 
            if(buffaccum[6] > 5'd12) 
                n_buffer_6[12] = buffer_6[12]; 
            else  
                n_buffer_6[12] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[12] = buffer_6[12];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd13) begin 
            n_buffer_6[13] = buffer_6[13 + Q];
        end else begin 
            if(buffaccum[6] > 5'd13) 
                n_buffer_6[13] = buffer_6[13]; 
            else  
                n_buffer_6[13] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[13] = buffer_6[13];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd14) begin 
            n_buffer_6[14] = buffer_6[14 + Q];
        end else begin 
            if(buffaccum[6] > 5'd14) 
                n_buffer_6[14] = buffer_6[14]; 
            else  
                n_buffer_6[14] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[14] = buffer_6[14];


    if(psum_set) begin 
        if(export[6] == 1'b1 && buffaccum[6] > 5'd15) begin 
            n_buffer_6[15] = buffer_6[15 + Q];
        end else begin 
            if(buffaccum[6] > 5'd15) 
                n_buffer_6[15] = buffer_6[15]; 
            else  
                n_buffer_6[15] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_6[15] = buffer_6[15];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd16) 
            n_buffer_6[16] = buffer_6[16]; 
        else  
            n_buffer_6[16] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_6[16] = buffer_6[16];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd17) 
            n_buffer_6[17] = buffer_6[17]; 
        else  
            n_buffer_6[17] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_6[17] = buffer_6[17];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd18) 
            n_buffer_6[18] = buffer_6[18]; 
        else  
            n_buffer_6[18] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_6[18] = buffer_6[18];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd19) 
            n_buffer_6[19] = buffer_6[19]; 
        else  
            n_buffer_6[19] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_6[19] = buffer_6[19];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd20) 
            n_buffer_6[20] = buffer_6[20]; 
        else  
            n_buffer_6[20] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_6[20] = buffer_6[20];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd21) 
            n_buffer_6[21] = buffer_6[21]; 
        else  
            n_buffer_6[21] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_6[21] = buffer_6[21];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd22) 
            n_buffer_6[22] = buffer_6[22]; 
        else  
            n_buffer_6[22] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_6[22] = buffer_6[22];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd23) 
            n_buffer_6[23] = buffer_6[23]; 
        else  
            n_buffer_6[23] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_6[23] = buffer_6[23];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd24) 
            n_buffer_6[24] = buffer_6[24]; 
        else  
            n_buffer_6[24] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_6[24] = buffer_6[24];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd25) 
            n_buffer_6[25] = buffer_6[25]; 
        else  
            n_buffer_6[25] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_6[25] = buffer_6[25];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd26) 
            n_buffer_6[26] = buffer_6[26]; 
        else  
            n_buffer_6[26] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_6[26] = buffer_6[26];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd27) 
            n_buffer_6[27] = buffer_6[27]; 
        else  
            n_buffer_6[27] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_6[27] = buffer_6[27];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd28) 
            n_buffer_6[28] = buffer_6[28]; 
        else  
            n_buffer_6[28] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_6[28] = buffer_6[28];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd29) 
            n_buffer_6[29] = buffer_6[29]; 
        else  
            n_buffer_6[29] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_6[29] = buffer_6[29];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd30) 
            n_buffer_6[30] = buffer_6[30]; 
        else  
            n_buffer_6[30] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_6[30] = buffer_6[30];


    if(psum_set) begin 
        if(buffaccum[6] > 5'd31) 
            n_buffer_6[31] = buffer_6[31]; 
        else  
            n_buffer_6[31] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_6[31] = buffer_6[31];

    //============================

    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd0) begin 
            n_buffer_7[0] = buffer_7[0 + Q];
        end else begin 
            if(buffaccum[7] > 5'd0) 
                n_buffer_7[0] = buffer_7[0]; 
            else  
                n_buffer_7[0] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[0] = buffer_7[0];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd1) begin 
            n_buffer_7[1] = buffer_7[1 + Q];
        end else begin 
            if(buffaccum[7] > 5'd1) 
                n_buffer_7[1] = buffer_7[1]; 
            else  
                n_buffer_7[1] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[1] = buffer_7[1];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd2) begin 
            n_buffer_7[2] = buffer_7[2 + Q];
        end else begin 
            if(buffaccum[7] > 5'd2) 
                n_buffer_7[2] = buffer_7[2]; 
            else  
                n_buffer_7[2] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[2] = buffer_7[2];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd3) begin 
            n_buffer_7[3] = buffer_7[3 + Q];
        end else begin 
            if(buffaccum[7] > 5'd3) 
                n_buffer_7[3] = buffer_7[3]; 
            else  
                n_buffer_7[3] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[3] = buffer_7[3];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd4) begin 
            n_buffer_7[4] = buffer_7[4 + Q];
        end else begin 
            if(buffaccum[7] > 5'd4) 
                n_buffer_7[4] = buffer_7[4]; 
            else  
                n_buffer_7[4] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[4] = buffer_7[4];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd5) begin 
            n_buffer_7[5] = buffer_7[5 + Q];
        end else begin 
            if(buffaccum[7] > 5'd5) 
                n_buffer_7[5] = buffer_7[5]; 
            else  
                n_buffer_7[5] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[5] = buffer_7[5];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd6) begin 
            n_buffer_7[6] = buffer_7[6 + Q];
        end else begin 
            if(buffaccum[7] > 5'd6) 
                n_buffer_7[6] = buffer_7[6]; 
            else  
                n_buffer_7[6] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[6] = buffer_7[6];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd7) begin 
            n_buffer_7[7] = buffer_7[7 + Q];
        end else begin 
            if(buffaccum[7] > 5'd7) 
                n_buffer_7[7] = buffer_7[7]; 
            else  
                n_buffer_7[7] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[7] = buffer_7[7];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd8) begin 
            n_buffer_7[8] = buffer_7[8 + Q];
        end else begin 
            if(buffaccum[7] > 5'd8) 
                n_buffer_7[8] = buffer_7[8]; 
            else  
                n_buffer_7[8] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[8] = buffer_7[8];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd9) begin 
            n_buffer_7[9] = buffer_7[9 + Q];
        end else begin 
            if(buffaccum[7] > 5'd9) 
                n_buffer_7[9] = buffer_7[9]; 
            else  
                n_buffer_7[9] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[9] = buffer_7[9];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd10) begin 
            n_buffer_7[10] = buffer_7[10 + Q];
        end else begin 
            if(buffaccum[7] > 5'd10) 
                n_buffer_7[10] = buffer_7[10]; 
            else  
                n_buffer_7[10] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[10] = buffer_7[10];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd11) begin 
            n_buffer_7[11] = buffer_7[11 + Q];
        end else begin 
            if(buffaccum[7] > 5'd11) 
                n_buffer_7[11] = buffer_7[11]; 
            else  
                n_buffer_7[11] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[11] = buffer_7[11];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd12) begin 
            n_buffer_7[12] = buffer_7[12 + Q];
        end else begin 
            if(buffaccum[7] > 5'd12) 
                n_buffer_7[12] = buffer_7[12]; 
            else  
                n_buffer_7[12] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[12] = buffer_7[12];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd13) begin 
            n_buffer_7[13] = buffer_7[13 + Q];
        end else begin 
            if(buffaccum[7] > 5'd13) 
                n_buffer_7[13] = buffer_7[13]; 
            else  
                n_buffer_7[13] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[13] = buffer_7[13];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd14) begin 
            n_buffer_7[14] = buffer_7[14 + Q];
        end else begin 
            if(buffaccum[7] > 5'd14) 
                n_buffer_7[14] = buffer_7[14]; 
            else  
                n_buffer_7[14] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[14] = buffer_7[14];


    if(psum_set) begin 
        if(export[7] == 1'b1 && buffaccum[7] > 5'd15) begin 
            n_buffer_7[15] = buffer_7[15 + Q];
        end else begin 
            if(buffaccum[7] > 5'd15) 
                n_buffer_7[15] = buffer_7[15]; 
            else  
                n_buffer_7[15] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_7[15] = buffer_7[15];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd16) 
            n_buffer_7[16] = buffer_7[16]; 
        else  
            n_buffer_7[16] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_7[16] = buffer_7[16];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd17) 
            n_buffer_7[17] = buffer_7[17]; 
        else  
            n_buffer_7[17] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_7[17] = buffer_7[17];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd18) 
            n_buffer_7[18] = buffer_7[18]; 
        else  
            n_buffer_7[18] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_7[18] = buffer_7[18];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd19) 
            n_buffer_7[19] = buffer_7[19]; 
        else  
            n_buffer_7[19] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_7[19] = buffer_7[19];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd20) 
            n_buffer_7[20] = buffer_7[20]; 
        else  
            n_buffer_7[20] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_7[20] = buffer_7[20];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd21) 
            n_buffer_7[21] = buffer_7[21]; 
        else  
            n_buffer_7[21] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_7[21] = buffer_7[21];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd22) 
            n_buffer_7[22] = buffer_7[22]; 
        else  
            n_buffer_7[22] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_7[22] = buffer_7[22];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd23) 
            n_buffer_7[23] = buffer_7[23]; 
        else  
            n_buffer_7[23] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_7[23] = buffer_7[23];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd24) 
            n_buffer_7[24] = buffer_7[24]; 
        else  
            n_buffer_7[24] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_7[24] = buffer_7[24];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd25) 
            n_buffer_7[25] = buffer_7[25]; 
        else  
            n_buffer_7[25] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_7[25] = buffer_7[25];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd26) 
            n_buffer_7[26] = buffer_7[26]; 
        else  
            n_buffer_7[26] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_7[26] = buffer_7[26];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd27) 
            n_buffer_7[27] = buffer_7[27]; 
        else  
            n_buffer_7[27] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_7[27] = buffer_7[27];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd28) 
            n_buffer_7[28] = buffer_7[28]; 
        else  
            n_buffer_7[28] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_7[28] = buffer_7[28];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd29) 
            n_buffer_7[29] = buffer_7[29]; 
        else  
            n_buffer_7[29] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_7[29] = buffer_7[29];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd30) 
            n_buffer_7[30] = buffer_7[30]; 
        else  
            n_buffer_7[30] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_7[30] = buffer_7[30];


    if(psum_set) begin 
        if(buffaccum[7] > 5'd31) 
            n_buffer_7[31] = buffer_7[31]; 
        else  
            n_buffer_7[31] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_7[31] = buffer_7[31];

    //============================

    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd0) begin 
            n_buffer_8[0] = buffer_8[0 + Q];
        end else begin 
            if(buffaccum[8] > 5'd0) 
                n_buffer_8[0] = buffer_8[0]; 
            else  
                n_buffer_8[0] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[0] = buffer_8[0];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd1) begin 
            n_buffer_8[1] = buffer_8[1 + Q];
        end else begin 
            if(buffaccum[8] > 5'd1) 
                n_buffer_8[1] = buffer_8[1]; 
            else  
                n_buffer_8[1] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[1] = buffer_8[1];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd2) begin 
            n_buffer_8[2] = buffer_8[2 + Q];
        end else begin 
            if(buffaccum[8] > 5'd2) 
                n_buffer_8[2] = buffer_8[2]; 
            else  
                n_buffer_8[2] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[2] = buffer_8[2];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd3) begin 
            n_buffer_8[3] = buffer_8[3 + Q];
        end else begin 
            if(buffaccum[8] > 5'd3) 
                n_buffer_8[3] = buffer_8[3]; 
            else  
                n_buffer_8[3] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[3] = buffer_8[3];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd4) begin 
            n_buffer_8[4] = buffer_8[4 + Q];
        end else begin 
            if(buffaccum[8] > 5'd4) 
                n_buffer_8[4] = buffer_8[4]; 
            else  
                n_buffer_8[4] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[4] = buffer_8[4];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd5) begin 
            n_buffer_8[5] = buffer_8[5 + Q];
        end else begin 
            if(buffaccum[8] > 5'd5) 
                n_buffer_8[5] = buffer_8[5]; 
            else  
                n_buffer_8[5] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[5] = buffer_8[5];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd6) begin 
            n_buffer_8[6] = buffer_8[6 + Q];
        end else begin 
            if(buffaccum[8] > 5'd6) 
                n_buffer_8[6] = buffer_8[6]; 
            else  
                n_buffer_8[6] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[6] = buffer_8[6];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd7) begin 
            n_buffer_8[7] = buffer_8[7 + Q];
        end else begin 
            if(buffaccum[8] > 5'd7) 
                n_buffer_8[7] = buffer_8[7]; 
            else  
                n_buffer_8[7] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[7] = buffer_8[7];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd8) begin 
            n_buffer_8[8] = buffer_8[8 + Q];
        end else begin 
            if(buffaccum[8] > 5'd8) 
                n_buffer_8[8] = buffer_8[8]; 
            else  
                n_buffer_8[8] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[8] = buffer_8[8];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd9) begin 
            n_buffer_8[9] = buffer_8[9 + Q];
        end else begin 
            if(buffaccum[8] > 5'd9) 
                n_buffer_8[9] = buffer_8[9]; 
            else  
                n_buffer_8[9] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[9] = buffer_8[9];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd10) begin 
            n_buffer_8[10] = buffer_8[10 + Q];
        end else begin 
            if(buffaccum[8] > 5'd10) 
                n_buffer_8[10] = buffer_8[10]; 
            else  
                n_buffer_8[10] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[10] = buffer_8[10];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd11) begin 
            n_buffer_8[11] = buffer_8[11 + Q];
        end else begin 
            if(buffaccum[8] > 5'd11) 
                n_buffer_8[11] = buffer_8[11]; 
            else  
                n_buffer_8[11] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[11] = buffer_8[11];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd12) begin 
            n_buffer_8[12] = buffer_8[12 + Q];
        end else begin 
            if(buffaccum[8] > 5'd12) 
                n_buffer_8[12] = buffer_8[12]; 
            else  
                n_buffer_8[12] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[12] = buffer_8[12];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd13) begin 
            n_buffer_8[13] = buffer_8[13 + Q];
        end else begin 
            if(buffaccum[8] > 5'd13) 
                n_buffer_8[13] = buffer_8[13]; 
            else  
                n_buffer_8[13] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[13] = buffer_8[13];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd14) begin 
            n_buffer_8[14] = buffer_8[14 + Q];
        end else begin 
            if(buffaccum[8] > 5'd14) 
                n_buffer_8[14] = buffer_8[14]; 
            else  
                n_buffer_8[14] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[14] = buffer_8[14];


    if(psum_set) begin 
        if(export[8] == 1'b1 && buffaccum[8] > 5'd15) begin 
            n_buffer_8[15] = buffer_8[15 + Q];
        end else begin 
            if(buffaccum[8] > 5'd15) 
                n_buffer_8[15] = buffer_8[15]; 
            else  
                n_buffer_8[15] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_8[15] = buffer_8[15];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd16) 
            n_buffer_8[16] = buffer_8[16]; 
        else  
            n_buffer_8[16] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_8[16] = buffer_8[16];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd17) 
            n_buffer_8[17] = buffer_8[17]; 
        else  
            n_buffer_8[17] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_8[17] = buffer_8[17];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd18) 
            n_buffer_8[18] = buffer_8[18]; 
        else  
            n_buffer_8[18] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_8[18] = buffer_8[18];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd19) 
            n_buffer_8[19] = buffer_8[19]; 
        else  
            n_buffer_8[19] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_8[19] = buffer_8[19];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd20) 
            n_buffer_8[20] = buffer_8[20]; 
        else  
            n_buffer_8[20] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_8[20] = buffer_8[20];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd21) 
            n_buffer_8[21] = buffer_8[21]; 
        else  
            n_buffer_8[21] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_8[21] = buffer_8[21];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd22) 
            n_buffer_8[22] = buffer_8[22]; 
        else  
            n_buffer_8[22] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_8[22] = buffer_8[22];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd23) 
            n_buffer_8[23] = buffer_8[23]; 
        else  
            n_buffer_8[23] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_8[23] = buffer_8[23];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd24) 
            n_buffer_8[24] = buffer_8[24]; 
        else  
            n_buffer_8[24] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_8[24] = buffer_8[24];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd25) 
            n_buffer_8[25] = buffer_8[25]; 
        else  
            n_buffer_8[25] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_8[25] = buffer_8[25];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd26) 
            n_buffer_8[26] = buffer_8[26]; 
        else  
            n_buffer_8[26] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_8[26] = buffer_8[26];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd27) 
            n_buffer_8[27] = buffer_8[27]; 
        else  
            n_buffer_8[27] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_8[27] = buffer_8[27];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd28) 
            n_buffer_8[28] = buffer_8[28]; 
        else  
            n_buffer_8[28] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_8[28] = buffer_8[28];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd29) 
            n_buffer_8[29] = buffer_8[29]; 
        else  
            n_buffer_8[29] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_8[29] = buffer_8[29];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd30) 
            n_buffer_8[30] = buffer_8[30]; 
        else  
            n_buffer_8[30] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_8[30] = buffer_8[30];


    if(psum_set) begin 
        if(buffaccum[8] > 5'd31) 
            n_buffer_8[31] = buffer_8[31]; 
        else  
            n_buffer_8[31] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_8[31] = buffer_8[31];

    //============================

    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd0) begin 
            n_buffer_9[0] = buffer_9[0 + Q];
        end else begin 
            if(buffaccum[9] > 5'd0) 
                n_buffer_9[0] = buffer_9[0]; 
            else  
                n_buffer_9[0] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[0] = buffer_9[0];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd1) begin 
            n_buffer_9[1] = buffer_9[1 + Q];
        end else begin 
            if(buffaccum[9] > 5'd1) 
                n_buffer_9[1] = buffer_9[1]; 
            else  
                n_buffer_9[1] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[1] = buffer_9[1];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd2) begin 
            n_buffer_9[2] = buffer_9[2 + Q];
        end else begin 
            if(buffaccum[9] > 5'd2) 
                n_buffer_9[2] = buffer_9[2]; 
            else  
                n_buffer_9[2] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[2] = buffer_9[2];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd3) begin 
            n_buffer_9[3] = buffer_9[3 + Q];
        end else begin 
            if(buffaccum[9] > 5'd3) 
                n_buffer_9[3] = buffer_9[3]; 
            else  
                n_buffer_9[3] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[3] = buffer_9[3];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd4) begin 
            n_buffer_9[4] = buffer_9[4 + Q];
        end else begin 
            if(buffaccum[9] > 5'd4) 
                n_buffer_9[4] = buffer_9[4]; 
            else  
                n_buffer_9[4] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[4] = buffer_9[4];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd5) begin 
            n_buffer_9[5] = buffer_9[5 + Q];
        end else begin 
            if(buffaccum[9] > 5'd5) 
                n_buffer_9[5] = buffer_9[5]; 
            else  
                n_buffer_9[5] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[5] = buffer_9[5];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd6) begin 
            n_buffer_9[6] = buffer_9[6 + Q];
        end else begin 
            if(buffaccum[9] > 5'd6) 
                n_buffer_9[6] = buffer_9[6]; 
            else  
                n_buffer_9[6] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[6] = buffer_9[6];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd7) begin 
            n_buffer_9[7] = buffer_9[7 + Q];
        end else begin 
            if(buffaccum[9] > 5'd7) 
                n_buffer_9[7] = buffer_9[7]; 
            else  
                n_buffer_9[7] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[7] = buffer_9[7];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd8) begin 
            n_buffer_9[8] = buffer_9[8 + Q];
        end else begin 
            if(buffaccum[9] > 5'd8) 
                n_buffer_9[8] = buffer_9[8]; 
            else  
                n_buffer_9[8] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[8] = buffer_9[8];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd9) begin 
            n_buffer_9[9] = buffer_9[9 + Q];
        end else begin 
            if(buffaccum[9] > 5'd9) 
                n_buffer_9[9] = buffer_9[9]; 
            else  
                n_buffer_9[9] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[9] = buffer_9[9];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd10) begin 
            n_buffer_9[10] = buffer_9[10 + Q];
        end else begin 
            if(buffaccum[9] > 5'd10) 
                n_buffer_9[10] = buffer_9[10]; 
            else  
                n_buffer_9[10] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[10] = buffer_9[10];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd11) begin 
            n_buffer_9[11] = buffer_9[11 + Q];
        end else begin 
            if(buffaccum[9] > 5'd11) 
                n_buffer_9[11] = buffer_9[11]; 
            else  
                n_buffer_9[11] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[11] = buffer_9[11];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd12) begin 
            n_buffer_9[12] = buffer_9[12 + Q];
        end else begin 
            if(buffaccum[9] > 5'd12) 
                n_buffer_9[12] = buffer_9[12]; 
            else  
                n_buffer_9[12] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[12] = buffer_9[12];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd13) begin 
            n_buffer_9[13] = buffer_9[13 + Q];
        end else begin 
            if(buffaccum[9] > 5'd13) 
                n_buffer_9[13] = buffer_9[13]; 
            else  
                n_buffer_9[13] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[13] = buffer_9[13];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd14) begin 
            n_buffer_9[14] = buffer_9[14 + Q];
        end else begin 
            if(buffaccum[9] > 5'd14) 
                n_buffer_9[14] = buffer_9[14]; 
            else  
                n_buffer_9[14] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[14] = buffer_9[14];


    if(psum_set) begin 
        if(export[9] == 1'b1 && buffaccum[9] > 5'd15) begin 
            n_buffer_9[15] = buffer_9[15 + Q];
        end else begin 
            if(buffaccum[9] > 5'd15) 
                n_buffer_9[15] = buffer_9[15]; 
            else  
                n_buffer_9[15] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_9[15] = buffer_9[15];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd16) 
            n_buffer_9[16] = buffer_9[16]; 
        else  
            n_buffer_9[16] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_9[16] = buffer_9[16];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd17) 
            n_buffer_9[17] = buffer_9[17]; 
        else  
            n_buffer_9[17] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_9[17] = buffer_9[17];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd18) 
            n_buffer_9[18] = buffer_9[18]; 
        else  
            n_buffer_9[18] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_9[18] = buffer_9[18];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd19) 
            n_buffer_9[19] = buffer_9[19]; 
        else  
            n_buffer_9[19] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_9[19] = buffer_9[19];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd20) 
            n_buffer_9[20] = buffer_9[20]; 
        else  
            n_buffer_9[20] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_9[20] = buffer_9[20];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd21) 
            n_buffer_9[21] = buffer_9[21]; 
        else  
            n_buffer_9[21] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_9[21] = buffer_9[21];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd22) 
            n_buffer_9[22] = buffer_9[22]; 
        else  
            n_buffer_9[22] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_9[22] = buffer_9[22];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd23) 
            n_buffer_9[23] = buffer_9[23]; 
        else  
            n_buffer_9[23] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_9[23] = buffer_9[23];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd24) 
            n_buffer_9[24] = buffer_9[24]; 
        else  
            n_buffer_9[24] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_9[24] = buffer_9[24];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd25) 
            n_buffer_9[25] = buffer_9[25]; 
        else  
            n_buffer_9[25] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_9[25] = buffer_9[25];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd26) 
            n_buffer_9[26] = buffer_9[26]; 
        else  
            n_buffer_9[26] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_9[26] = buffer_9[26];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd27) 
            n_buffer_9[27] = buffer_9[27]; 
        else  
            n_buffer_9[27] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_9[27] = buffer_9[27];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd28) 
            n_buffer_9[28] = buffer_9[28]; 
        else  
            n_buffer_9[28] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_9[28] = buffer_9[28];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd29) 
            n_buffer_9[29] = buffer_9[29]; 
        else  
            n_buffer_9[29] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_9[29] = buffer_9[29];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd30) 
            n_buffer_9[30] = buffer_9[30]; 
        else  
            n_buffer_9[30] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_9[30] = buffer_9[30];


    if(psum_set) begin 
        if(buffaccum[9] > 5'd31) 
            n_buffer_9[31] = buffer_9[31]; 
        else  
            n_buffer_9[31] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_9[31] = buffer_9[31];

    //============================

    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd0) begin 
            n_buffer_10[0] = buffer_10[0 + Q];
        end else begin 
            if(buffaccum[10] > 5'd0) 
                n_buffer_10[0] = buffer_10[0]; 
            else  
                n_buffer_10[0] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[0] = buffer_10[0];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd1) begin 
            n_buffer_10[1] = buffer_10[1 + Q];
        end else begin 
            if(buffaccum[10] > 5'd1) 
                n_buffer_10[1] = buffer_10[1]; 
            else  
                n_buffer_10[1] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[1] = buffer_10[1];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd2) begin 
            n_buffer_10[2] = buffer_10[2 + Q];
        end else begin 
            if(buffaccum[10] > 5'd2) 
                n_buffer_10[2] = buffer_10[2]; 
            else  
                n_buffer_10[2] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[2] = buffer_10[2];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd3) begin 
            n_buffer_10[3] = buffer_10[3 + Q];
        end else begin 
            if(buffaccum[10] > 5'd3) 
                n_buffer_10[3] = buffer_10[3]; 
            else  
                n_buffer_10[3] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[3] = buffer_10[3];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd4) begin 
            n_buffer_10[4] = buffer_10[4 + Q];
        end else begin 
            if(buffaccum[10] > 5'd4) 
                n_buffer_10[4] = buffer_10[4]; 
            else  
                n_buffer_10[4] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[4] = buffer_10[4];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd5) begin 
            n_buffer_10[5] = buffer_10[5 + Q];
        end else begin 
            if(buffaccum[10] > 5'd5) 
                n_buffer_10[5] = buffer_10[5]; 
            else  
                n_buffer_10[5] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[5] = buffer_10[5];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd6) begin 
            n_buffer_10[6] = buffer_10[6 + Q];
        end else begin 
            if(buffaccum[10] > 5'd6) 
                n_buffer_10[6] = buffer_10[6]; 
            else  
                n_buffer_10[6] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[6] = buffer_10[6];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd7) begin 
            n_buffer_10[7] = buffer_10[7 + Q];
        end else begin 
            if(buffaccum[10] > 5'd7) 
                n_buffer_10[7] = buffer_10[7]; 
            else  
                n_buffer_10[7] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[7] = buffer_10[7];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd8) begin 
            n_buffer_10[8] = buffer_10[8 + Q];
        end else begin 
            if(buffaccum[10] > 5'd8) 
                n_buffer_10[8] = buffer_10[8]; 
            else  
                n_buffer_10[8] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[8] = buffer_10[8];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd9) begin 
            n_buffer_10[9] = buffer_10[9 + Q];
        end else begin 
            if(buffaccum[10] > 5'd9) 
                n_buffer_10[9] = buffer_10[9]; 
            else  
                n_buffer_10[9] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[9] = buffer_10[9];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd10) begin 
            n_buffer_10[10] = buffer_10[10 + Q];
        end else begin 
            if(buffaccum[10] > 5'd10) 
                n_buffer_10[10] = buffer_10[10]; 
            else  
                n_buffer_10[10] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[10] = buffer_10[10];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd11) begin 
            n_buffer_10[11] = buffer_10[11 + Q];
        end else begin 
            if(buffaccum[10] > 5'd11) 
                n_buffer_10[11] = buffer_10[11]; 
            else  
                n_buffer_10[11] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[11] = buffer_10[11];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd12) begin 
            n_buffer_10[12] = buffer_10[12 + Q];
        end else begin 
            if(buffaccum[10] > 5'd12) 
                n_buffer_10[12] = buffer_10[12]; 
            else  
                n_buffer_10[12] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[12] = buffer_10[12];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd13) begin 
            n_buffer_10[13] = buffer_10[13 + Q];
        end else begin 
            if(buffaccum[10] > 5'd13) 
                n_buffer_10[13] = buffer_10[13]; 
            else  
                n_buffer_10[13] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[13] = buffer_10[13];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd14) begin 
            n_buffer_10[14] = buffer_10[14 + Q];
        end else begin 
            if(buffaccum[10] > 5'd14) 
                n_buffer_10[14] = buffer_10[14]; 
            else  
                n_buffer_10[14] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[14] = buffer_10[14];


    if(psum_set) begin 
        if(export[10] == 1'b1 && buffaccum[10] > 5'd15) begin 
            n_buffer_10[15] = buffer_10[15 + Q];
        end else begin 
            if(buffaccum[10] > 5'd15) 
                n_buffer_10[15] = buffer_10[15]; 
            else  
                n_buffer_10[15] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_10[15] = buffer_10[15];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd16) 
            n_buffer_10[16] = buffer_10[16]; 
        else  
            n_buffer_10[16] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_10[16] = buffer_10[16];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd17) 
            n_buffer_10[17] = buffer_10[17]; 
        else  
            n_buffer_10[17] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_10[17] = buffer_10[17];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd18) 
            n_buffer_10[18] = buffer_10[18]; 
        else  
            n_buffer_10[18] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_10[18] = buffer_10[18];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd19) 
            n_buffer_10[19] = buffer_10[19]; 
        else  
            n_buffer_10[19] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_10[19] = buffer_10[19];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd20) 
            n_buffer_10[20] = buffer_10[20]; 
        else  
            n_buffer_10[20] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_10[20] = buffer_10[20];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd21) 
            n_buffer_10[21] = buffer_10[21]; 
        else  
            n_buffer_10[21] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_10[21] = buffer_10[21];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd22) 
            n_buffer_10[22] = buffer_10[22]; 
        else  
            n_buffer_10[22] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_10[22] = buffer_10[22];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd23) 
            n_buffer_10[23] = buffer_10[23]; 
        else  
            n_buffer_10[23] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_10[23] = buffer_10[23];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd24) 
            n_buffer_10[24] = buffer_10[24]; 
        else  
            n_buffer_10[24] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_10[24] = buffer_10[24];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd25) 
            n_buffer_10[25] = buffer_10[25]; 
        else  
            n_buffer_10[25] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_10[25] = buffer_10[25];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd26) 
            n_buffer_10[26] = buffer_10[26]; 
        else  
            n_buffer_10[26] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_10[26] = buffer_10[26];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd27) 
            n_buffer_10[27] = buffer_10[27]; 
        else  
            n_buffer_10[27] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_10[27] = buffer_10[27];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd28) 
            n_buffer_10[28] = buffer_10[28]; 
        else  
            n_buffer_10[28] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_10[28] = buffer_10[28];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd29) 
            n_buffer_10[29] = buffer_10[29]; 
        else  
            n_buffer_10[29] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_10[29] = buffer_10[29];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd30) 
            n_buffer_10[30] = buffer_10[30]; 
        else  
            n_buffer_10[30] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_10[30] = buffer_10[30];


    if(psum_set) begin 
        if(buffaccum[10] > 5'd31) 
            n_buffer_10[31] = buffer_10[31]; 
        else  
            n_buffer_10[31] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_10[31] = buffer_10[31];

    //============================

    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd0) begin 
            n_buffer_11[0] = buffer_11[0 + Q];
        end else begin 
            if(buffaccum[11] > 5'd0) 
                n_buffer_11[0] = buffer_11[0]; 
            else  
                n_buffer_11[0] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[0] = buffer_11[0];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd1) begin 
            n_buffer_11[1] = buffer_11[1 + Q];
        end else begin 
            if(buffaccum[11] > 5'd1) 
                n_buffer_11[1] = buffer_11[1]; 
            else  
                n_buffer_11[1] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[1] = buffer_11[1];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd2) begin 
            n_buffer_11[2] = buffer_11[2 + Q];
        end else begin 
            if(buffaccum[11] > 5'd2) 
                n_buffer_11[2] = buffer_11[2]; 
            else  
                n_buffer_11[2] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[2] = buffer_11[2];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd3) begin 
            n_buffer_11[3] = buffer_11[3 + Q];
        end else begin 
            if(buffaccum[11] > 5'd3) 
                n_buffer_11[3] = buffer_11[3]; 
            else  
                n_buffer_11[3] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[3] = buffer_11[3];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd4) begin 
            n_buffer_11[4] = buffer_11[4 + Q];
        end else begin 
            if(buffaccum[11] > 5'd4) 
                n_buffer_11[4] = buffer_11[4]; 
            else  
                n_buffer_11[4] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[4] = buffer_11[4];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd5) begin 
            n_buffer_11[5] = buffer_11[5 + Q];
        end else begin 
            if(buffaccum[11] > 5'd5) 
                n_buffer_11[5] = buffer_11[5]; 
            else  
                n_buffer_11[5] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[5] = buffer_11[5];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd6) begin 
            n_buffer_11[6] = buffer_11[6 + Q];
        end else begin 
            if(buffaccum[11] > 5'd6) 
                n_buffer_11[6] = buffer_11[6]; 
            else  
                n_buffer_11[6] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[6] = buffer_11[6];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd7) begin 
            n_buffer_11[7] = buffer_11[7 + Q];
        end else begin 
            if(buffaccum[11] > 5'd7) 
                n_buffer_11[7] = buffer_11[7]; 
            else  
                n_buffer_11[7] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[7] = buffer_11[7];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd8) begin 
            n_buffer_11[8] = buffer_11[8 + Q];
        end else begin 
            if(buffaccum[11] > 5'd8) 
                n_buffer_11[8] = buffer_11[8]; 
            else  
                n_buffer_11[8] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[8] = buffer_11[8];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd9) begin 
            n_buffer_11[9] = buffer_11[9 + Q];
        end else begin 
            if(buffaccum[11] > 5'd9) 
                n_buffer_11[9] = buffer_11[9]; 
            else  
                n_buffer_11[9] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[9] = buffer_11[9];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd10) begin 
            n_buffer_11[10] = buffer_11[10 + Q];
        end else begin 
            if(buffaccum[11] > 5'd10) 
                n_buffer_11[10] = buffer_11[10]; 
            else  
                n_buffer_11[10] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[10] = buffer_11[10];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd11) begin 
            n_buffer_11[11] = buffer_11[11 + Q];
        end else begin 
            if(buffaccum[11] > 5'd11) 
                n_buffer_11[11] = buffer_11[11]; 
            else  
                n_buffer_11[11] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[11] = buffer_11[11];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd12) begin 
            n_buffer_11[12] = buffer_11[12 + Q];
        end else begin 
            if(buffaccum[11] > 5'd12) 
                n_buffer_11[12] = buffer_11[12]; 
            else  
                n_buffer_11[12] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[12] = buffer_11[12];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd13) begin 
            n_buffer_11[13] = buffer_11[13 + Q];
        end else begin 
            if(buffaccum[11] > 5'd13) 
                n_buffer_11[13] = buffer_11[13]; 
            else  
                n_buffer_11[13] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[13] = buffer_11[13];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd14) begin 
            n_buffer_11[14] = buffer_11[14 + Q];
        end else begin 
            if(buffaccum[11] > 5'd14) 
                n_buffer_11[14] = buffer_11[14]; 
            else  
                n_buffer_11[14] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[14] = buffer_11[14];


    if(psum_set) begin 
        if(export[11] == 1'b1 && buffaccum[11] > 5'd15) begin 
            n_buffer_11[15] = buffer_11[15 + Q];
        end else begin 
            if(buffaccum[11] > 5'd15) 
                n_buffer_11[15] = buffer_11[15]; 
            else  
                n_buffer_11[15] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_11[15] = buffer_11[15];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd16) 
            n_buffer_11[16] = buffer_11[16]; 
        else  
            n_buffer_11[16] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_11[16] = buffer_11[16];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd17) 
            n_buffer_11[17] = buffer_11[17]; 
        else  
            n_buffer_11[17] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_11[17] = buffer_11[17];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd18) 
            n_buffer_11[18] = buffer_11[18]; 
        else  
            n_buffer_11[18] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_11[18] = buffer_11[18];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd19) 
            n_buffer_11[19] = buffer_11[19]; 
        else  
            n_buffer_11[19] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_11[19] = buffer_11[19];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd20) 
            n_buffer_11[20] = buffer_11[20]; 
        else  
            n_buffer_11[20] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_11[20] = buffer_11[20];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd21) 
            n_buffer_11[21] = buffer_11[21]; 
        else  
            n_buffer_11[21] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_11[21] = buffer_11[21];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd22) 
            n_buffer_11[22] = buffer_11[22]; 
        else  
            n_buffer_11[22] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_11[22] = buffer_11[22];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd23) 
            n_buffer_11[23] = buffer_11[23]; 
        else  
            n_buffer_11[23] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_11[23] = buffer_11[23];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd24) 
            n_buffer_11[24] = buffer_11[24]; 
        else  
            n_buffer_11[24] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_11[24] = buffer_11[24];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd25) 
            n_buffer_11[25] = buffer_11[25]; 
        else  
            n_buffer_11[25] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_11[25] = buffer_11[25];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd26) 
            n_buffer_11[26] = buffer_11[26]; 
        else  
            n_buffer_11[26] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_11[26] = buffer_11[26];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd27) 
            n_buffer_11[27] = buffer_11[27]; 
        else  
            n_buffer_11[27] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_11[27] = buffer_11[27];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd28) 
            n_buffer_11[28] = buffer_11[28]; 
        else  
            n_buffer_11[28] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_11[28] = buffer_11[28];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd29) 
            n_buffer_11[29] = buffer_11[29]; 
        else  
            n_buffer_11[29] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_11[29] = buffer_11[29];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd30) 
            n_buffer_11[30] = buffer_11[30]; 
        else  
            n_buffer_11[30] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_11[30] = buffer_11[30];


    if(psum_set) begin 
        if(buffaccum[11] > 5'd31) 
            n_buffer_11[31] = buffer_11[31]; 
        else  
            n_buffer_11[31] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_11[31] = buffer_11[31];

    //============================

    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd0) begin 
            n_buffer_12[0] = buffer_12[0 + Q];
        end else begin 
            if(buffaccum[12] > 5'd0) 
                n_buffer_12[0] = buffer_12[0]; 
            else  
                n_buffer_12[0] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[0] = buffer_12[0];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd1) begin 
            n_buffer_12[1] = buffer_12[1 + Q];
        end else begin 
            if(buffaccum[12] > 5'd1) 
                n_buffer_12[1] = buffer_12[1]; 
            else  
                n_buffer_12[1] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[1] = buffer_12[1];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd2) begin 
            n_buffer_12[2] = buffer_12[2 + Q];
        end else begin 
            if(buffaccum[12] > 5'd2) 
                n_buffer_12[2] = buffer_12[2]; 
            else  
                n_buffer_12[2] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[2] = buffer_12[2];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd3) begin 
            n_buffer_12[3] = buffer_12[3 + Q];
        end else begin 
            if(buffaccum[12] > 5'd3) 
                n_buffer_12[3] = buffer_12[3]; 
            else  
                n_buffer_12[3] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[3] = buffer_12[3];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd4) begin 
            n_buffer_12[4] = buffer_12[4 + Q];
        end else begin 
            if(buffaccum[12] > 5'd4) 
                n_buffer_12[4] = buffer_12[4]; 
            else  
                n_buffer_12[4] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[4] = buffer_12[4];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd5) begin 
            n_buffer_12[5] = buffer_12[5 + Q];
        end else begin 
            if(buffaccum[12] > 5'd5) 
                n_buffer_12[5] = buffer_12[5]; 
            else  
                n_buffer_12[5] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[5] = buffer_12[5];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd6) begin 
            n_buffer_12[6] = buffer_12[6 + Q];
        end else begin 
            if(buffaccum[12] > 5'd6) 
                n_buffer_12[6] = buffer_12[6]; 
            else  
                n_buffer_12[6] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[6] = buffer_12[6];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd7) begin 
            n_buffer_12[7] = buffer_12[7 + Q];
        end else begin 
            if(buffaccum[12] > 5'd7) 
                n_buffer_12[7] = buffer_12[7]; 
            else  
                n_buffer_12[7] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[7] = buffer_12[7];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd8) begin 
            n_buffer_12[8] = buffer_12[8 + Q];
        end else begin 
            if(buffaccum[12] > 5'd8) 
                n_buffer_12[8] = buffer_12[8]; 
            else  
                n_buffer_12[8] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[8] = buffer_12[8];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd9) begin 
            n_buffer_12[9] = buffer_12[9 + Q];
        end else begin 
            if(buffaccum[12] > 5'd9) 
                n_buffer_12[9] = buffer_12[9]; 
            else  
                n_buffer_12[9] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[9] = buffer_12[9];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd10) begin 
            n_buffer_12[10] = buffer_12[10 + Q];
        end else begin 
            if(buffaccum[12] > 5'd10) 
                n_buffer_12[10] = buffer_12[10]; 
            else  
                n_buffer_12[10] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[10] = buffer_12[10];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd11) begin 
            n_buffer_12[11] = buffer_12[11 + Q];
        end else begin 
            if(buffaccum[12] > 5'd11) 
                n_buffer_12[11] = buffer_12[11]; 
            else  
                n_buffer_12[11] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[11] = buffer_12[11];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd12) begin 
            n_buffer_12[12] = buffer_12[12 + Q];
        end else begin 
            if(buffaccum[12] > 5'd12) 
                n_buffer_12[12] = buffer_12[12]; 
            else  
                n_buffer_12[12] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[12] = buffer_12[12];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd13) begin 
            n_buffer_12[13] = buffer_12[13 + Q];
        end else begin 
            if(buffaccum[12] > 5'd13) 
                n_buffer_12[13] = buffer_12[13]; 
            else  
                n_buffer_12[13] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[13] = buffer_12[13];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd14) begin 
            n_buffer_12[14] = buffer_12[14 + Q];
        end else begin 
            if(buffaccum[12] > 5'd14) 
                n_buffer_12[14] = buffer_12[14]; 
            else  
                n_buffer_12[14] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[14] = buffer_12[14];


    if(psum_set) begin 
        if(export[12] == 1'b1 && buffaccum[12] > 5'd15) begin 
            n_buffer_12[15] = buffer_12[15 + Q];
        end else begin 
            if(buffaccum[12] > 5'd15) 
                n_buffer_12[15] = buffer_12[15]; 
            else  
                n_buffer_12[15] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_12[15] = buffer_12[15];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd16) 
            n_buffer_12[16] = buffer_12[16]; 
        else  
            n_buffer_12[16] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_12[16] = buffer_12[16];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd17) 
            n_buffer_12[17] = buffer_12[17]; 
        else  
            n_buffer_12[17] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_12[17] = buffer_12[17];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd18) 
            n_buffer_12[18] = buffer_12[18]; 
        else  
            n_buffer_12[18] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_12[18] = buffer_12[18];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd19) 
            n_buffer_12[19] = buffer_12[19]; 
        else  
            n_buffer_12[19] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_12[19] = buffer_12[19];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd20) 
            n_buffer_12[20] = buffer_12[20]; 
        else  
            n_buffer_12[20] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_12[20] = buffer_12[20];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd21) 
            n_buffer_12[21] = buffer_12[21]; 
        else  
            n_buffer_12[21] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_12[21] = buffer_12[21];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd22) 
            n_buffer_12[22] = buffer_12[22]; 
        else  
            n_buffer_12[22] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_12[22] = buffer_12[22];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd23) 
            n_buffer_12[23] = buffer_12[23]; 
        else  
            n_buffer_12[23] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_12[23] = buffer_12[23];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd24) 
            n_buffer_12[24] = buffer_12[24]; 
        else  
            n_buffer_12[24] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_12[24] = buffer_12[24];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd25) 
            n_buffer_12[25] = buffer_12[25]; 
        else  
            n_buffer_12[25] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_12[25] = buffer_12[25];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd26) 
            n_buffer_12[26] = buffer_12[26]; 
        else  
            n_buffer_12[26] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_12[26] = buffer_12[26];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd27) 
            n_buffer_12[27] = buffer_12[27]; 
        else  
            n_buffer_12[27] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_12[27] = buffer_12[27];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd28) 
            n_buffer_12[28] = buffer_12[28]; 
        else  
            n_buffer_12[28] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_12[28] = buffer_12[28];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd29) 
            n_buffer_12[29] = buffer_12[29]; 
        else  
            n_buffer_12[29] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_12[29] = buffer_12[29];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd30) 
            n_buffer_12[30] = buffer_12[30]; 
        else  
            n_buffer_12[30] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_12[30] = buffer_12[30];


    if(psum_set) begin 
        if(buffaccum[12] > 5'd31) 
            n_buffer_12[31] = buffer_12[31]; 
        else  
            n_buffer_12[31] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_12[31] = buffer_12[31];

    //============================

    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd0) begin 
            n_buffer_13[0] = buffer_13[0 + Q];
        end else begin 
            if(buffaccum[13] > 5'd0) 
                n_buffer_13[0] = buffer_13[0]; 
            else  
                n_buffer_13[0] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[0] = buffer_13[0];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd1) begin 
            n_buffer_13[1] = buffer_13[1 + Q];
        end else begin 
            if(buffaccum[13] > 5'd1) 
                n_buffer_13[1] = buffer_13[1]; 
            else  
                n_buffer_13[1] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[1] = buffer_13[1];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd2) begin 
            n_buffer_13[2] = buffer_13[2 + Q];
        end else begin 
            if(buffaccum[13] > 5'd2) 
                n_buffer_13[2] = buffer_13[2]; 
            else  
                n_buffer_13[2] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[2] = buffer_13[2];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd3) begin 
            n_buffer_13[3] = buffer_13[3 + Q];
        end else begin 
            if(buffaccum[13] > 5'd3) 
                n_buffer_13[3] = buffer_13[3]; 
            else  
                n_buffer_13[3] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[3] = buffer_13[3];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd4) begin 
            n_buffer_13[4] = buffer_13[4 + Q];
        end else begin 
            if(buffaccum[13] > 5'd4) 
                n_buffer_13[4] = buffer_13[4]; 
            else  
                n_buffer_13[4] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[4] = buffer_13[4];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd5) begin 
            n_buffer_13[5] = buffer_13[5 + Q];
        end else begin 
            if(buffaccum[13] > 5'd5) 
                n_buffer_13[5] = buffer_13[5]; 
            else  
                n_buffer_13[5] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[5] = buffer_13[5];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd6) begin 
            n_buffer_13[6] = buffer_13[6 + Q];
        end else begin 
            if(buffaccum[13] > 5'd6) 
                n_buffer_13[6] = buffer_13[6]; 
            else  
                n_buffer_13[6] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[6] = buffer_13[6];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd7) begin 
            n_buffer_13[7] = buffer_13[7 + Q];
        end else begin 
            if(buffaccum[13] > 5'd7) 
                n_buffer_13[7] = buffer_13[7]; 
            else  
                n_buffer_13[7] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[7] = buffer_13[7];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd8) begin 
            n_buffer_13[8] = buffer_13[8 + Q];
        end else begin 
            if(buffaccum[13] > 5'd8) 
                n_buffer_13[8] = buffer_13[8]; 
            else  
                n_buffer_13[8] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[8] = buffer_13[8];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd9) begin 
            n_buffer_13[9] = buffer_13[9 + Q];
        end else begin 
            if(buffaccum[13] > 5'd9) 
                n_buffer_13[9] = buffer_13[9]; 
            else  
                n_buffer_13[9] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[9] = buffer_13[9];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd10) begin 
            n_buffer_13[10] = buffer_13[10 + Q];
        end else begin 
            if(buffaccum[13] > 5'd10) 
                n_buffer_13[10] = buffer_13[10]; 
            else  
                n_buffer_13[10] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[10] = buffer_13[10];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd11) begin 
            n_buffer_13[11] = buffer_13[11 + Q];
        end else begin 
            if(buffaccum[13] > 5'd11) 
                n_buffer_13[11] = buffer_13[11]; 
            else  
                n_buffer_13[11] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[11] = buffer_13[11];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd12) begin 
            n_buffer_13[12] = buffer_13[12 + Q];
        end else begin 
            if(buffaccum[13] > 5'd12) 
                n_buffer_13[12] = buffer_13[12]; 
            else  
                n_buffer_13[12] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[12] = buffer_13[12];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd13) begin 
            n_buffer_13[13] = buffer_13[13 + Q];
        end else begin 
            if(buffaccum[13] > 5'd13) 
                n_buffer_13[13] = buffer_13[13]; 
            else  
                n_buffer_13[13] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[13] = buffer_13[13];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd14) begin 
            n_buffer_13[14] = buffer_13[14 + Q];
        end else begin 
            if(buffaccum[13] > 5'd14) 
                n_buffer_13[14] = buffer_13[14]; 
            else  
                n_buffer_13[14] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[14] = buffer_13[14];


    if(psum_set) begin 
        if(export[13] == 1'b1 && buffaccum[13] > 5'd15) begin 
            n_buffer_13[15] = buffer_13[15 + Q];
        end else begin 
            if(buffaccum[13] > 5'd15) 
                n_buffer_13[15] = buffer_13[15]; 
            else  
                n_buffer_13[15] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_13[15] = buffer_13[15];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd16) 
            n_buffer_13[16] = buffer_13[16]; 
        else  
            n_buffer_13[16] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_13[16] = buffer_13[16];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd17) 
            n_buffer_13[17] = buffer_13[17]; 
        else  
            n_buffer_13[17] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_13[17] = buffer_13[17];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd18) 
            n_buffer_13[18] = buffer_13[18]; 
        else  
            n_buffer_13[18] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_13[18] = buffer_13[18];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd19) 
            n_buffer_13[19] = buffer_13[19]; 
        else  
            n_buffer_13[19] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_13[19] = buffer_13[19];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd20) 
            n_buffer_13[20] = buffer_13[20]; 
        else  
            n_buffer_13[20] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_13[20] = buffer_13[20];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd21) 
            n_buffer_13[21] = buffer_13[21]; 
        else  
            n_buffer_13[21] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_13[21] = buffer_13[21];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd22) 
            n_buffer_13[22] = buffer_13[22]; 
        else  
            n_buffer_13[22] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_13[22] = buffer_13[22];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd23) 
            n_buffer_13[23] = buffer_13[23]; 
        else  
            n_buffer_13[23] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_13[23] = buffer_13[23];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd24) 
            n_buffer_13[24] = buffer_13[24]; 
        else  
            n_buffer_13[24] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_13[24] = buffer_13[24];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd25) 
            n_buffer_13[25] = buffer_13[25]; 
        else  
            n_buffer_13[25] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_13[25] = buffer_13[25];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd26) 
            n_buffer_13[26] = buffer_13[26]; 
        else  
            n_buffer_13[26] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_13[26] = buffer_13[26];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd27) 
            n_buffer_13[27] = buffer_13[27]; 
        else  
            n_buffer_13[27] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_13[27] = buffer_13[27];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd28) 
            n_buffer_13[28] = buffer_13[28]; 
        else  
            n_buffer_13[28] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_13[28] = buffer_13[28];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd29) 
            n_buffer_13[29] = buffer_13[29]; 
        else  
            n_buffer_13[29] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_13[29] = buffer_13[29];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd30) 
            n_buffer_13[30] = buffer_13[30]; 
        else  
            n_buffer_13[30] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_13[30] = buffer_13[30];


    if(psum_set) begin 
        if(buffaccum[13] > 5'd31) 
            n_buffer_13[31] = buffer_13[31]; 
        else  
            n_buffer_13[31] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_13[31] = buffer_13[31];

    //============================

    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd0) begin 
            n_buffer_14[0] = buffer_14[0 + Q];
        end else begin 
            if(buffaccum[14] > 5'd0) 
                n_buffer_14[0] = buffer_14[0]; 
            else  
                n_buffer_14[0] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[0] = buffer_14[0];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd1) begin 
            n_buffer_14[1] = buffer_14[1 + Q];
        end else begin 
            if(buffaccum[14] > 5'd1) 
                n_buffer_14[1] = buffer_14[1]; 
            else  
                n_buffer_14[1] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[1] = buffer_14[1];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd2) begin 
            n_buffer_14[2] = buffer_14[2 + Q];
        end else begin 
            if(buffaccum[14] > 5'd2) 
                n_buffer_14[2] = buffer_14[2]; 
            else  
                n_buffer_14[2] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[2] = buffer_14[2];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd3) begin 
            n_buffer_14[3] = buffer_14[3 + Q];
        end else begin 
            if(buffaccum[14] > 5'd3) 
                n_buffer_14[3] = buffer_14[3]; 
            else  
                n_buffer_14[3] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[3] = buffer_14[3];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd4) begin 
            n_buffer_14[4] = buffer_14[4 + Q];
        end else begin 
            if(buffaccum[14] > 5'd4) 
                n_buffer_14[4] = buffer_14[4]; 
            else  
                n_buffer_14[4] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[4] = buffer_14[4];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd5) begin 
            n_buffer_14[5] = buffer_14[5 + Q];
        end else begin 
            if(buffaccum[14] > 5'd5) 
                n_buffer_14[5] = buffer_14[5]; 
            else  
                n_buffer_14[5] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[5] = buffer_14[5];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd6) begin 
            n_buffer_14[6] = buffer_14[6 + Q];
        end else begin 
            if(buffaccum[14] > 5'd6) 
                n_buffer_14[6] = buffer_14[6]; 
            else  
                n_buffer_14[6] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[6] = buffer_14[6];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd7) begin 
            n_buffer_14[7] = buffer_14[7 + Q];
        end else begin 
            if(buffaccum[14] > 5'd7) 
                n_buffer_14[7] = buffer_14[7]; 
            else  
                n_buffer_14[7] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[7] = buffer_14[7];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd8) begin 
            n_buffer_14[8] = buffer_14[8 + Q];
        end else begin 
            if(buffaccum[14] > 5'd8) 
                n_buffer_14[8] = buffer_14[8]; 
            else  
                n_buffer_14[8] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[8] = buffer_14[8];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd9) begin 
            n_buffer_14[9] = buffer_14[9 + Q];
        end else begin 
            if(buffaccum[14] > 5'd9) 
                n_buffer_14[9] = buffer_14[9]; 
            else  
                n_buffer_14[9] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[9] = buffer_14[9];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd10) begin 
            n_buffer_14[10] = buffer_14[10 + Q];
        end else begin 
            if(buffaccum[14] > 5'd10) 
                n_buffer_14[10] = buffer_14[10]; 
            else  
                n_buffer_14[10] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[10] = buffer_14[10];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd11) begin 
            n_buffer_14[11] = buffer_14[11 + Q];
        end else begin 
            if(buffaccum[14] > 5'd11) 
                n_buffer_14[11] = buffer_14[11]; 
            else  
                n_buffer_14[11] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[11] = buffer_14[11];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd12) begin 
            n_buffer_14[12] = buffer_14[12 + Q];
        end else begin 
            if(buffaccum[14] > 5'd12) 
                n_buffer_14[12] = buffer_14[12]; 
            else  
                n_buffer_14[12] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[12] = buffer_14[12];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd13) begin 
            n_buffer_14[13] = buffer_14[13 + Q];
        end else begin 
            if(buffaccum[14] > 5'd13) 
                n_buffer_14[13] = buffer_14[13]; 
            else  
                n_buffer_14[13] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[13] = buffer_14[13];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd14) begin 
            n_buffer_14[14] = buffer_14[14 + Q];
        end else begin 
            if(buffaccum[14] > 5'd14) 
                n_buffer_14[14] = buffer_14[14]; 
            else  
                n_buffer_14[14] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[14] = buffer_14[14];


    if(psum_set) begin 
        if(export[14] == 1'b1 && buffaccum[14] > 5'd15) begin 
            n_buffer_14[15] = buffer_14[15 + Q];
        end else begin 
            if(buffaccum[14] > 5'd15) 
                n_buffer_14[15] = buffer_14[15]; 
            else  
                n_buffer_14[15] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_14[15] = buffer_14[15];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd16) 
            n_buffer_14[16] = buffer_14[16]; 
        else  
            n_buffer_14[16] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_14[16] = buffer_14[16];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd17) 
            n_buffer_14[17] = buffer_14[17]; 
        else  
            n_buffer_14[17] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_14[17] = buffer_14[17];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd18) 
            n_buffer_14[18] = buffer_14[18]; 
        else  
            n_buffer_14[18] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_14[18] = buffer_14[18];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd19) 
            n_buffer_14[19] = buffer_14[19]; 
        else  
            n_buffer_14[19] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_14[19] = buffer_14[19];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd20) 
            n_buffer_14[20] = buffer_14[20]; 
        else  
            n_buffer_14[20] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_14[20] = buffer_14[20];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd21) 
            n_buffer_14[21] = buffer_14[21]; 
        else  
            n_buffer_14[21] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_14[21] = buffer_14[21];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd22) 
            n_buffer_14[22] = buffer_14[22]; 
        else  
            n_buffer_14[22] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_14[22] = buffer_14[22];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd23) 
            n_buffer_14[23] = buffer_14[23]; 
        else  
            n_buffer_14[23] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_14[23] = buffer_14[23];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd24) 
            n_buffer_14[24] = buffer_14[24]; 
        else  
            n_buffer_14[24] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_14[24] = buffer_14[24];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd25) 
            n_buffer_14[25] = buffer_14[25]; 
        else  
            n_buffer_14[25] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_14[25] = buffer_14[25];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd26) 
            n_buffer_14[26] = buffer_14[26]; 
        else  
            n_buffer_14[26] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_14[26] = buffer_14[26];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd27) 
            n_buffer_14[27] = buffer_14[27]; 
        else  
            n_buffer_14[27] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_14[27] = buffer_14[27];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd28) 
            n_buffer_14[28] = buffer_14[28]; 
        else  
            n_buffer_14[28] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_14[28] = buffer_14[28];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd29) 
            n_buffer_14[29] = buffer_14[29]; 
        else  
            n_buffer_14[29] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_14[29] = buffer_14[29];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd30) 
            n_buffer_14[30] = buffer_14[30]; 
        else  
            n_buffer_14[30] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_14[30] = buffer_14[30];


    if(psum_set) begin 
        if(buffaccum[14] > 5'd31) 
            n_buffer_14[31] = buffer_14[31]; 
        else  
            n_buffer_14[31] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_14[31] = buffer_14[31];

    //============================

    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd0) begin 
            n_buffer_15[0] = buffer_15[0 + Q];
        end else begin 
            if(buffaccum[15] > 5'd0) 
                n_buffer_15[0] = buffer_15[0]; 
            else  
                n_buffer_15[0] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd0) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd0) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd0) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd0) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd0) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd0) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd0) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd0) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd0) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd0) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd0) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd0) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd0) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd0) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd0) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd0) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[0] = buffer_15[0];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd1) begin 
            n_buffer_15[1] = buffer_15[1 + Q];
        end else begin 
            if(buffaccum[15] > 5'd1) 
                n_buffer_15[1] = buffer_15[1]; 
            else  
                n_buffer_15[1] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd1) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd1) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd1) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd1) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd1) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd1) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd1) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd1) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd1) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd1) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd1) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd1) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd1) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd1) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd1) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd1) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[1] = buffer_15[1];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd2) begin 
            n_buffer_15[2] = buffer_15[2 + Q];
        end else begin 
            if(buffaccum[15] > 5'd2) 
                n_buffer_15[2] = buffer_15[2]; 
            else  
                n_buffer_15[2] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd2) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd2) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd2) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd2) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd2) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd2) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd2) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd2) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd2) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd2) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd2) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd2) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd2) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd2) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd2) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd2) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[2] = buffer_15[2];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd3) begin 
            n_buffer_15[3] = buffer_15[3 + Q];
        end else begin 
            if(buffaccum[15] > 5'd3) 
                n_buffer_15[3] = buffer_15[3]; 
            else  
                n_buffer_15[3] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd3) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd3) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd3) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd3) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd3) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd3) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd3) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd3) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd3) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd3) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd3) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd3) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd3) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd3) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd3) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd3) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[3] = buffer_15[3];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd4) begin 
            n_buffer_15[4] = buffer_15[4 + Q];
        end else begin 
            if(buffaccum[15] > 5'd4) 
                n_buffer_15[4] = buffer_15[4]; 
            else  
                n_buffer_15[4] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd4) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd4) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd4) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd4) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd4) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd4) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd4) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd4) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd4) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd4) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd4) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd4) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd4) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd4) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd4) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd4) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[4] = buffer_15[4];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd5) begin 
            n_buffer_15[5] = buffer_15[5 + Q];
        end else begin 
            if(buffaccum[15] > 5'd5) 
                n_buffer_15[5] = buffer_15[5]; 
            else  
                n_buffer_15[5] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd5) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd5) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd5) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd5) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd5) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd5) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd5) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd5) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd5) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd5) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd5) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd5) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd5) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd5) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd5) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd5) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[5] = buffer_15[5];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd6) begin 
            n_buffer_15[6] = buffer_15[6 + Q];
        end else begin 
            if(buffaccum[15] > 5'd6) 
                n_buffer_15[6] = buffer_15[6]; 
            else  
                n_buffer_15[6] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd6) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd6) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd6) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd6) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd6) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd6) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd6) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd6) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd6) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd6) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd6) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd6) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd6) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd6) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd6) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd6) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[6] = buffer_15[6];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd7) begin 
            n_buffer_15[7] = buffer_15[7 + Q];
        end else begin 
            if(buffaccum[15] > 5'd7) 
                n_buffer_15[7] = buffer_15[7]; 
            else  
                n_buffer_15[7] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd7) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd7) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd7) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd7) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd7) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd7) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd7) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd7) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd7) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd7) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd7) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd7) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd7) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd7) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd7) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd7) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[7] = buffer_15[7];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd8) begin 
            n_buffer_15[8] = buffer_15[8 + Q];
        end else begin 
            if(buffaccum[15] > 5'd8) 
                n_buffer_15[8] = buffer_15[8]; 
            else  
                n_buffer_15[8] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd8) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd8) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd8) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd8) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd8) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd8) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd8) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd8) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd8) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd8) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd8) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd8) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd8) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd8) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd8) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd8) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[8] = buffer_15[8];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd9) begin 
            n_buffer_15[9] = buffer_15[9 + Q];
        end else begin 
            if(buffaccum[15] > 5'd9) 
                n_buffer_15[9] = buffer_15[9]; 
            else  
                n_buffer_15[9] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd9) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd9) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd9) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd9) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd9) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd9) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd9) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd9) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd9) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd9) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd9) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd9) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd9) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd9) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd9) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd9) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[9] = buffer_15[9];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd10) begin 
            n_buffer_15[10] = buffer_15[10 + Q];
        end else begin 
            if(buffaccum[15] > 5'd10) 
                n_buffer_15[10] = buffer_15[10]; 
            else  
                n_buffer_15[10] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd10) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd10) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd10) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd10) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd10) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd10) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd10) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd10) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd10) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd10) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd10) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd10) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd10) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd10) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd10) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd10) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[10] = buffer_15[10];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd11) begin 
            n_buffer_15[11] = buffer_15[11 + Q];
        end else begin 
            if(buffaccum[15] > 5'd11) 
                n_buffer_15[11] = buffer_15[11]; 
            else  
                n_buffer_15[11] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd11) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd11) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd11) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd11) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd11) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd11) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd11) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd11) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd11) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd11) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd11) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd11) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd11) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd11) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd11) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd11) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[11] = buffer_15[11];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd12) begin 
            n_buffer_15[12] = buffer_15[12 + Q];
        end else begin 
            if(buffaccum[15] > 5'd12) 
                n_buffer_15[12] = buffer_15[12]; 
            else  
                n_buffer_15[12] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd12) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd12) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd12) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd12) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd12) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd12) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd12) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd12) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd12) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd12) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd12) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd12) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd12) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd12) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd12) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd12) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[12] = buffer_15[12];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd13) begin 
            n_buffer_15[13] = buffer_15[13 + Q];
        end else begin 
            if(buffaccum[15] > 5'd13) 
                n_buffer_15[13] = buffer_15[13]; 
            else  
                n_buffer_15[13] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd13) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd13) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd13) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd13) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd13) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd13) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd13) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd13) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd13) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd13) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd13) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd13) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd13) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd13) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd13) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd13) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[13] = buffer_15[13];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd14) begin 
            n_buffer_15[14] = buffer_15[14 + Q];
        end else begin 
            if(buffaccum[15] > 5'd14) 
                n_buffer_15[14] = buffer_15[14]; 
            else  
                n_buffer_15[14] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd14) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd14) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd14) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd14) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd14) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd14) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd14) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd14) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd14) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd14) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd14) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd14) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd14) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd14) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd14) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd14) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[14] = buffer_15[14];


    if(psum_set) begin 
        if(export[15] == 1'b1 && buffaccum[15] > 5'd15) begin 
            n_buffer_15[15] = buffer_15[15 + Q];
        end else begin 
            if(buffaccum[15] > 5'd15) 
                n_buffer_15[15] = buffer_15[15]; 
            else  
                n_buffer_15[15] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd15) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd15) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd15) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd15) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd15) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd15) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd15) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd15) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd15) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd15) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd15) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd15) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd15) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd15) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd15) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd15) * v_gidx[15]);
        end 
    end else 
        n_buffer_15[15] = buffer_15[15];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd16) 
            n_buffer_15[16] = buffer_15[16]; 
        else  
            n_buffer_15[16] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd16) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd16) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd16) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd16) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd16) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd16) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd16) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd16) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd16) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd16) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd16) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd16) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd16) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd16) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd16) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd16) * v_gidx[15]);
    end else 
        n_buffer_15[16] = buffer_15[16];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd17) 
            n_buffer_15[17] = buffer_15[17]; 
        else  
            n_buffer_15[17] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd17) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd17) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd17) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd17) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd17) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd17) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd17) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd17) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd17) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd17) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd17) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd17) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd17) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd17) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd17) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd17) * v_gidx[15]);
    end else 
        n_buffer_15[17] = buffer_15[17];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd18) 
            n_buffer_15[18] = buffer_15[18]; 
        else  
            n_buffer_15[18] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd18) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd18) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd18) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd18) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd18) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd18) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd18) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd18) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd18) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd18) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd18) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd18) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd18) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd18) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd18) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd18) * v_gidx[15]);
    end else 
        n_buffer_15[18] = buffer_15[18];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd19) 
            n_buffer_15[19] = buffer_15[19]; 
        else  
            n_buffer_15[19] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd19) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd19) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd19) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd19) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd19) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd19) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd19) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd19) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd19) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd19) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd19) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd19) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd19) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd19) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd19) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd19) * v_gidx[15]);
    end else 
        n_buffer_15[19] = buffer_15[19];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd20) 
            n_buffer_15[20] = buffer_15[20]; 
        else  
            n_buffer_15[20] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd20) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd20) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd20) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd20) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd20) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd20) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd20) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd20) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd20) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd20) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd20) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd20) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd20) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd20) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd20) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd20) * v_gidx[15]);
    end else 
        n_buffer_15[20] = buffer_15[20];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd21) 
            n_buffer_15[21] = buffer_15[21]; 
        else  
            n_buffer_15[21] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd21) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd21) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd21) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd21) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd21) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd21) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd21) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd21) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd21) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd21) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd21) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd21) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd21) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd21) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd21) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd21) * v_gidx[15]);
    end else 
        n_buffer_15[21] = buffer_15[21];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd22) 
            n_buffer_15[22] = buffer_15[22]; 
        else  
            n_buffer_15[22] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd22) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd22) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd22) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd22) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd22) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd22) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd22) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd22) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd22) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd22) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd22) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd22) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd22) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd22) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd22) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd22) * v_gidx[15]);
    end else 
        n_buffer_15[22] = buffer_15[22];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd23) 
            n_buffer_15[23] = buffer_15[23]; 
        else  
            n_buffer_15[23] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd23) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd23) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd23) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd23) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd23) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd23) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd23) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd23) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd23) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd23) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd23) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd23) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd23) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd23) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd23) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd23) * v_gidx[15]);
    end else 
        n_buffer_15[23] = buffer_15[23];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd24) 
            n_buffer_15[24] = buffer_15[24]; 
        else  
            n_buffer_15[24] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd24) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd24) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd24) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd24) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd24) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd24) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd24) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd24) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd24) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd24) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd24) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd24) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd24) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd24) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd24) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd24) * v_gidx[15]);
    end else 
        n_buffer_15[24] = buffer_15[24];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd25) 
            n_buffer_15[25] = buffer_15[25]; 
        else  
            n_buffer_15[25] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd25) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd25) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd25) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd25) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd25) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd25) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd25) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd25) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd25) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd25) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd25) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd25) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd25) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd25) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd25) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd25) * v_gidx[15]);
    end else 
        n_buffer_15[25] = buffer_15[25];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd26) 
            n_buffer_15[26] = buffer_15[26]; 
        else  
            n_buffer_15[26] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd26) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd26) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd26) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd26) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd26) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd26) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd26) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd26) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd26) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd26) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd26) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd26) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd26) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd26) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd26) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd26) * v_gidx[15]);
    end else 
        n_buffer_15[26] = buffer_15[26];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd27) 
            n_buffer_15[27] = buffer_15[27]; 
        else  
            n_buffer_15[27] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd27) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd27) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd27) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd27) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd27) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd27) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd27) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd27) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd27) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd27) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd27) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd27) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd27) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd27) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd27) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd27) * v_gidx[15]);
    end else 
        n_buffer_15[27] = buffer_15[27];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd28) 
            n_buffer_15[28] = buffer_15[28]; 
        else  
            n_buffer_15[28] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd28) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd28) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd28) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd28) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd28) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd28) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd28) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd28) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd28) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd28) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd28) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd28) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd28) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd28) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd28) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd28) * v_gidx[15]);
    end else 
        n_buffer_15[28] = buffer_15[28];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd29) 
            n_buffer_15[29] = buffer_15[29]; 
        else  
            n_buffer_15[29] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd29) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd29) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd29) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd29) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd29) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd29) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd29) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd29) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd29) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd29) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd29) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd29) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd29) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd29) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd29) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd29) * v_gidx[15]);
    end else 
        n_buffer_15[29] = buffer_15[29];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd30) 
            n_buffer_15[30] = buffer_15[30]; 
        else  
            n_buffer_15[30] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd30) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd30) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd30) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd30) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd30) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd30) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd30) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd30) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd30) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd30) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd30) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd30) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd30) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd30) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd30) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd30) * v_gidx[15]);
    end else 
        n_buffer_15[30] = buffer_15[30];


    if(psum_set) begin 
        if(buffaccum[15] > 5'd31) 
            n_buffer_15[31] = buffer_15[31]; 
        else  
            n_buffer_15[31] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == 5'd31) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == 5'd31) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == 5'd31) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == 5'd31) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == 5'd31) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == 5'd31) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == 5'd31) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == 5'd31) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == 5'd31) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == 5'd31) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == 5'd31) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == 5'd31) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == 5'd31) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == 5'd31) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == 5'd31) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == 5'd31) * v_gidx[15]);
    end else 
        n_buffer_15[31] = buffer_15[31];

    //============================

end 

// comb7 get xij
reg [PRO_BW-1:0] xijs[0:K-1]; // n_xijs[0:K-1];

integer j, qiter;
wire [7:0] tmpepoch = epoch >= 8'd2 ? epoch - 2 : epoch;
always @* begin 
    for(j = 0; j < K; j = j + 1) begin 
        xijs[j] = mi_j[j] < mj_i[j] ? mi_j[j] : mj_i[j];
    end 
    for(qiter = 0; qiter < Q; qiter = qiter + 1) begin
        nreal_next_arr[qiter] = xijs[next_arr[qiter]] > proposal_nums[qiter] ? next_arr[qiter] : tmpepoch[7:4]; // < xij move, if not stay at current 
    end 
end 
integer mask_i;
always @* begin 
    // loc sram 256 vgindices in one addres
    for(mask_i = 0; mask_i < Q; mask_i = mask_i + 1) begin 
        (* synthesis, parallel_case *)
        case(v_gidx[mask_i][7:0])
            0:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110;
            1:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101;
            2:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011;
            3:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111;
            4:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111;
            5:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111;
            6:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111;
            7:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111;
            8:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111;
            9:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111;
            10:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111;
            11:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111;
            12:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111;
            13:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111;
            14:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111;
            15:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111;
            16:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111;
            17:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111;
            18:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111;
            19:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111;
            20:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111;
            21:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111;
            22:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111;
            23:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111;
            24:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111;
            25:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111;
            26:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111;
            27:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111;
            28:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111;
            29:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111;
            30:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111;
            31:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111;
            32:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111;
            33:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111;
            34:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111;
            35:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111;
            36:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111;
            37:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111;
            38:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111;
            39:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111;
            40:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111;
            41:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111;
            42:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111;
            43:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111;
            44:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111;
            45:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111;
            46:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111;
            47:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111;
            48:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111;
            49:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111;
            50:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111;
            51:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111;
            52:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111;
            53:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111;
            54:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111;
            55:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111;
            56:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111;
            57:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111;
            58:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111;
            59:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111;
            60:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111;
            61:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111;
            62:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111;
            63:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111;
            64:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111;
            65:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111;
            66:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111;
            67:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111;
            68:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111;
            69:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111;
            70:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111;
            71:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111;
            72:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111;
            73:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111;
            74:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111;
            75:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111;
            76:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111;
            77:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111;
            78:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111;
            79:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111;
            80:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111;
            81:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            82:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            83:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            84:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            85:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            86:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            87:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            88:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            89:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            90:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            91:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            92:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            93:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            94:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            95:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            96:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            97:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            98:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            99:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            100:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            101:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            102:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            103:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            104:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            105:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            106:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            107:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            108:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            109:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            110:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            111:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            112:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            113:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            114:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            115:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            116:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            117:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            118:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            119:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            120:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            121:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            122:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            123:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            124:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            125:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            126:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            127:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            128:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            129:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            130:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            131:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            132:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            133:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            134:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            135:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            136:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            137:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            138:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            139:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            140:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            141:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            142:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            143:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            144:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            145:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            146:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            147:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            148:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            149:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            150:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            151:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            152:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            153:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            154:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            155:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            156:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            157:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            158:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            159:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            160:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            161:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            162:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            163:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            164:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            165:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            166:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            167:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            168:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            169:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            170:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            171:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            172:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            173:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            174:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            175:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            176:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            177:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            178:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            179:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            180:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            181:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            182:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            183:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            184:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            185:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            186:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            187:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            188:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            189:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            190:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            191:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            192:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            193:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            194:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            195:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            196:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            197:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            198:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            199:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            200:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            201:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            202:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            203:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            204:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            205:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            206:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            207:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            208:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            209:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            210:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            211:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            212:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            213:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            214:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            215:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            216:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            217:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            218:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            219:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            220:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            221:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            222:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            223:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            224:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            225:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            226:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            227:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            228:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            229:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            230:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            231:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            232:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            233:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            234:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            235:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            236:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            237:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            238:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            239:  n_locsram_wbytemask[mask_i] = 256'b1111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            240:  n_locsram_wbytemask[mask_i] = 256'b1111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            241:  n_locsram_wbytemask[mask_i] = 256'b1111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            242:  n_locsram_wbytemask[mask_i] = 256'b1111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            243:  n_locsram_wbytemask[mask_i] = 256'b1111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            244:  n_locsram_wbytemask[mask_i] = 256'b1111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            245:  n_locsram_wbytemask[mask_i] = 256'b1111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            246:  n_locsram_wbytemask[mask_i] = 256'b1111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            247:  n_locsram_wbytemask[mask_i] = 256'b1111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            248:  n_locsram_wbytemask[mask_i] = 256'b1111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            249:  n_locsram_wbytemask[mask_i] = 256'b1111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            250:  n_locsram_wbytemask[mask_i] = 256'b1111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            251:  n_locsram_wbytemask[mask_i] = 256'b1111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            252:  n_locsram_wbytemask[mask_i] = 256'b1110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            253:  n_locsram_wbytemask[mask_i] = 256'b1101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            254:  n_locsram_wbytemask[mask_i] = 256'b1011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
            255:  n_locsram_wbytemask[mask_i] = 256'b0111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
        endcase 
    end 
end 
// total epoch = N(4096) / Q(16)
integer loci;
integer export_i;
integer ri, rk, rj, si, sk, sq, pi, pj;
always @* begin 
    if(~enable) begin 
        nstate = IDLE;
    end else begin 
        case(state) 
            IDLE: nstate = RUNS;
            RUNS: nstate = (epoch == 8'd255) ? DELAY : RUNS;
            DELAY: nstate = (delay == DONEII) ? FINISH : DELAY;
            FINISH: nstate = FINISH;
        endcase 
    end 
end 
integer bfi, bfidxw;
always @(posedge clk) begin 
    rst_n <= rst_n_in;
    if(~rst_n) begin 
        enable <= 1'b0;
        state <= IDLE;
        psum_set <= 0;
        for(ri = 0; ri < Q; ri = ri + 1) begin 
            next_arr[ri] <= {NEXT_BW{1'b0}};
            proposal_nums[ri] <= {PRO_BW{1'b0}};
            v_gidx[ri] <= {VID_BW{1'b0}};
            real_next_arr[ri] <= {NEXT_BW{1'b0}};
            buff_next[ri] <= {NEXT_BW{1'b0}};
            buff_1_next[ri] <= {NEXT_BW{1'b0}};
            for(rj = 0; rj < K; rj = rj + 1) begin 
                // buffer[rj][2*ri] <= {VID_BW{1'b0}};
                // buffer[rj][2*ri+1] <= {VID_BW{1'b0}};
                partial_sum[ri][rj] <= {OFFSET_BW{1'b0}};
            end 
            buffer_idx[ri] <= {BUF_BW{1'b0}};
        end 
        for(bfi = 0; bfi < 2 * Q; bfi = bfi + 1) begin 
            buffer_0[bfi] <= {VID_BW{1'b0}};  buffer_1[bfi] <= {VID_BW{1'b0}};  buffer_2[bfi] <= {VID_BW{1'b0}};  buffer_3[bfi] <= {VID_BW{1'b0}};  
            buffer_4[bfi] <= {VID_BW{1'b0}};  buffer_5[bfi] <= {VID_BW{1'b0}};  buffer_6[bfi] <= {VID_BW{1'b0}};  buffer_7[bfi] <= {VID_BW{1'b0}};  
            buffer_8[bfi] <= {VID_BW{1'b0}};  buffer_9[bfi] <= {VID_BW{1'b0}};  buffer_10[bfi] <= {VID_BW{1'b0}};  buffer_11[bfi] <= {VID_BW{1'b0}};  
            buffer_12[bfi] <= {VID_BW{1'b0}};  buffer_13[bfi] <= {VID_BW{1'b0}};  buffer_14[bfi] <= {VID_BW{1'b0}};  buffer_15[bfi] <= {VID_BW{1'b0}};  
        end
        vidsram_wen <= {K{1'b1}};
        for(rk = 0; rk < K; rk = rk + 1) begin 
            mi_j[rk] <= {PRO_BW{1'b0}};
            mj_i[rk] <= {PRO_BW{1'b0}};
            // vidsram_wdata[rk] <= {Q*VID_BW-1{1'b0}};
            vidsram_waddr[rk] <= {VID_ADDR_SPACE{1'b0}};
            accum[rk] <= {BUF_BW{1'b0}};
            export[rk] <= 1'b0;
            buffaccum[rk] <= {BUF_BW{1'b0}};
        end 
        vidsram_wdata_0 <= {Q*VID_BW{1'b0}}; vidsram_wdata_8 <= {Q*VID_BW{1'b0}};
        vidsram_wdata_1 <= {Q*VID_BW{1'b0}}; vidsram_wdata_9 <= {Q*VID_BW{1'b0}};
        vidsram_wdata_2 <= {Q*VID_BW{1'b0}}; vidsram_wdata_10 <= {Q*VID_BW{1'b0}};
        vidsram_wdata_3 <= {Q*VID_BW{1'b0}}; vidsram_wdata_11 <= {Q*VID_BW{1'b0}};
        vidsram_wdata_4 <= {Q*VID_BW{1'b0}}; vidsram_wdata_12 <= {Q*VID_BW{1'b0}};
        vidsram_wdata_5 <= {Q*VID_BW{1'b0}}; vidsram_wdata_13 <= {Q*VID_BW{1'b0}};
        vidsram_wdata_6 <= {Q*VID_BW{1'b0}}; vidsram_wdata_14 <= {Q*VID_BW{1'b0}};
        vidsram_wdata_7 <= {Q*VID_BW{1'b0}}; vidsram_wdata_15 <= {Q*VID_BW{1'b0}};
        epoch <= 0;
        ready <= 0;
        finish <= 0;
        delay <= 0;
        locsram_wen <= 1'b1;
        for(loci = 0; loci < Q; loci = loci + 1) begin 
            locsram_wbytemask[loci] <= 256'd0;//n_locsram_wbytemask[loci];
            locsram_addr[loci] <= 8'd0;//v_gidx[loci][VID_BW-1:8];  //15:8 16 bit - 8
        end
    end else begin
        enable <= enable_in;
        state <= nstate; 
        epoch <= n_epoch;
        // $write("epoch: %d\n",epoch);
        delay <= n_delay;
        psum_set <= n_psum_set;
        if(state == FINISH) finish <= 1;
        else                finish <= 0;
        {next_arr[0],next_arr[1],next_arr[2],next_arr[3],next_arr[4],next_arr[5],next_arr[6],next_arr[7],
        next_arr[8],next_arr[9],next_arr[10],next_arr[11],next_arr[12],next_arr[13],next_arr[14],next_arr[15]}
            <= in_next_arr;
        {proposal_nums[0],proposal_nums[1],proposal_nums[2],proposal_nums[3],proposal_nums[4],proposal_nums[5],proposal_nums[6],proposal_nums[7],
        proposal_nums[8],proposal_nums[9],proposal_nums[10],proposal_nums[11],proposal_nums[12],proposal_nums[13],proposal_nums[14],proposal_nums[15]}
            <= in_proposal_nums;
        {v_gidx[0],v_gidx[1],v_gidx[2],v_gidx[3],v_gidx[4],v_gidx[5],v_gidx[6],v_gidx[7],
        v_gidx[8],v_gidx[9],v_gidx[10],v_gidx[11],v_gidx[12],v_gidx[13],v_gidx[14],v_gidx[15]} 
            <= in_v_gidx;
        for(si = 0; si < Q; si = si + 1) begin 
            real_next_arr[si] <= nreal_next_arr[si];
            buff_1_next[si]<= real_next_arr[si];
            buff_next[si] <= buff_1_next[si];
            buffer_idx[si] <= nbuffer_idx[si];
        end 
        for(pi = 0; pi < Q; pi = pi + 1) begin 
            for(pj = 0; pj < K; pj = pj + 1) begin
                 partial_sum[pi][pj] <= n_partial_sum[pi][pj];
            end 
        end 

        {mi_j[0],mi_j[1],mi_j[2],mi_j[3],mi_j[4],mi_j[5],mi_j[6],mi_j[7],
        mi_j[8],mi_j[9],mi_j[10],mi_j[11],mi_j[12],mi_j[13],mi_j[14],mi_j[15]} <= in_mi_j;
        {mj_i[0],mj_i[1],mj_i[2],mj_i[3],mj_i[4],mj_i[5],mj_i[6],mj_i[7],
        mj_i[8],mj_i[9],mj_i[10],mj_i[11],mj_i[12],mj_i[13],mj_i[14],mj_i[15]} <= in_mj_i;
        if(enable && epoch > 4)
            ready <= 1;
        else 
            ready <= 0;
        for(sk = 0; sk < K; sk = sk + 1) begin 
            if(~enable) begin
                accum[sk] <= {BUF_BW{1'b0}};
                export[sk] <= 1'b0;
                buffaccum[sk] <= {BUF_BW{1'b0}};
            end else begin 
                accum[sk] <= n_accum[sk];
                export[sk] <= n_export[sk];
                buffaccum[sk] <= n_buffaccum[sk];
            end 
            // for(sq = 0; sq < 2*Q; sq = sq + 1) begin 
            //     if(~enable) buffer[sk][sq] <= 0;
            //     else buffer[sk][sq] <= n_buffer[sk][sq];
            // end 
        end 
        for(bfidxw = 0; bfidxw < 2 * Q; bfidxw = bfidxw + 1) begin 
            if(~enable) begin 
                buffer_0[bfidxw] <= 0;  buffer_1[bfidxw] <= 0;  buffer_2[bfidxw] <= 0;  buffer_3[bfidxw] <= 0;  
                buffer_4[bfidxw] <= 0;  buffer_5[bfidxw] <= 0;  buffer_6[bfidxw] <= 0;  buffer_7[bfidxw] <= 0;  
                buffer_8[bfidxw] <= 0;  buffer_9[bfidxw] <= 0;  buffer_10[bfidxw] <= 0;  buffer_11[bfidxw] <= 0;  
                buffer_12[bfidxw] <= 0;  buffer_13[bfidxw] <= 0;  buffer_14[bfidxw] <= 0;  buffer_15[bfidxw] <= 0; 
            end else begin 
                buffer_0[bfidxw] <= n_buffer_0[bfidxw]; buffer_1[bfidxw] <= n_buffer_1[bfidxw]; buffer_2[bfidxw] <= n_buffer_2[bfidxw]; buffer_3[bfidxw] <= n_buffer_3[bfidxw]; 
                buffer_4[bfidxw] <= n_buffer_4[bfidxw]; buffer_5[bfidxw] <= n_buffer_5[bfidxw]; buffer_6[bfidxw] <= n_buffer_6[bfidxw]; buffer_7[bfidxw] <= n_buffer_7[bfidxw]; 
                buffer_8[bfidxw] <= n_buffer_8[bfidxw]; buffer_9[bfidxw] <= n_buffer_9[bfidxw]; buffer_10[bfidxw] <= n_buffer_10[bfidxw]; buffer_11[bfidxw] <= n_buffer_11[bfidxw]; 
                buffer_12[bfidxw] <= n_buffer_12[bfidxw]; buffer_13[bfidxw] <= n_buffer_13[bfidxw]; buffer_14[bfidxw] <= n_buffer_14[bfidxw]; buffer_15[bfidxw] <= n_buffer_15[bfidxw];
            end 
        end 

        // write vid sram 
        for(export_i = 0; export_i < K; export_i = export_i + 1) begin 
            if(enable && state >= RUNS) begin 
                if(vidsram_wen[export_i] == 1'b0)  
                    vidsram_waddr[export_i]  <= vidsram_waddr[export_i] + 1;
                if(export[export_i] == 1) begin 
                    // vidsram_wdata[export_i]  <= {buffer[export_i][0],buffer[export_i][1],buffer[export_i][2],buffer[export_i][3],buffer[export_i][4],buffer[export_i][5],buffer[export_i][6],buffer[export_i][7],buffer[export_i][8],buffer[export_i][9],buffer[export_i][10],buffer[export_i][11],buffer[export_i][12],buffer[export_i][13],buffer[export_i][14],buffer[export_i][15]};
                    vidsram_wen[export_i]  <= 1'b0;
                end else begin 
                    vidsram_wen[export_i]  <= 1'b1;
                end 
            end else begin 
                vidsram_wen[export_i]  <= 1'b1;
                vidsram_waddr[export_i] <= 5'd16 & {5{pingpong}};//{5{1'd0}}; // to change ping pong 
            end 
        end 
        vidsram_wdata_0 <= {buffer_0[0],buffer_0[1],buffer_0[2],buffer_0[3],buffer_0[4],buffer_0[5],buffer_0[6],buffer_0[7],buffer_0[8],buffer_0[9],buffer_0[10],buffer_0[11],buffer_0[12],buffer_0[13],buffer_0[14],buffer_0[15]} ; 
        vidsram_wdata_1 <= {buffer_1[0],buffer_1[1],buffer_1[2],buffer_1[3],buffer_1[4],buffer_1[5],buffer_1[6],buffer_1[7],buffer_1[8],buffer_1[9],buffer_1[10],buffer_1[11],buffer_1[12],buffer_1[13],buffer_1[14],buffer_1[15]} ; 
        vidsram_wdata_2 <= {buffer_2[0],buffer_2[1],buffer_2[2],buffer_2[3],buffer_2[4],buffer_2[5],buffer_2[6],buffer_2[7],buffer_2[8],buffer_2[9],buffer_2[10],buffer_2[11],buffer_2[12],buffer_2[13],buffer_2[14],buffer_2[15]} ; 
        vidsram_wdata_3 <= {buffer_3[0],buffer_3[1],buffer_3[2],buffer_3[3],buffer_3[4],buffer_3[5],buffer_3[6],buffer_3[7],buffer_3[8],buffer_3[9],buffer_3[10],buffer_3[11],buffer_3[12],buffer_3[13],buffer_3[14],buffer_3[15]} ; 
        vidsram_wdata_4 <= {buffer_4[0],buffer_4[1],buffer_4[2],buffer_4[3],buffer_4[4],buffer_4[5],buffer_4[6],buffer_4[7],buffer_4[8],buffer_4[9],buffer_4[10],buffer_4[11],buffer_4[12],buffer_4[13],buffer_4[14],buffer_4[15]} ; 
        vidsram_wdata_5 <= {buffer_5[0],buffer_5[1],buffer_5[2],buffer_5[3],buffer_5[4],buffer_5[5],buffer_5[6],buffer_5[7],buffer_5[8],buffer_5[9],buffer_5[10],buffer_5[11],buffer_5[12],buffer_5[13],buffer_5[14],buffer_5[15]} ; 
        vidsram_wdata_6 <= {buffer_6[0],buffer_6[1],buffer_6[2],buffer_6[3],buffer_6[4],buffer_6[5],buffer_6[6],buffer_6[7],buffer_6[8],buffer_6[9],buffer_6[10],buffer_6[11],buffer_6[12],buffer_6[13],buffer_6[14],buffer_6[15]} ; 
        vidsram_wdata_7 <= {buffer_7[0],buffer_7[1],buffer_7[2],buffer_7[3],buffer_7[4],buffer_7[5],buffer_7[6],buffer_7[7],buffer_7[8],buffer_7[9],buffer_7[10],buffer_7[11],buffer_7[12],buffer_7[13],buffer_7[14],buffer_7[15]} ; 
        vidsram_wdata_8 <= {buffer_8[0],buffer_8[1],buffer_8[2],buffer_8[3],buffer_8[4],buffer_8[5],buffer_8[6],buffer_8[7],buffer_8[8],buffer_8[9],buffer_8[10],buffer_8[11],buffer_8[12],buffer_8[13],buffer_8[14],buffer_8[15]} ;
        vidsram_wdata_9 <= {buffer_9[0],buffer_9[1],buffer_9[2],buffer_9[3],buffer_9[4],buffer_9[5],buffer_9[6],buffer_9[7],buffer_9[8],buffer_9[9],buffer_9[10],buffer_9[11],buffer_9[12],buffer_9[13],buffer_9[14],buffer_9[15]} ;
        vidsram_wdata_10 <= {buffer_10[0],buffer_10[1],buffer_10[2],buffer_10[3],buffer_10[4],buffer_10[5],buffer_10[6],buffer_10[7],buffer_10[8],buffer_10[9],buffer_10[10],buffer_10[11],buffer_10[12],buffer_10[13],buffer_10[14],buffer_10[15]} ;
        vidsram_wdata_11 <= {buffer_11[0],buffer_11[1],buffer_11[2],buffer_11[3],buffer_11[4],buffer_11[5],buffer_11[6],buffer_11[7],buffer_11[8],buffer_11[9],buffer_11[10],buffer_11[11],buffer_11[12],buffer_11[13],buffer_11[14],buffer_11[15]} ;
        vidsram_wdata_12 <= {buffer_12[0],buffer_12[1],buffer_12[2],buffer_12[3],buffer_12[4],buffer_12[5],buffer_12[6],buffer_12[7],buffer_12[8],buffer_12[9],buffer_12[10],buffer_12[11],buffer_12[12],buffer_12[13],buffer_12[14],buffer_12[15]} ;
        vidsram_wdata_13 <= {buffer_13[0],buffer_13[1],buffer_13[2],buffer_13[3],buffer_13[4],buffer_13[5],buffer_13[6],buffer_13[7],buffer_13[8],buffer_13[9],buffer_13[10],buffer_13[11],buffer_13[12],buffer_13[13],buffer_13[14],buffer_13[15]} ;
        vidsram_wdata_14 <= {buffer_14[0],buffer_14[1],buffer_14[2],buffer_14[3],buffer_14[4],buffer_14[5],buffer_14[6],buffer_14[7],buffer_14[8],buffer_14[9],buffer_14[10],buffer_14[11],buffer_14[12],buffer_14[13],buffer_14[14],buffer_14[15]} ;
        vidsram_wdata_15 <= {buffer_15[0],buffer_15[1],buffer_15[2],buffer_15[3],buffer_15[4],buffer_15[5],buffer_15[6],buffer_15[7],buffer_15[8],buffer_15[9],buffer_15[10],buffer_15[11],buffer_15[12],buffer_15[13],buffer_15[14],buffer_15[15]} ;
        // write loc sram
        locsram_wdata[0] <= buff_next[0];   locsram_wdata[8] <= buff_next[8];
        locsram_wdata[1] <= buff_next[1];   locsram_wdata[9] <= buff_next[9];
        locsram_wdata[2] <= buff_next[2];   locsram_wdata[10] <= buff_next[10];
        locsram_wdata[3] <= buff_next[3];   locsram_wdata[11] <= buff_next[11];
        locsram_wdata[4] <= buff_next[4];   locsram_wdata[12] <= buff_next[12];
        locsram_wdata[5] <= buff_next[5];   locsram_wdata[13] <= buff_next[13];
        locsram_wdata[6] <= buff_next[6];   locsram_wdata[14] <= buff_next[14];
        locsram_wdata[7] <= buff_next[7];   locsram_wdata[15] <= buff_next[15];
        
        if(psum_set) begin 
            // next_arr -> next_real_arr -> buff_next "write out" 
            locsram_wen <= 1'b0;
            for(loci = 0; loci < Q; loci = loci + 1) begin 
                // locsram_wdata[loci] <= {D{1'b1, buff_next[loci]}};
                locsram_wbytemask[loci] <= n_locsram_wbytemask[loci];
                // locsram_wen[loci] <= 1'b0; //loci th "bit"
                locsram_addr[loci] <= v_gidx[loci][VID_BW-1:8];  //15:8 16 bit - 8
            end
        end else begin 
            locsram_wen <= 1'b1;
            // for(loci = 0; loci < Q; loci = loci + 1) begin 
            //     locsram_wen[loci] <= 1'b1; //loci th "bit"
            // end
        end 
        // TODO: start update read_waddr of vid ! 

    end 
end 


endmodule
// TODO : set valid bit to zero in last batch of worker before master start 