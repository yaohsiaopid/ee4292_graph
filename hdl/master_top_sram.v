module master_top_sram #(
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
parameter LOC_ADDR_SPACE = 8, //4 2^16/256,
parameter NEXT_ADDR_SPACE = 4,
parameter PRO_ADDR_SPACE = 4
) (
input clk,
input rst_n_in, 
input enable_in,
// inputs 
input [NEXT_BW*Q-1:0] next_sram_rdata0, input [NEXT_BW*Q-1:0] next_sram_rdata8,
input [NEXT_BW*Q-1:0] next_sram_rdata1, input [NEXT_BW*Q-1:0] next_sram_rdata9,
input [NEXT_BW*Q-1:0] next_sram_rdata2, input [NEXT_BW*Q-1:0] next_sram_rdata10,
input [NEXT_BW*Q-1:0] next_sram_rdata3, input [NEXT_BW*Q-1:0] next_sram_rdata11,
input [NEXT_BW*Q-1:0] next_sram_rdata4, input [NEXT_BW*Q-1:0] next_sram_rdata12,
input [NEXT_BW*Q-1:0] next_sram_rdata5, input [NEXT_BW*Q-1:0] next_sram_rdata13,
input [NEXT_BW*Q-1:0] next_sram_rdata6, input [NEXT_BW*Q-1:0] next_sram_rdata14,
input [NEXT_BW*Q-1:0] next_sram_rdata7, input [NEXT_BW*Q-1:0] next_sram_rdata15,

input [PRO_BW*Q-1:0] proposal_sram_rdata0, input [PRO_BW*Q-1:0] proposal_sram_rdata8,
input [PRO_BW*Q-1:0] proposal_sram_rdata1, input [PRO_BW*Q-1:0] proposal_sram_rdata9,
input [PRO_BW*Q-1:0] proposal_sram_rdata2, input [PRO_BW*Q-1:0] proposal_sram_rdata10,
input [PRO_BW*Q-1:0] proposal_sram_rdata3, input [PRO_BW*Q-1:0] proposal_sram_rdata11,
input [PRO_BW*Q-1:0] proposal_sram_rdata4, input [PRO_BW*Q-1:0] proposal_sram_rdata12,
input [PRO_BW*Q-1:0] proposal_sram_rdata5, input [PRO_BW*Q-1:0] proposal_sram_rdata13,
input [PRO_BW*Q-1:0] proposal_sram_rdata6, input [PRO_BW*Q-1:0] proposal_sram_rdata14,
input [PRO_BW*Q-1:0] proposal_sram_rdata7, input [PRO_BW*Q-1:0] proposal_sram_rdata15,

input [VID_BW*Q-1:0] vid_sram_rdata0, input [VID_BW*Q-1:0] vid_sram_rdata8,
input [VID_BW*Q-1:0] vid_sram_rdata1, input [VID_BW*Q-1:0] vid_sram_rdata9,
input [VID_BW*Q-1:0] vid_sram_rdata2, input [VID_BW*Q-1:0] vid_sram_rdata10,
input [VID_BW*Q-1:0] vid_sram_rdata3, input [VID_BW*Q-1:0] vid_sram_rdata11,
input [VID_BW*Q-1:0] vid_sram_rdata4, input [VID_BW*Q-1:0] vid_sram_rdata12,
input [VID_BW*Q-1:0] vid_sram_rdata5, input [VID_BW*Q-1:0] vid_sram_rdata13,
input [VID_BW*Q-1:0] vid_sram_rdata6, input [VID_BW*Q-1:0] vid_sram_rdata14,
input [VID_BW*Q-1:0] vid_sram_rdata7, input [VID_BW*Q-1:0] vid_sram_rdata15,


input [PRO_BW*K-1:0] in_mi_j, 
input [PRO_BW*K-1:0] in_mj_i, 
// input [VID_BW*Q-1:0] in_v_gidx, 
// input [PRO_BW*Q-1:0] in_proposal_nums,
input pingpong,
// outputs 
output reg [NEXT_ADDR_SPACE-1:0] next_sram_raddr,
// output reg [PRO_ADDR_SPACE-1:0] pronum_sram_raddr,
output reg [VID_ADDR_SPACE-1:0] vid_sram_raddr,
output reg [7:0] epoch,
output reg [K-1:0] vidsram_wen, // 0 at MSB
output reg locsram_wen,
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
localparam DONEII = 5;
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
reg [3:0] select_vid;
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
// reg [VID_BW-1:0] buffer [0:K-1] [0:2*Q-2], n_buffer[0:K-1][0:2*Q-2];
reg [VID_BW-1:0] buffer_0[0:2*Q-2],buffer_1[0:2*Q-2],buffer_2[0:2*Q-2],buffer_3[0:2*Q-2],
buffer_4[0:2*Q-2],buffer_5[0:2*Q-2],buffer_6[0:2*Q-2],buffer_7[0:2*Q-2],
buffer_8[0:2*Q-2],buffer_9[0:2*Q-2],buffer_10[0:2*Q-2],buffer_11[0:2*Q-2],
buffer_12[0:2*Q-2],buffer_13[0:2*Q-2],buffer_14[0:2*Q-2],buffer_15[0:2*Q-2];
reg [VID_BW-1:0] n_buffer_0[0:2*Q-2],n_buffer_1[0:2*Q-2],n_buffer_2[0:2*Q-2],n_buffer_3[0:2*Q-2],
n_buffer_4[0:2*Q-2],n_buffer_5[0:2*Q-2],n_buffer_6[0:2*Q-2],n_buffer_7[0:2*Q-2],
n_buffer_8[0:2*Q-2],n_buffer_9[0:2*Q-2],n_buffer_10[0:2*Q-2],n_buffer_11[0:2*Q-2],
n_buffer_12[0:2*Q-2],n_buffer_13[0:2*Q-2],n_buffer_14[0:2*Q-2],n_buffer_15[0:2*Q-2];

reg [BUF_BW-1:0] accum[0:K-1], n_accum[0:K-1]; // buffer size for each of K buffers
reg [BUF_BW-1:0] buffer_idx[0:Q-1], nbuffer_idx[0:Q-1]; // additioanl bit??
reg export[0:K-1], n_export[0:K-1];
reg [BUF_BW-2:0] buffaccum[0:K-1], n_buffaccum[0:K-1]; // for buffer indexing's accum
reg [K-1:0] onehot[0:Q-1];
reg [OFFSET_BW-1:0] partial_sum[0:Q-1][0:K-1],n_partial_sum[0:Q-1][0:K-1];
reg psum_set, n_psum_set;
reg [NEXT_BW*Q-1:0] in_next_arr;
reg [PRO_BW*Q-1:0] in_proposal_nums;
reg [VID_BW*Q-1:0] in_v_gidx;
integer o_idx, in_idx;
integer accumidx;
integer partial_i, partial_j, check_i;
integer buffi,buffj;
reg [7:0] epoch_buff;
always @* begin 
    (* synthesis, parallel_case *)
    case(epoch_buff[7:4])
	    4'd0: in_next_arr = next_sram_rdata0;
	    4'd1: in_next_arr = next_sram_rdata1;
	    4'd2: in_next_arr = next_sram_rdata2;
	    4'd3: in_next_arr = next_sram_rdata3;
	    4'd4: in_next_arr = next_sram_rdata4;
	    4'd5: in_next_arr = next_sram_rdata5;
	    4'd6: in_next_arr = next_sram_rdata6;
	    4'd7: in_next_arr = next_sram_rdata7;
	    4'd8: in_next_arr = next_sram_rdata8;
	    4'd9: in_next_arr = next_sram_rdata9;
	    4'd10: in_next_arr = next_sram_rdata10;
	    4'd11: in_next_arr = next_sram_rdata11;
	    4'd12: in_next_arr = next_sram_rdata12;
	    4'd13: in_next_arr = next_sram_rdata13;
	    4'd14: in_next_arr = next_sram_rdata14;
	    4'd15: in_next_arr = next_sram_rdata15;
  	endcase

    (* synthesis, parallel_case *)
    case(epoch_buff[7:4])
        4'd0: in_proposal_nums = proposal_sram_rdata0;
	    4'd1: in_proposal_nums = proposal_sram_rdata1;
	    4'd2: in_proposal_nums = proposal_sram_rdata2;
	    4'd3: in_proposal_nums = proposal_sram_rdata3;
	    4'd4: in_proposal_nums = proposal_sram_rdata4;
	    4'd5: in_proposal_nums = proposal_sram_rdata5;
	    4'd6: in_proposal_nums = proposal_sram_rdata6;
	    4'd7: in_proposal_nums = proposal_sram_rdata7;
	    4'd8: in_proposal_nums = proposal_sram_rdata8;
	    4'd9: in_proposal_nums = proposal_sram_rdata9;
	    4'd10: in_proposal_nums = proposal_sram_rdata10;
	    4'd11: in_proposal_nums = proposal_sram_rdata11;
	    4'd12: in_proposal_nums = proposal_sram_rdata12;
	    4'd13: in_proposal_nums = proposal_sram_rdata13;
	    4'd14: in_proposal_nums = proposal_sram_rdata14;
	    4'd15: in_proposal_nums = proposal_sram_rdata15;
	endcase

    (* synthesis, parallel_case *)
    case(select_vid) 
        4'd0: in_v_gidx = vid_sram_rdata0;
        4'd1: in_v_gidx = vid_sram_rdata1;
        4'd2: in_v_gidx = vid_sram_rdata2;
        4'd3: in_v_gidx = vid_sram_rdata3;
        4'd4: in_v_gidx = vid_sram_rdata4;
        4'd5: in_v_gidx = vid_sram_rdata5;
        4'd6: in_v_gidx = vid_sram_rdata6;
        4'd7: in_v_gidx = vid_sram_rdata7;
        4'd8: in_v_gidx = vid_sram_rdata8;
        4'd9: in_v_gidx = vid_sram_rdata9;
        4'd10: in_v_gidx = vid_sram_rdata10;
        4'd11: in_v_gidx = vid_sram_rdata11;
        4'd12: in_v_gidx = vid_sram_rdata12;
        4'd13: in_v_gidx = vid_sram_rdata13;
        4'd14: in_v_gidx = vid_sram_rdata14;
        4'd15: in_v_gidx = vid_sram_rdata15;
    endcase 
end 
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
        if(~enable) nbuffer_idx[partial_i] = 0;
        else begin 
        if(psum_set) 
        nbuffer_idx[partial_i] = (partial_sum[partial_i][buff_1_next[partial_i]] - 1) + (accum[buff_1_next[partial_i]] >= Q ? accum[buff_1_next[partial_i]] - Q : accum[buff_1_next[partial_i]]) ;
        else 
        nbuffer_idx[partial_i] = buffer_idx[partial_i];
        // TODO: accum[q] == Q also update to partial_sum[15][q], / transfer out 
        end 
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
// handle n_buffer_0~15[0:31]
always @* begin
    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[0] == 1 && buffaccum[0] > buffj) begin 
                n_buffer_0[buffj] = buffer_0[buffj + Q];
            end else begin 
                if(buffaccum[0] > buffj)  n_buffer_0[buffj] = buffer_0[buffj]; 
                else                        n_buffer_0[buffj] =
                    ((buff_next[0] == 4'd0) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_0[buffj] = buffer_0[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_0[buffj] = ((buff_next[0] == 4'd0) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd0) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd0) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd0) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd0) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd0) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd0) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd0) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd0) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd0) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd0) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd0) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd0) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd0) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd0) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd0) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_0[buffj] = buffer_0[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[1] == 1 && buffaccum[1] > buffj) begin 
                n_buffer_1[buffj] = buffer_1[buffj + Q];
            end else begin 
                if(buffaccum[1] > buffj)  n_buffer_1[buffj] = buffer_1[buffj]; 
                else                        n_buffer_1[buffj] =
                    ((buff_next[0] == 4'd1) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_1[buffj] = buffer_1[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_1[buffj] = ((buff_next[0] == 4'd1) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd1) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd1) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd1) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd1) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd1) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd1) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd1) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd1) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd1) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd1) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd1) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd1) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd1) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd1) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd1) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_1[buffj] = buffer_1[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[2] == 1 && buffaccum[2] > buffj) begin 
                n_buffer_2[buffj] = buffer_2[buffj + Q];
            end else begin 
                if(buffaccum[2] > buffj)  n_buffer_2[buffj] = buffer_2[buffj]; 
                else                        n_buffer_2[buffj] =
                    ((buff_next[0] == 4'd2) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_2[buffj] = buffer_2[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_2[buffj] = ((buff_next[0] == 4'd2) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd2) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd2) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd2) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd2) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd2) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd2) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd2) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd2) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd2) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd2) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd2) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd2) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd2) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd2) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd2) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_2[buffj] = buffer_2[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[3] == 1 && buffaccum[3] > buffj) begin 
                n_buffer_3[buffj] = buffer_3[buffj + Q];
            end else begin 
                if(buffaccum[3] > buffj)  n_buffer_3[buffj] = buffer_3[buffj]; 
                else                        n_buffer_3[buffj] =
                    ((buff_next[0] == 4'd3) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_3[buffj] = buffer_3[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_3[buffj] = ((buff_next[0] == 4'd3) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd3) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd3) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd3) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd3) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd3) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd3) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd3) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd3) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd3) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd3) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd3) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd3) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd3) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd3) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd3) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_3[buffj] = buffer_3[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[4] == 1 && buffaccum[4] > buffj) begin 
                n_buffer_4[buffj] = buffer_4[buffj + Q];
            end else begin 
                if(buffaccum[4] > buffj)  n_buffer_4[buffj] = buffer_4[buffj]; 
                else                        n_buffer_4[buffj] =
                    ((buff_next[0] == 4'd4) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_4[buffj] = buffer_4[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_4[buffj] = ((buff_next[0] == 4'd4) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd4) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd4) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd4) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd4) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd4) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd4) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd4) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd4) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd4) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd4) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd4) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd4) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd4) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd4) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd4) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_4[buffj] = buffer_4[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[5] == 1 && buffaccum[5] > buffj) begin 
                n_buffer_5[buffj] = buffer_5[buffj + Q];
            end else begin 
                if(buffaccum[5] > buffj)  n_buffer_5[buffj] = buffer_5[buffj]; 
                else                        n_buffer_5[buffj] =
                    ((buff_next[0] == 4'd5) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_5[buffj] = buffer_5[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_5[buffj] = ((buff_next[0] == 4'd5) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd5) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd5) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd5) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd5) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd5) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd5) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd5) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd5) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd5) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd5) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd5) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd5) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd5) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd5) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd5) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_5[buffj] = buffer_5[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[6] == 1 && buffaccum[6] > buffj) begin 
                n_buffer_6[buffj] = buffer_6[buffj + Q];
            end else begin 
                if(buffaccum[6] > buffj)  n_buffer_6[buffj] = buffer_6[buffj]; 
                else                        n_buffer_6[buffj] =
                    ((buff_next[0] == 4'd6) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_6[buffj] = buffer_6[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_6[buffj] = ((buff_next[0] == 4'd6) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd6) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd6) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd6) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd6) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd6) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd6) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd6) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd6) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd6) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd6) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd6) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd6) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd6) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd6) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd6) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_6[buffj] = buffer_6[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[7] == 1 && buffaccum[7] > buffj) begin 
                n_buffer_7[buffj] = buffer_7[buffj + Q];
            end else begin 
                if(buffaccum[7] > buffj)  n_buffer_7[buffj] = buffer_7[buffj]; 
                else                        n_buffer_7[buffj] =
                    ((buff_next[0] == 4'd7) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_7[buffj] = buffer_7[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_7[buffj] = ((buff_next[0] == 4'd7) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd7) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd7) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd7) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd7) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd7) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd7) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd7) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd7) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd7) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd7) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd7) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd7) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd7) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd7) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd7) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_7[buffj] = buffer_7[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[8] == 1 && buffaccum[8] > buffj) begin 
                n_buffer_8[buffj] = buffer_8[buffj + Q];
            end else begin 
                if(buffaccum[8] > buffj)  n_buffer_8[buffj] = buffer_8[buffj]; 
                else                        n_buffer_8[buffj] =
                    ((buff_next[0] == 4'd8) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_8[buffj] = buffer_8[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_8[buffj] = ((buff_next[0] == 4'd8) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd8) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd8) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd8) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd8) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd8) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd8) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd8) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd8) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd8) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd8) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd8) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd8) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd8) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd8) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd8) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_8[buffj] = buffer_8[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[9] == 1 && buffaccum[9] > buffj) begin 
                n_buffer_9[buffj] = buffer_9[buffj + Q];
            end else begin 
                if(buffaccum[9] > buffj)  n_buffer_9[buffj] = buffer_9[buffj]; 
                else                        n_buffer_9[buffj] =
                    ((buff_next[0] == 4'd9) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_9[buffj] = buffer_9[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_9[buffj] = ((buff_next[0] == 4'd9) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd9) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd9) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd9) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd9) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd9) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd9) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd9) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd9) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd9) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd9) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd9) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd9) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd9) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd9) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd9) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_9[buffj] = buffer_9[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[10] == 1 && buffaccum[10] > buffj) begin 
                n_buffer_10[buffj] = buffer_10[buffj + Q];
            end else begin 
                if(buffaccum[10] > buffj)  n_buffer_10[buffj] = buffer_10[buffj]; 
                else                        n_buffer_10[buffj] =
                    ((buff_next[0] == 4'd10) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_10[buffj] = buffer_10[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_10[buffj] = ((buff_next[0] == 4'd10) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd10) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd10) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd10) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd10) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd10) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd10) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd10) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd10) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd10) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd10) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd10) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd10) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd10) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd10) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd10) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_10[buffj] = buffer_10[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[11] == 1 && buffaccum[11] > buffj) begin 
                n_buffer_11[buffj] = buffer_11[buffj + Q];
            end else begin 
                if(buffaccum[11] > buffj)  n_buffer_11[buffj] = buffer_11[buffj]; 
                else                        n_buffer_11[buffj] =
                    ((buff_next[0] == 4'd11) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_11[buffj] = buffer_11[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_11[buffj] = ((buff_next[0] == 4'd11) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd11) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd11) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd11) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd11) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd11) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd11) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd11) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd11) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd11) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd11) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd11) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd11) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd11) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd11) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd11) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_11[buffj] = buffer_11[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[12] == 1 && buffaccum[12] > buffj) begin 
                n_buffer_12[buffj] = buffer_12[buffj + Q];
            end else begin 
                if(buffaccum[12] > buffj)  n_buffer_12[buffj] = buffer_12[buffj]; 
                else                        n_buffer_12[buffj] =
                    ((buff_next[0] == 4'd12) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_12[buffj] = buffer_12[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_12[buffj] = ((buff_next[0] == 4'd12) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd12) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd12) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd12) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd12) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd12) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd12) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd12) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd12) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd12) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd12) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd12) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd12) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd12) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd12) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd12) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_12[buffj] = buffer_12[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[13] == 1 && buffaccum[13] > buffj) begin 
                n_buffer_13[buffj] = buffer_13[buffj + Q];
            end else begin 
                if(buffaccum[13] > buffj)  n_buffer_13[buffj] = buffer_13[buffj]; 
                else                        n_buffer_13[buffj] =
                    ((buff_next[0] == 4'd13) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_13[buffj] = buffer_13[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_13[buffj] = ((buff_next[0] == 4'd13) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd13) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd13) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd13) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd13) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd13) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd13) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd13) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd13) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd13) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd13) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd13) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd13) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd13) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd13) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd13) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_13[buffj] = buffer_13[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[14] == 1 && buffaccum[14] > buffj) begin 
                n_buffer_14[buffj] = buffer_14[buffj + Q];
            end else begin 
                if(buffaccum[14] > buffj)  n_buffer_14[buffj] = buffer_14[buffj]; 
                else                        n_buffer_14[buffj] =
                    ((buff_next[0] == 4'd14) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_14[buffj] = buffer_14[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_14[buffj] = ((buff_next[0] == 4'd14) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd14) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd14) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd14) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd14) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd14) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd14) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd14) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd14) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd14) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd14) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd14) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd14) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd14) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd14) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd14) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_14[buffj] = buffer_14[buffj];
    end 

    //--------

    for(buffj = 0; buffj < Q - 1; buffj = buffj + 1) begin  
        if(psum_set) begin 
            if(export[15] == 1 && buffaccum[15] > buffj) begin 
                n_buffer_15[buffj] = buffer_15[buffj + Q];
            end else begin 
                if(buffaccum[15] > buffj)  n_buffer_15[buffj] = buffer_15[buffj]; 
                else                        n_buffer_15[buffj] =
                    ((buff_next[0] == 4'd15) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == buffj) * v_gidx[15]);
            end 
        end else begin 
            n_buffer_15[buffj] = buffer_15[buffj];
        end 
    end 

    //--------

    for(buffj = Q - 1; buffj < 2*Q-1; buffj = buffj + 1) begin  
        if(psum_set)  
            n_buffer_15[buffj] = ((buff_next[0] == 4'd15) * (buffer_idx[0] == buffj) * v_gidx[0]) | ((buff_next[1] == 4'd15) * (buffer_idx[1] == buffj) * v_gidx[1]) | ((buff_next[2] == 4'd15) * (buffer_idx[2] == buffj) * v_gidx[2]) | ((buff_next[3] == 4'd15) * (buffer_idx[3] == buffj) * v_gidx[3]) | ((buff_next[4] == 4'd15) * (buffer_idx[4] == buffj) * v_gidx[4]) | ((buff_next[5] == 4'd15) * (buffer_idx[5] == buffj) * v_gidx[5]) | ((buff_next[6] == 4'd15) * (buffer_idx[6] == buffj) * v_gidx[6]) | ((buff_next[7] == 4'd15) * (buffer_idx[7] == buffj) * v_gidx[7]) | ((buff_next[8] == 4'd15) * (buffer_idx[8] == buffj) * v_gidx[8]) | ((buff_next[9] == 4'd15) * (buffer_idx[9] == buffj) * v_gidx[9]) | ((buff_next[10] == 4'd15) * (buffer_idx[10] == buffj) * v_gidx[10]) | ((buff_next[11] == 4'd15) * (buffer_idx[11] == buffj) * v_gidx[11]) | ((buff_next[12] == 4'd15) * (buffer_idx[12] == buffj) * v_gidx[12]) | ((buff_next[13] == 4'd15) * (buffer_idx[13] == buffj) * v_gidx[13]) | ((buff_next[14] == 4'd15) * (buffer_idx[14] == buffj) * v_gidx[14]) | ((buff_next[15] == 4'd15) * (buffer_idx[15] == buffj) * v_gidx[15]);
        else 
            n_buffer_15[buffj] = buffer_15[buffj];
    end 

    //--------
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
        for(bfi = 0; bfi < 2 * Q - 1; bfi = bfi + 1) begin 
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
        finish <= 0;
        delay <= 0;
        locsram_wen <= 1'b1;
        for(loci = 0; loci < Q; loci = loci + 1) begin 
            locsram_wbytemask[loci] <= 256'd0;//n_locsram_wbytemask[loci];
            locsram_addr[loci] <= 8'd0;//v_gidx[loci][VID_BW-1:8];  //15:8 16 bit - 8
        end
        next_sram_raddr <= 4'b0;
        vid_sram_raddr <= 5'b0;
        epoch_buff <= 8'd0;
        select_vid <= 4'd0;
    end else begin
        enable <= enable_in;
        state <= nstate; 
        epoch <= n_epoch;
        next_sram_raddr <= n_epoch;
        if((~enable) || epoch < PSUM_READY) begin 
            vid_sram_raddr <= 5'd16 & {5{pingpong}};
        end else begin 
            if(vid_sram_raddr != 5'd15 && vid_sram_raddr != 5'd31)
                vid_sram_raddr <= vid_sram_raddr + 1;
            else 
                vid_sram_raddr <= (epoch == 8'd255 ? vid_sram_raddr : (pingpong == 1 ? 5'd16 : 5'd0));
        end 
        // if((~enable) || epoch < PSUM_READY + 1) begin 
        //     select_vid <= 8'd0;
        // end else begin 
        //     select_vid <= select_vid == 8'd255 ? 8'd255 : select_vid + 1;
        // end 
        if(~enable) 
            select_vid <= 4'd0;
        else if(epoch[3:0] == 4'd3 && (epoch[7] || epoch[6] || epoch[5] || epoch[4])) begin 
            select_vid <= select_vid + 1;
        end 

        if(~enable) 
            epoch_buff <= 8'd0;
        else 
            epoch_buff <= epoch;
        // $write("epoch: %d\n",epoch);
        delay <= n_delay;
        psum_set <= n_psum_set;
        if(~enable) finish <= 0;
        else begin 
            if(state == FINISH) finish <= 1;
            else                finish <= 0;
        end 
        {next_arr[0],next_arr[1],next_arr[2],next_arr[3],next_arr[4],next_arr[5],next_arr[6],next_arr[7],
        next_arr[8],next_arr[9],next_arr[10],next_arr[11],next_arr[12],next_arr[13],next_arr[14],next_arr[15]}
            <= in_next_arr;
        // $write("epoch %d: %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h, \n", 
        // epoch, buffer_15[0],buffer_15[1],buffer_15[2],buffer_15[3],buffer_15[4],buffer_15[5],buffer_15[6],buffer_15[7],buffer_15[8],buffer_15[9],buffer_15[10],buffer_15[11],buffer_15[12],buffer_15[13],buffer_15[14],buffer_15[15]);  
        // $write("epoch %d: %h\n", epoch, in_v_gidx);
        // $write("epoch %d; %h\n",  epoch, in_proposal_nums);
        // $write("epoch %d; raddr %d selectvid %d in_vid: %h \n", epoch, vid_sram_raddr, select_vid, in_v_gidx);// vid_sram_rdata0);
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
       
        for(sk = 0; sk < K; sk = sk + 1) begin 
            if(~enable) begin
                accum[sk] <= {BUF_BW{1'b0}};
                export[sk] <= 1'b0;
                buffaccum[sk] <= {4{1'b0}};
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
        for(bfidxw = 0; bfidxw < 2 * Q - 1; bfidxw = bfidxw + 1) begin 
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
            if(~enable) begin 
                vidsram_waddr[export_i] <= 5'd16 & {5{~pingpong}};  
                vidsram_wen[export_i]  <= 1'b1;
            end else if(state >= RUNS && state < FINISH) begin 
                if(vidsram_wen[export_i] == 1'b0)  
                    vidsram_waddr[export_i]  <= vidsram_waddr[export_i] + 1;
                if(export[export_i] == 1) begin 
                    vidsram_wen[export_i]  <= 1'b0;
                end else begin 
                    vidsram_wen[export_i]  <= 1'b1;
                end 
            end else begin 
                vidsram_wen[export_i]  <= 1'b1;
                vidsram_waddr[export_i] <= 5'd16 & {5{~pingpong}};//{5{1'd0}}; // to change ping pong 
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
        if(~enable) begin 
            locsram_wen <= 1'b1;
        end else if(psum_set && state < FINISH) begin 
            // next_arr -> next_real_arr -> buff_next "write out" 
            locsram_wen <= 1'b0;
            for(loci = 0; loci < Q; loci = loci + 1) begin 
                locsram_wbytemask[loci] <= n_locsram_wbytemask[loci];
                locsram_addr[loci] <= v_gidx[loci][VID_BW-1:8];  //15:8 16 bit - 8
            end
        end else begin 
            locsram_wen <= 1'b1;
        end 

    end 
end 


endmodule
// TODO : set valid bit to zero in last batch of worker before master start 