`timescale 1ns/100ps
module test_master;
localparam N = 4096;
localparam K = 16;
localparam NEXT_BW = 4;
localparam PRO_BW = 8;
localparam VID_BW = 16;
localparam Q = 16; 
localparam MAX_EPOCH = 256; // 4096 / 16
localparam VID_ADDR_SPACE = 5;
localparam D = 256;
localparam LOC_ADDR_SPACE = 8;
localparam LOC_BW = 5;
real CYCLE = 10;
integer fptr;
//====== module I/O =====
reg clk;
reg rst_n;
reg enable;

// input, assign from gold 
reg [NEXT_BW*Q-1:0] in_next_arr;
reg [PRO_BW*K-1:0] in_mi_j; 
reg [PRO_BW*K-1:0] in_mj_i; 
reg [VID_BW*Q-1:0] in_v_gidx; 
reg [PRO_BW*Q-1:0] in_proposal_nums;

// output 
wire master_finish;
wire [7:0] epoch;
wire [K-1:0] vidsram_wen; // 0 at MSB  
wire ready; // TODO: if ready == 1 , check at negedge clk     
// =================== instance sram ================================
// graph.py to gen
wire [VID_BW*Q-1:0] vid_sram_wdata0,vid_sram_wdata1,vid_sram_wdata2,vid_sram_wdata3,vid_sram_wdata4,vid_sram_wdata5,vid_sram_wdata6,vid_sram_wdata7,vid_sram_wdata8,vid_sram_wdata9,vid_sram_wdata10,vid_sram_wdata11,vid_sram_wdata12,vid_sram_wdata13,vid_sram_wdata14,vid_sram_wdata15;
wire [VID_ADDR_SPACE-1:0] vid_sram_raddr, vid_sram_waddr0,vid_sram_waddr1,vid_sram_waddr2,vid_sram_waddr3,vid_sram_waddr4,vid_sram_waddr5,vid_sram_waddr6,vid_sram_waddr7,vid_sram_waddr8,vid_sram_waddr9,vid_sram_waddr10,vid_sram_waddr11,vid_sram_waddr12,vid_sram_waddr13,vid_sram_waddr14,vid_sram_waddr15;
wire [VID_BW*Q-1:0] vid_sram_rdata0,vid_sram_rdata1,vid_sram_rdata2,vid_sram_rdata3,vid_sram_rdata4,vid_sram_rdata5,vid_sram_rdata6,vid_sram_rdata7,vid_sram_rdata8,vid_sram_rdata9,vid_sram_rdata10,vid_sram_rdata11,vid_sram_rdata12,vid_sram_rdata13,vid_sram_rdata14,vid_sram_rdata15;
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w0_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[0]), .wdata(vid_sram_wdata0), .waddr(vid_sram_waddr0), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata0));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w1_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[1]), .wdata(vid_sram_wdata1), .waddr(vid_sram_waddr1), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata1));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w2_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[2]), .wdata(vid_sram_wdata2), .waddr(vid_sram_waddr2), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata2));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w3_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[3]), .wdata(vid_sram_wdata3), .waddr(vid_sram_waddr3), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata3));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w4_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[4]), .wdata(vid_sram_wdata4), .waddr(vid_sram_waddr4), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata4));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w5_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[5]), .wdata(vid_sram_wdata5), .waddr(vid_sram_waddr5), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata5));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w6_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[6]), .wdata(vid_sram_wdata6), .waddr(vid_sram_waddr6), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata6));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w7_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[7]), .wdata(vid_sram_wdata7), .waddr(vid_sram_waddr7), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata7));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w8_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[8]), .wdata(vid_sram_wdata8), .waddr(vid_sram_waddr8), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata8));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w9_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[9]), .wdata(vid_sram_wdata9), .waddr(vid_sram_waddr9), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata9));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w10_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[10]), .wdata(vid_sram_wdata10), .waddr(vid_sram_waddr10), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata10));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w11_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[11]), .wdata(vid_sram_wdata11), .waddr(vid_sram_waddr11), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata11));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w12_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[12]), .wdata(vid_sram_wdata12), .waddr(vid_sram_waddr12), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata12));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w13_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[13]), .wdata(vid_sram_wdata13), .waddr(vid_sram_waddr13), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata13));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w14_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[14]), .wdata(vid_sram_wdata14), .waddr(vid_sram_waddr14), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata14));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w15_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[15]), .wdata(vid_sram_wdata15), .waddr(vid_sram_waddr15), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata15));
// --------- loc sram ------
wire [LOC_BW*D-1:0] loc_sram_wdata0,loc_sram_wdata1,loc_sram_wdata2,loc_sram_wdata3,loc_sram_wdata4,loc_sram_wdata5,loc_sram_wdata6,loc_sram_wdata7,loc_sram_wdata8,loc_sram_wdata9,loc_sram_wdata10,loc_sram_wdata11,loc_sram_wdata12,loc_sram_wdata13,loc_sram_wdata14,loc_sram_wdata15;
wire locsram_wen;
wire [D-1:0] locsram_wbytemask0,locsram_wbytemask1,locsram_wbytemask2,locsram_wbytemask3,locsram_wbytemask4,locsram_wbytemask5,locsram_wbytemask6,locsram_wbytemask7,locsram_wbytemask8,locsram_wbytemask9,locsram_wbytemask10,locsram_wbytemask11,locsram_wbytemask12,locsram_wbytemask13,locsram_wbytemask14,locsram_wbytemask15;
wire [LOC_ADDR_SPACE-1:0] loc_sram_waddr0,loc_sram_waddr1,loc_sram_waddr2,loc_sram_waddr3,loc_sram_waddr4,loc_sram_waddr5,loc_sram_waddr6,loc_sram_waddr7,loc_sram_waddr8,loc_sram_waddr9,loc_sram_waddr10,loc_sram_waddr11,loc_sram_waddr12,loc_sram_waddr13,loc_sram_waddr14,loc_sram_waddr15;
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w0_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask0), .wdata(loc_sram_wdata0), .waddr(loc_sram_waddr0), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w1_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask1), .wdata(loc_sram_wdata1), .waddr(loc_sram_waddr1), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w2_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask2), .wdata(loc_sram_wdata2), .waddr(loc_sram_waddr2), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w3_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask3), .wdata(loc_sram_wdata3), .waddr(loc_sram_waddr3), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w4_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask4), .wdata(loc_sram_wdata4), .waddr(loc_sram_waddr4), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w5_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask5), .wdata(loc_sram_wdata5), .waddr(loc_sram_waddr5), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w6_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask6), .wdata(loc_sram_wdata6), .waddr(loc_sram_waddr6), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w7_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask7), .wdata(loc_sram_wdata7), .waddr(loc_sram_waddr7), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w8_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask8), .wdata(loc_sram_wdata8), .waddr(loc_sram_waddr8), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w9_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask9), .wdata(loc_sram_wdata9), .waddr(loc_sram_waddr9), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w10_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask10), .wdata(loc_sram_wdata10), .waddr(loc_sram_waddr10), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w11_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask11), .wdata(loc_sram_wdata11), .waddr(loc_sram_waddr11), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w12_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask12), .wdata(loc_sram_wdata12), .waddr(loc_sram_waddr12), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w13_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask13), .wdata(loc_sram_wdata13), .waddr(loc_sram_waddr13), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w14_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask14), .wdata(loc_sram_wdata14), .waddr(loc_sram_waddr14), .raddr(), .rdata());
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w15_loc_sram_16x256b(.clk(clk), .wsb(locsram_wen), .bytemask(locsram_wbytemask15), .wdata(loc_sram_wdata15), .waddr(loc_sram_waddr15), .raddr(), .rdata());
// ===================================================================================
// master_top #(
//  // 
// )
wire pingpong = 0;
master_top master_instn (
    .clk(clk),
    .enable_in(enable),
    .rst_n_in(rst_n),
    .in_next_arr(in_next_arr),
    .in_mi_j(in_mi_j),
    .in_mj_i(in_mj_i),
    .in_v_gidx(in_v_gidx),
    .in_proposal_nums(in_proposal_nums),
    .pingpong(pingpong),
    // output 
    .epoch(epoch),
    .vidsram_wen(vidsram_wen),
    .locsram_wen(locsram_wen), 
    .ready(ready),
    .finish(master_finish),
    .vid_sram_wdata0(vid_sram_wdata0),     .vid_sram_waddr0(vid_sram_waddr0),
    .vid_sram_wdata1(vid_sram_wdata1),     .vid_sram_waddr1(vid_sram_waddr1),
    .vid_sram_wdata2(vid_sram_wdata2),     .vid_sram_waddr2(vid_sram_waddr2),
    .vid_sram_wdata3(vid_sram_wdata3),     .vid_sram_waddr3(vid_sram_waddr3),
    .vid_sram_wdata4(vid_sram_wdata4),     .vid_sram_waddr4(vid_sram_waddr4),
    .vid_sram_wdata5(vid_sram_wdata5),     .vid_sram_waddr5(vid_sram_waddr5),
    .vid_sram_wdata6(vid_sram_wdata6),     .vid_sram_waddr6(vid_sram_waddr6),
    .vid_sram_wdata7(vid_sram_wdata7),     .vid_sram_waddr7(vid_sram_waddr7),
    .vid_sram_wdata8(vid_sram_wdata8),     .vid_sram_waddr8(vid_sram_waddr8),
    .vid_sram_wdata9(vid_sram_wdata9),     .vid_sram_waddr9(vid_sram_waddr9),
    .vid_sram_wdata10(vid_sram_wdata10),   .vid_sram_waddr10(vid_sram_waddr10),    
    .vid_sram_wdata11(vid_sram_wdata11),   .vid_sram_waddr11(vid_sram_waddr11),    
    .vid_sram_wdata12(vid_sram_wdata12),   .vid_sram_waddr12(vid_sram_waddr12),    
    .vid_sram_wdata13(vid_sram_wdata13),   .vid_sram_waddr13(vid_sram_waddr13),    
    .vid_sram_wdata14(vid_sram_wdata14),   .vid_sram_waddr14(vid_sram_waddr14),    
    .vid_sram_wdata15(vid_sram_wdata15),   .vid_sram_waddr15(vid_sram_waddr15),
    .loc_sram_wdata0(loc_sram_wdata0)   ,  .loc_sram_waddr0(loc_sram_waddr0)    , .locsram_wbytemask0(locsram_wbytemask0),
    .loc_sram_wdata1(loc_sram_wdata1)   ,  .loc_sram_waddr1(loc_sram_waddr1)    , .locsram_wbytemask1(locsram_wbytemask1),
    .loc_sram_wdata2(loc_sram_wdata2)   ,  .loc_sram_waddr2(loc_sram_waddr2)    , .locsram_wbytemask2(locsram_wbytemask2),
    .loc_sram_wdata3(loc_sram_wdata3)   ,  .loc_sram_waddr3(loc_sram_waddr3)    , .locsram_wbytemask3(locsram_wbytemask3),
    .loc_sram_wdata4(loc_sram_wdata4)   ,  .loc_sram_waddr4(loc_sram_waddr4)    , .locsram_wbytemask4(locsram_wbytemask4),
    .loc_sram_wdata5(loc_sram_wdata5)   ,  .loc_sram_waddr5(loc_sram_waddr5)    , .locsram_wbytemask5(locsram_wbytemask5),
    .loc_sram_wdata6(loc_sram_wdata6)   ,  .loc_sram_waddr6(loc_sram_waddr6)    , .locsram_wbytemask6(locsram_wbytemask6),
    .loc_sram_wdata7(loc_sram_wdata7)   ,  .loc_sram_waddr7(loc_sram_waddr7)    , .locsram_wbytemask7(locsram_wbytemask7),
    .loc_sram_wdata8(loc_sram_wdata8)   ,  .loc_sram_waddr8(loc_sram_waddr8)    , .locsram_wbytemask8(locsram_wbytemask8),
    .loc_sram_wdata9(loc_sram_wdata9)   ,  .loc_sram_waddr9(loc_sram_waddr9)    , .locsram_wbytemask9(locsram_wbytemask9),
    .loc_sram_wdata10(loc_sram_wdata10) ,  .loc_sram_waddr10(loc_sram_waddr10)  , .locsram_wbytemask10(locsram_wbytemask10),
    .loc_sram_wdata11(loc_sram_wdata11) ,  .loc_sram_waddr11(loc_sram_waddr11)  , .locsram_wbytemask11(locsram_wbytemask11),
    .loc_sram_wdata12(loc_sram_wdata12) ,  .loc_sram_waddr12(loc_sram_waddr12)  , .locsram_wbytemask12(locsram_wbytemask12),
    .loc_sram_wdata13(loc_sram_wdata13) ,  .loc_sram_waddr13(loc_sram_waddr13)  , .locsram_wbytemask13(locsram_wbytemask13),
    .loc_sram_wdata14(loc_sram_wdata14) ,  .loc_sram_waddr14(loc_sram_waddr14)  , .locsram_wbytemask14(locsram_wbytemask14),
    .loc_sram_wdata15(loc_sram_wdata15) ,  .loc_sram_waddr15(loc_sram_waddr15)  , .locsram_wbytemask15(locsram_wbytemask15)
);
reg [NEXT_BW*Q-1:0] file_next_arr[0:MAX_EPOCH-1];
reg [PRO_BW*K-1:0] file_mi_j[0:MAX_EPOCH-1]; 
reg [PRO_BW*K-1:0] file_mj_i[0:MAX_EPOCH-1]; 
reg [VID_BW*Q-1:0] file_v_gidx[0:MAX_EPOCH-1]; 
reg [PRO_BW*Q-1:0] file_proposal_nums[0:MAX_EPOCH-1];
reg [VID_BW*Q-1:0] w0_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w1_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w2_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w3_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w4_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w5_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w6_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w7_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w8_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w9_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w10_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w11_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w12_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w13_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w14_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w15_vid_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w0_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w1_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w2_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w3_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w4_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w5_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w6_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w7_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w8_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w9_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w10_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w11_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w12_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w13_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w14_loc_sram_gold[0:16-1];
reg [LOC_BW*D-1:0] w15_loc_sram_gold[0:16-1];
  
reg [8:0] gold_epoch;
reg [K-1:0] gold_wen;
reg [Q * VID_BW - 1:0] gold_wdata; 
reg [4 - 1:0] gold_waddr;
reg [7:0] chars[0:2];
always #(CYCLE/2) clk = ~clk;
integer ccc;
reg [8:0] check_epoch;
integer feed, feed_v;
reg [4:0] srami;
reg [8:0] locsrami;
reg rerun;
initial begin 
    clk = 0;
    rst_n = 1;
    enable = 1'b0;
    rerun = 1'b0;
    $readmemh("../software/gold_master/vid_sram_w0.dat", w0_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w1.dat", w1_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w2.dat", w2_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w3.dat", w3_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w4.dat", w4_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w5.dat", w5_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w6.dat", w6_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w7.dat", w7_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w8.dat", w8_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w9.dat", w9_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w10.dat", w10_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w11.dat", w11_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w12.dat", w12_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w13.dat", w13_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w14.dat", w14_vid_sram_gold);
    $readmemh("../software/gold_master/vid_sram_w15.dat", w15_vid_sram_gold);
    // -------------
    $readmemb("../software/gold_master/locsram_w0.dat",  w0_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w1.dat",  w1_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w2.dat",  w2_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w3.dat",  w3_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w4.dat",  w4_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w5.dat",  w5_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w6.dat",  w6_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w7.dat",  w7_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w8.dat",  w8_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w9.dat",  w9_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w10.dat",  w10_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w11.dat",  w11_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w12.dat",  w12_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w13.dat",  w13_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w14.dat",  w14_loc_sram_gold);
    $readmemb("../software/gold_master/locsram_w15.dat",  w15_loc_sram_gold);
    $write("w0 loc sram gold %h %d\n", w15_loc_sram_gold[15], w15_loc_sram_gold[15][5*256-1]);
    $readmemh("../software/gold_master/next_arr.dat", file_next_arr);
    $write("file_next_arr 0: %h\n", file_next_arr[0]);
    $write("file_next_arr 1: %h\n", file_next_arr[1]);
    $readmemh("../software/gold_master/v_gidx.dat", file_v_gidx);
    $write("file_v_gidx 0: %h\n", file_v_gidx[0]);
    $write("file_v_gidx 1: %h\n", file_v_gidx[1]);
    $readmemh("../software/gold_master/mi_j.dat", file_mi_j);
    $write("file_mi_j 0: %h\n", file_mi_j[0]);
    $write("file_mi_j 1: %h\n", file_mi_j[1]);
    $readmemh("../software/gold_master/mj_i.dat", file_mj_i);
    $write("file_mj_i 0: %h\n", file_mj_i[0]);
    $write("file_mj_i 1: %h\n", file_mj_i[1]);
    $readmemh("../software/gold_master/proposal_nums.dat", file_proposal_nums);
    $write("file_proposal_nums 0: %h\n", file_proposal_nums[0]);
    $write("file_proposal_nums 1: %h\n", file_proposal_nums[1]);
    $write("=========== locsram =============\n");
    for(locsrami = 0; locsrami < 16; locsrami = locsrami + 1) begin 
        w0_loc_sram_16x256b.load_param(locsrami, 0);
        w1_loc_sram_16x256b.load_param(locsrami, 0);
        w2_loc_sram_16x256b.load_param(locsrami, 0);
        w3_loc_sram_16x256b.load_param(locsrami, 0);
        w4_loc_sram_16x256b.load_param(locsrami, 0);
        w5_loc_sram_16x256b.load_param(locsrami, 0);
        w6_loc_sram_16x256b.load_param(locsrami, 0);
        w7_loc_sram_16x256b.load_param(locsrami, 0);
        w8_loc_sram_16x256b.load_param(locsrami, 0);
        w9_loc_sram_16x256b.load_param(locsrami, 0);
        w10_loc_sram_16x256b.load_param(locsrami, 0);
        w11_loc_sram_16x256b.load_param(locsrami, 0);
        w12_loc_sram_16x256b.load_param(locsrami, 0);
        w13_loc_sram_16x256b.load_param(locsrami, 0);
        w14_loc_sram_16x256b.load_param(locsrami, 0);
        w15_loc_sram_16x256b.load_param(locsrami, 0);
    end 
    #(CYCLE) rst_n = 0; 
    // input test pattern, epoch should = 0 
    in_next_arr = file_next_arr[epoch];
    in_mi_j = file_mi_j[epoch];
    in_mj_i = file_mj_i[epoch];
    in_v_gidx = file_v_gidx[epoch];
    in_proposal_nums = file_proposal_nums[epoch];
    #(CYCLE) rst_n = 1;   enable = 1'b1;
    #(CYCLE)
    while(epoch < MAX_EPOCH - 1) begin 
        @(negedge clk)
        in_next_arr = file_next_arr[epoch-1 >= 0 ? epoch - 1: 0];
        in_mi_j = file_mi_j[epoch-1 >= 0 ? epoch - 1: 0];
        in_mj_i = file_mj_i[epoch-1 >= 0 ? epoch - 1: 0];
        in_v_gidx = file_v_gidx[epoch-4 >= 0 ? epoch - 4: 0];
        in_proposal_nums = file_proposal_nums[epoch-1 >= 0 ? epoch - 1: 0];
    end 
    feed = 255;
    feed_v = 252;
    while(feed_v < 256) begin
        @(negedge clk)
        // $write("input epoch %d feed %d", epoch, feed);
        in_next_arr = file_next_arr[feed];
        in_mi_j = file_mi_j[feed];
        in_mj_i = file_mj_i[feed];
        in_v_gidx = file_v_gidx[feed_v];
        in_proposal_nums = file_proposal_nums[feed];
        // $write("; vgid in %h;\n",in_v_gidx );
        feed_v = feed_v + 1;
        if(feed == 255) feed = 255;
        else feed = feed + 1;
    end 
    wait(master_finish == 1);
    enable = 1'b0;
    $write("DONNEE\n");
    for(srami = 0; srami < 16; srami = srami + 1) begin 
        if(w0_vid_sram_gold[srami] !== w0_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 0 at %d \n", srami); $finish; end 
        // else $write("0_%02d,", srami);
        if(w1_vid_sram_gold[srami] !== w1_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 1 at %d \n", srami); $finish; end 
        // else $write("1_%02d,", srami);
        if(w2_vid_sram_gold[srami] !== w2_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 2 at %d \n", srami); $finish; end 
        // else $write("2_%02d,", srami);
        if(w3_vid_sram_gold[srami] !== w3_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 3 at %d \n", srami); $finish; end 
        // else $write("3_%02d,", srami);
        if(w4_vid_sram_gold[srami] !== w4_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 4 at %d \n", srami); $finish; end 
        // else $write("4_%02d,", srami);
        if(w5_vid_sram_gold[srami] !== w5_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 5 at %d \n", srami); $finish; end 
        // else $write("5_%02d,", srami);
        if(w6_vid_sram_gold[srami] !== w6_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 6 at %d \n", srami); $finish; end 
        // else $write("6_%02d,", srami);
        if(w7_vid_sram_gold[srami] !== w7_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 7 at %d \n", srami); $finish; end 
        // else $write("7_%02d,", srami);
        if(w8_vid_sram_gold[srami] !== w8_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 8 at %d \n", srami); $finish; end 
        // else $write("8_%02d,", srami);
        if(w9_vid_sram_gold[srami] !== w9_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 9 at %d \n", srami); $finish; end 
        // else $write("9_%02d,", srami);
        if(w10_vid_sram_gold[srami] !== w10_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 10  at %d\n", srami); $finish; end 
        // else $write("10_%02d,", srami);
        if(w11_vid_sram_gold[srami] !== w11_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 11  at %d\n", srami); $finish; end 
        // else $write("11_%02d,", srami);
        if(w12_vid_sram_gold[srami] !== w12_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 12  at %d\n", srami); $finish; end 
        // else $write("12_%02d,", srami);
        if(w13_vid_sram_gold[srami] !== w13_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 13  at %d\n", srami); $finish; end 
        // else $write("13_%02d,", srami);
        if(w14_vid_sram_gold[srami] !== w14_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 14  at %d\n", srami); $finish; end 
        // else $write("14_%02d,", srami);
        if(w15_vid_sram_gold[srami] !== w15_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 15  at %d\n", srami); $finish; end 
        // else $write("15_%02d,", srami);
        // $write("\n");
    end 
    $write("=========== locsram =============\n");
    for(locsrami = 0; locsrami < 16; locsrami = locsrami + 1) begin 
        if(w0_loc_sram_16x256b.mem[locsrami] !== w0_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w1_loc_sram_16x256b.mem[locsrami] !== w1_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w2_loc_sram_16x256b.mem[locsrami] !== w2_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w3_loc_sram_16x256b.mem[locsrami] !== w3_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w4_loc_sram_16x256b.mem[locsrami] !== w4_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w5_loc_sram_16x256b.mem[locsrami] !== w5_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w6_loc_sram_16x256b.mem[locsrami] !== w6_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w7_loc_sram_16x256b.mem[locsrami] !== w7_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w8_loc_sram_16x256b.mem[locsrami] !== w8_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w9_loc_sram_16x256b.mem[locsrami] !== w9_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w10_loc_sram_16x256b.mem[locsrami] !== w10_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w11_loc_sram_16x256b.mem[locsrami] !== w11_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w12_loc_sram_16x256b.mem[locsrami] !== w12_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w13_loc_sram_16x256b.mem[locsrami] !== w13_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w14_loc_sram_16x256b.mem[locsrami] !== w14_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
        if(w15_loc_sram_16x256b.mem[locsrami] !== w15_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end //else $write("good locsrma0 %h vs gold %h\n",w15_loc_sram_16x256b.mem[locsrami] , w15_loc_sram_gold[locsrami]);
    end  
    $write("\n");
    rerun = 1'b1;
    $write("--------------------rerun to check---\n");
    #(CYCLE*3) enable = 1'b1;
    #(CYCLE*2) $write("re: epoch %d\n", epoch);
    while(epoch < MAX_EPOCH - 1) begin 
        @(negedge clk)
        in_next_arr = file_next_arr[epoch-1 >= 0 ? epoch - 1: 0];
        in_mi_j = file_mi_j[epoch-1 >= 0 ? epoch - 1: 0];
        in_mj_i = file_mj_i[epoch-1 >= 0 ? epoch - 1: 0];
        in_v_gidx = file_v_gidx[epoch-4 >= 0 ? epoch - 4: 0];
        in_proposal_nums = file_proposal_nums[epoch-1 >= 0 ? epoch - 1: 0];
    end 
    feed = 255;
    feed_v = 252;
    while(feed_v < 256) begin
        @(negedge clk)
        // $write("input epoch %d feed %d", epoch, feed);
        in_next_arr = file_next_arr[feed];
        in_mi_j = file_mi_j[feed];
        in_mj_i = file_mj_i[feed];
        in_v_gidx = file_v_gidx[feed_v];
        in_proposal_nums = file_proposal_nums[feed];
        // $write("; vgid in %h;\n",in_v_gidx );
        feed_v = feed_v + 1;
        if(feed == 255) feed = 255;
        else feed = feed + 1;
    end 
    wait(master_finish == 1);
    enable = 1'b0;
    $write("DONNEE\n");
    for(srami = 0; srami < 16; srami = srami + 1) begin 
        if(w0_vid_sram_gold[srami] !== w0_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 0 at %d \n", srami); $finish; end 
        // else $write("0_%02d,", srami);
        if(w1_vid_sram_gold[srami] !== w1_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 1 at %d \n", srami); $finish; end 
        // else $write("1_%02d,", srami);
        if(w2_vid_sram_gold[srami] !== w2_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 2 at %d \n", srami); $finish; end 
        // else $write("2_%02d,", srami);
        if(w3_vid_sram_gold[srami] !== w3_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 3 at %d \n", srami); $finish; end 
        // else $write("3_%02d,", srami);
        if(w4_vid_sram_gold[srami] !== w4_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 4 at %d \n", srami); $finish; end 
        // else $write("4_%02d,", srami);
        if(w5_vid_sram_gold[srami] !== w5_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 5 at %d \n", srami); $finish; end 
        // else $write("5_%02d,", srami);
        if(w6_vid_sram_gold[srami] !== w6_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 6 at %d \n", srami); $finish; end 
        // else $write("6_%02d,", srami);
        if(w7_vid_sram_gold[srami] !== w7_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 7 at %d \n", srami); $finish; end 
        // else $write("7_%02d,", srami);
        if(w8_vid_sram_gold[srami] !== w8_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 8 at %d \n", srami); $finish; end 
        // else $write("8_%02d,", srami);
        if(w9_vid_sram_gold[srami] !== w9_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 9 at %d \n", srami); $finish; end 
        // else $write("9_%02d,", srami);
        if(w10_vid_sram_gold[srami] !== w10_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 10  at %d\n", srami); $finish; end 
        // else $write("10_%02d,", srami);
        if(w11_vid_sram_gold[srami] !== w11_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 11  at %d\n", srami); $finish; end 
        // else $write("11_%02d,", srami);
        if(w12_vid_sram_gold[srami] !== w12_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 12  at %d\n", srami); $finish; end 
        // else $write("12_%02d,", srami);
        if(w13_vid_sram_gold[srami] !== w13_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 13  at %d\n", srami); $finish; end 
        // else $write("13_%02d,", srami);
        if(w14_vid_sram_gold[srami] !== w14_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 14  at %d\n", srami); $finish; end 
        // else $write("14_%02d,", srami);
        if(w15_vid_sram_gold[srami] !== w15_vid_sram_16x256b.mem[srami]) begin  $write("FAIL vidsram 15  at %d\n", srami); $finish; end 
        // else $write("15_%02d,", srami);
        // $write("\n");
    end 

    
    $write("========================\nall pass ~\n========================\n");
    $finish;
end 

reg [K-1:0] checkbit;
integer checki;
reg [NEXT_BW-1:0] banknum; 
// initial begin 
//     fptr = $fopen("../software/gold_master/wdata.dat", "r");
//     check_epoch = 0;
//     wait(rerun == 1);
//     #(CYCLE);
//     wait(ready == 1);
//     while(check_epoch < MAX_EPOCH + 1) begin 
//         @(negedge clk)
//         ccc = $fscanf(fptr, "%h %h", gold_epoch, gold_wen);
//         // $display("tbepoch: %d %h; %d", gold_epoch, gold_wen, check_epoch);
//         if(check_epoch == gold_epoch) begin 
//             if(gold_wen !== ~(vidsram_wen)) begin 
//                 $display("FAILL epoch %d tbepoch: %h goldwen %h; check %h", epoch, gold_epoch, gold_wen, check_epoch);
//                 $write("gold_wen %h vs vidsram_wen %h\n", gold_wen, vidsram_wen);
//                 $finish;
//             end 
//             // else begin 
//                 if(gold_wen > 0) begin 
//                     checkbit = 16'h8000;
//                     for(checki = 0; checki < K; checki = checki + 1) begin 
//                         if((checkbit & gold_wen) > 0) begin 
//                             ccc = $fscanf(fptr, "%h", banknum); 
//                             // $write("banknum: %d\t\t", banknum);
//                             ccc = $fscanf(fptr, "%h", gold_wdata);
//                             // $write("wdata: %h\n", gold_wdata);
//                             if(master_instn.vidsram_wdata[banknum] !== gold_wdata) begin
//                                 $write("FAIL check: %h vs %h (gold)", master_instn.vidsram_wdata[banknum], gold_wdata); 
//                                 $finish;
//                             end 
//                             // else begin 
//                             //     $write("good check: %h vs %h (gold)\n", master_instn.vidsram_wdata[banknum], gold_wdata); 
//                             // end 
//                         end 
//                         checkbit = checkbit >>1;
//                     end
//                     // $write("-------\n"); 
//                 end 
//             // end 
//         end
//         else begin 
//             $display("fscanf fail to sync!");
//             $finish;
//         end 
//         check_epoch = check_epoch + 1;
//     end
//     if(check_epoch != MAX_EPOCH + 1) begin 
//         $write("FAILLL only check to %d\n", check_epoch);
//     end else begin 
//         $write("HOORAY\n");
//     end 
//     // $finish; 
// end 
initial begin 
    #(CYCLE*1000000);
    $finish;
end 
initial begin 
    // wait(epoch == 100000);
    // $finish;
end 
initial begin
	$fsdbDumpfile("test_master.fsdb");
    $sdf_annotate("../syn_master/netlist/master_top_syn.sdf", master_instn);
	$fsdbDumpvars("+mda");
end
endmodule

