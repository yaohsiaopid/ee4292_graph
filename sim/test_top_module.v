// `timescale 1ns/100ps
module test_top;
localparam N = 4096;
localparam K = 16;
localparam D = 256;
localparam DIST_BW = 1;
localparam DIST_ADDR_SPACE = 16;
localparam LOC_BW = 5;
localparam LOC_ADDR_SPACE = 4;
localparam NEXT_BW = 4;
localparam NEXT_ADDR_SPACE = 4;
localparam PRO_BW = 8;
localparam PRO_ADDR_SPACE = 4;
localparam VID_BW = 16;
localparam VID_ADDR_SPACE = 5;
localparam Q = 16;
real CYCLE = 10;
// Table of Content
// # module I/O
// # sram connection
//  ---- vid_sram_instn ---
//  ---- 
// # module instance 
// # GOLD 
// # 

//====== module I/O =====
reg clk;
reg rst_n;
reg enable;
wire part_finish;


wire [NEXT_ADDR_SPACE-1:0] next_sram_raddr;
wire [PRO_ADDR_SPACE-1:0] pronum_sram_raddr;
assign pronum_sram_raddr = next_sram_raddr;
wire [PRO_BW*Q-1:0] proposal_sram_rdata0, proposal_sram_rdata8;
wire [PRO_BW*Q-1:0] proposal_sram_rdata1, proposal_sram_rdata9;
wire [PRO_BW*Q-1:0] proposal_sram_rdata2, proposal_sram_rdata10;
wire [PRO_BW*Q-1:0] proposal_sram_rdata3, proposal_sram_rdata11;
wire [PRO_BW*Q-1:0] proposal_sram_rdata4, proposal_sram_rdata12;
wire [PRO_BW*Q-1:0] proposal_sram_rdata5, proposal_sram_rdata13;
wire [PRO_BW*Q-1:0] proposal_sram_rdata6, proposal_sram_rdata14;
wire [PRO_BW*Q-1:0] proposal_sram_rdata7, proposal_sram_rdata15;

// output 
wire master_finish;
wire [7:0] epoch;
wire [K-1:0] vidsram_wen;    
//====== sram connection =====
// -------- vid_sram_instn -------------
wire [VID_ADDR_SPACE-1:0] vid_sram_raddr0 ,vid_sram_raddr1 ,vid_sram_raddr2 ,vid_sram_raddr3 ,vid_sram_raddr4 ,vid_sram_raddr5 ,vid_sram_raddr6 ,vid_sram_raddr7 ,vid_sram_raddr8 ,vid_sram_raddr9 ,vid_sram_raddr10 ,vid_sram_raddr11 ,vid_sram_raddr12 ,vid_sram_raddr13 ,vid_sram_raddr14 ,vid_sram_raddr15;
wire [VID_BW*Q-1:0] vid_sram_wdata0,vid_sram_wdata1,vid_sram_wdata2,vid_sram_wdata3,vid_sram_wdata4,vid_sram_wdata5,vid_sram_wdata6,vid_sram_wdata7,vid_sram_wdata8,vid_sram_wdata9,vid_sram_wdata10,vid_sram_wdata11,vid_sram_wdata12,vid_sram_wdata13,vid_sram_wdata14,vid_sram_wdata15;
wire [VID_ADDR_SPACE-1:0] vid_sram_waddr0,vid_sram_waddr1,vid_sram_waddr2,vid_sram_waddr3,vid_sram_waddr4,vid_sram_waddr5,vid_sram_waddr6,vid_sram_waddr7,vid_sram_waddr8,vid_sram_waddr9,vid_sram_waddr10,vid_sram_waddr11,vid_sram_waddr12,vid_sram_waddr13,vid_sram_waddr14,vid_sram_waddr15;
wire [VID_BW*Q-1:0] vid_sram_rdata0,vid_sram_rdata1,vid_sram_rdata2,vid_sram_rdata3,vid_sram_rdata4,vid_sram_rdata5,vid_sram_rdata6,vid_sram_rdata7,vid_sram_rdata8,vid_sram_rdata9,vid_sram_rdata10,vid_sram_rdata11,vid_sram_rdata12,vid_sram_rdata13,vid_sram_rdata14,vid_sram_rdata15;
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w0_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[0]), .wdata(vid_sram_wdata0), .waddr(vid_sram_waddr0), .raddr(vid_sram_raddr0), .rdata(vid_sram_rdata0));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w1_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[1]), .wdata(vid_sram_wdata1), .waddr(vid_sram_waddr1), .raddr(vid_sram_raddr1), .rdata(vid_sram_rdata1));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w2_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[2]), .wdata(vid_sram_wdata2), .waddr(vid_sram_waddr2), .raddr(vid_sram_raddr2), .rdata(vid_sram_rdata2));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w3_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[3]), .wdata(vid_sram_wdata3), .waddr(vid_sram_waddr3), .raddr(vid_sram_raddr3), .rdata(vid_sram_rdata3));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w4_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[4]), .wdata(vid_sram_wdata4), .waddr(vid_sram_waddr4), .raddr(vid_sram_raddr4), .rdata(vid_sram_rdata4));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w5_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[5]), .wdata(vid_sram_wdata5), .waddr(vid_sram_waddr5), .raddr(vid_sram_raddr5), .rdata(vid_sram_rdata5));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w6_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[6]), .wdata(vid_sram_wdata6), .waddr(vid_sram_waddr6), .raddr(vid_sram_raddr6), .rdata(vid_sram_rdata6));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w7_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[7]), .wdata(vid_sram_wdata7), .waddr(vid_sram_waddr7), .raddr(vid_sram_raddr7), .rdata(vid_sram_rdata7));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w8_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[8]), .wdata(vid_sram_wdata8), .waddr(vid_sram_waddr8), .raddr(vid_sram_raddr8), .rdata(vid_sram_rdata8));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w9_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[9]), .wdata(vid_sram_wdata9), .waddr(vid_sram_waddr9), .raddr(vid_sram_raddr9), .rdata(vid_sram_rdata9));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w10_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[10]), .wdata(vid_sram_wdata10), .waddr(vid_sram_waddr10), .raddr(vid_sram_raddr10), .rdata(vid_sram_rdata10));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w11_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[11]), .wdata(vid_sram_wdata11), .waddr(vid_sram_waddr11), .raddr(vid_sram_raddr11), .rdata(vid_sram_rdata11));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w12_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[12]), .wdata(vid_sram_wdata12), .waddr(vid_sram_waddr12), .raddr(vid_sram_raddr12), .rdata(vid_sram_rdata12));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w13_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[13]), .wdata(vid_sram_wdata13), .waddr(vid_sram_waddr13), .raddr(vid_sram_raddr13), .rdata(vid_sram_rdata13));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w14_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[14]), .wdata(vid_sram_wdata14), .waddr(vid_sram_waddr14), .raddr(vid_sram_raddr14), .rdata(vid_sram_rdata14));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w15_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[15]), .wdata(vid_sram_wdata15), .waddr(vid_sram_waddr15), .raddr(vid_sram_raddr15), .rdata(vid_sram_rdata15));

// --------- loc_sram_instn ------
wire [LOC_BW*D-1:0] loc_sram_wdata0,loc_sram_wdata1,loc_sram_wdata2,loc_sram_wdata3,loc_sram_wdata4,loc_sram_wdata5,loc_sram_wdata6,loc_sram_wdata7,loc_sram_wdata8,loc_sram_wdata9,loc_sram_wdata10,loc_sram_wdata11,loc_sram_wdata12,loc_sram_wdata13,loc_sram_wdata14,loc_sram_wdata15;
wire loc_sram_wen;
wire [LOC_ADDR_SPACE-1:0] loc_sram_raddr0 ,loc_sram_raddr1 ,loc_sram_raddr2 ,loc_sram_raddr3 ,loc_sram_raddr4 ,loc_sram_raddr5 ,loc_sram_raddr6 ,loc_sram_raddr7 ,loc_sram_raddr8 ,loc_sram_raddr9 ,loc_sram_raddr10 ,loc_sram_raddr11 ,loc_sram_raddr12 ,loc_sram_raddr13 ,loc_sram_raddr14 ,loc_sram_raddr15;
wire [LOC_BW*D-1:0] loc_sram_rdata0 ,loc_sram_rdata1 ,loc_sram_rdata2 ,loc_sram_rdata3 ,loc_sram_rdata4 ,loc_sram_rdata5 ,loc_sram_rdata6 ,loc_sram_rdata7 ,loc_sram_rdata8 ,loc_sram_rdata9 ,loc_sram_rdata10 ,loc_sram_rdata11 ,loc_sram_rdata12 ,loc_sram_rdata13 ,loc_sram_rdata14 ,loc_sram_rdata15;
wire [D-1:0] locsram_wbytemask0,locsram_wbytemask1,locsram_wbytemask2,locsram_wbytemask3,locsram_wbytemask4,locsram_wbytemask5,locsram_wbytemask6,locsram_wbytemask7,locsram_wbytemask8,locsram_wbytemask9,locsram_wbytemask10,locsram_wbytemask11,locsram_wbytemask12,locsram_wbytemask13,locsram_wbytemask14,locsram_wbytemask15;
wire [LOC_ADDR_SPACE-1:0] loc_sram_waddr0,loc_sram_waddr1,loc_sram_waddr2,loc_sram_waddr3,loc_sram_waddr4,loc_sram_waddr5,loc_sram_waddr6,loc_sram_waddr7,loc_sram_waddr8,loc_sram_waddr9,loc_sram_waddr10,loc_sram_waddr11,loc_sram_waddr12,loc_sram_waddr13,loc_sram_waddr14,loc_sram_waddr15;
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w0_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask0), .wdata(loc_sram_wdata0), .waddr(loc_sram_waddr0), .raddr(loc_sram_raddr0), .rdata(loc_sram_rdata0));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w1_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask1), .wdata(loc_sram_wdata1), .waddr(loc_sram_waddr1), .raddr(loc_sram_raddr1), .rdata(loc_sram_rdata1));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w2_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask2), .wdata(loc_sram_wdata2), .waddr(loc_sram_waddr2), .raddr(loc_sram_raddr2), .rdata(loc_sram_rdata2));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w3_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask3), .wdata(loc_sram_wdata3), .waddr(loc_sram_waddr3), .raddr(loc_sram_raddr3), .rdata(loc_sram_rdata3));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w4_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask4), .wdata(loc_sram_wdata4), .waddr(loc_sram_waddr4), .raddr(loc_sram_raddr4), .rdata(loc_sram_rdata4));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w5_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask5), .wdata(loc_sram_wdata5), .waddr(loc_sram_waddr5), .raddr(loc_sram_raddr5), .rdata(loc_sram_rdata5));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w6_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask6), .wdata(loc_sram_wdata6), .waddr(loc_sram_waddr6), .raddr(loc_sram_raddr6), .rdata(loc_sram_rdata6));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w7_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask7), .wdata(loc_sram_wdata7), .waddr(loc_sram_waddr7), .raddr(loc_sram_raddr7), .rdata(loc_sram_rdata7));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w8_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask8), .wdata(loc_sram_wdata8), .waddr(loc_sram_waddr8), .raddr(loc_sram_raddr8), .rdata(loc_sram_rdata8));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w9_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask9), .wdata(loc_sram_wdata9), .waddr(loc_sram_waddr9), .raddr(loc_sram_raddr9), .rdata(loc_sram_rdata9));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w10_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask10), .wdata(loc_sram_wdata10), .waddr(loc_sram_waddr10), .raddr(loc_sram_raddr10), .rdata(loc_sram_rdata10));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w11_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask11), .wdata(loc_sram_wdata11), .waddr(loc_sram_waddr11), .raddr(loc_sram_raddr11), .rdata(loc_sram_rdata11));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w12_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask12), .wdata(loc_sram_wdata12), .waddr(loc_sram_waddr12), .raddr(loc_sram_raddr12), .rdata(loc_sram_rdata12));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w13_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask13), .wdata(loc_sram_wdata13), .waddr(loc_sram_waddr13), .raddr(loc_sram_raddr13), .rdata(loc_sram_rdata13));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w14_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask14), .wdata(loc_sram_wdata14), .waddr(loc_sram_waddr14), .raddr(loc_sram_raddr14), .rdata(loc_sram_rdata14));
loc_sram_16x1280b #(.ADDR_SPACE(LOC_ADDR_SPACE),.D(D),.BW(LOC_BW)) 
w15_loc_sram_16x256b(.clk(clk), .wsb(loc_sram_wen), .bytemask(locsram_wbytemask15), .wdata(loc_sram_wdata15), .waddr(loc_sram_waddr15), .raddr(loc_sram_raddr15), .rdata(loc_sram_rdata15));

// --------- dist_sram_instn ------
wire [D*DIST_BW-1:0] dist_sram_rdata0, dist_sram_rdata1, dist_sram_rdata2, dist_sram_rdata3, dist_sram_rdata4, dist_sram_rdata5, dist_sram_rdata6, dist_sram_rdata7, dist_sram_rdata8, dist_sram_rdata9, dist_sram_rdata10, dist_sram_rdata11, dist_sram_rdata12, dist_sram_rdata13, dist_sram_rdata14, dist_sram_rdata15;
wire [DIST_ADDR_SPACE-1:0] dist_sram_raddr0, dist_sram_raddr1, dist_sram_raddr2, dist_sram_raddr3, dist_sram_raddr4, dist_sram_raddr5, dist_sram_raddr6, dist_sram_raddr7, dist_sram_raddr8, dist_sram_raddr9, dist_sram_raddr10, dist_sram_raddr11, dist_sram_raddr12, dist_sram_raddr13, dist_sram_raddr14, dist_sram_raddr15;
dist_sram_NxNbxk #(.N(N), .BW(DIST_BW), .D(D), .ADDR_SPACE(DIST_ADDR_SPACE))
grand_dist_NxNbxk(.clk(clk), .wsb(), .wdata(), .waddr(),
.raddr0(dist_sram_raddr0),
.raddr1(dist_sram_raddr1),
.raddr2(dist_sram_raddr2),
.raddr3(dist_sram_raddr3),
.raddr4(dist_sram_raddr4),
.raddr5(dist_sram_raddr5),
.raddr6(dist_sram_raddr6),
.raddr7(dist_sram_raddr7),
.raddr8(dist_sram_raddr8),
.raddr9(dist_sram_raddr9),
.raddr10(dist_sram_raddr10),
.raddr11(dist_sram_raddr11),
.raddr12(dist_sram_raddr12),
.raddr13(dist_sram_raddr13),
.raddr14(dist_sram_raddr14),
.raddr15(dist_sram_raddr15),
.rdata0(dist_sram_rdata0),
.rdata1(dist_sram_rdata1),
.rdata2(dist_sram_rdata2),
.rdata3(dist_sram_rdata3),
.rdata4(dist_sram_rdata4),
.rdata5(dist_sram_rdata5),
.rdata6(dist_sram_rdata6),
.rdata7(dist_sram_rdata7),
.rdata8(dist_sram_rdata8),
.rdata9(dist_sram_rdata9),
.rdata10(dist_sram_rdata10),
.rdata11(dist_sram_rdata11),
.rdata12(dist_sram_rdata12),
.rdata13(dist_sram_rdata13),
.rdata14(dist_sram_rdata14),
.rdata15(dist_sram_rdata15)
);


wire worker_wen;

// ----- next_sram_instn ------
wire [Q*NEXT_BW-1:0] next_sram_wdata0, next_sram_wdata1, next_sram_wdata2, next_sram_wdata3, next_sram_wdata4, next_sram_wdata5, next_sram_wdata6, next_sram_wdata7, next_sram_wdata8, next_sram_wdata9, next_sram_wdata10, next_sram_wdata11, next_sram_wdata12, next_sram_wdata13, next_sram_wdata14, next_sram_wdata15;
wire [Q-1:0] next_sram_wbytemask0 ,next_sram_wbytemask1 ,next_sram_wbytemask2 ,next_sram_wbytemask3 ,next_sram_wbytemask4 ,next_sram_wbytemask5 ,next_sram_wbytemask6 ,next_sram_wbytemask7 ,next_sram_wbytemask8 ,next_sram_wbytemask9 ,next_sram_wbytemask10 ,next_sram_wbytemask11 ,next_sram_wbytemask12 ,next_sram_wbytemask13 ,next_sram_wbytemask14 ,next_sram_wbytemask15;
wire [NEXT_ADDR_SPACE-1:0] next_sram_waddr0, next_sram_waddr1, next_sram_waddr2, next_sram_waddr3, next_sram_waddr4, next_sram_waddr5, next_sram_waddr6, next_sram_waddr7, next_sram_waddr8, next_sram_waddr9, next_sram_waddr10, next_sram_waddr11, next_sram_waddr12, next_sram_waddr13, next_sram_waddr14, next_sram_waddr15;
wire [NEXT_ADDR_SPACE-1:0] next_sram_raddr0, next_sram_raddr1, next_sram_raddr2, next_sram_raddr3, next_sram_raddr4, next_sram_raddr5, next_sram_raddr6, next_sram_raddr7, next_sram_raddr8, next_sram_raddr9, next_sram_raddr10, next_sram_raddr11, next_sram_raddr12, next_sram_raddr13, next_sram_raddr14, next_sram_raddr15;
wire [NEXT_BW*Q-1:0] next_sram_rdata0 ,next_sram_rdata1 ,next_sram_rdata2 ,next_sram_rdata3 ,next_sram_rdata4 ,next_sram_rdata5 ,next_sram_rdata6 ,next_sram_rdata7 ,next_sram_rdata8 ,next_sram_rdata9 ,next_sram_rdata10 ,next_sram_rdata11 ,next_sram_rdata12 ,next_sram_rdata13 ,next_sram_rdata14 ,next_sram_rdata15;
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w0_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata0), .bytemask(next_sram_wbytemask0), .waddr(next_sram_waddr0), .raddr(next_sram_raddr0), .rdata(next_sram_rdata0));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w1_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata1), .bytemask(next_sram_wbytemask1), .waddr(next_sram_waddr1), .raddr(next_sram_raddr1), .rdata(next_sram_rdata1));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w2_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata2), .bytemask(next_sram_wbytemask2), .waddr(next_sram_waddr2), .raddr(next_sram_raddr2), .rdata(next_sram_rdata2));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w3_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata3), .bytemask(next_sram_wbytemask3), .waddr(next_sram_waddr3), .raddr(next_sram_raddr3), .rdata(next_sram_rdata3));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w4_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata4), .bytemask(next_sram_wbytemask4), .waddr(next_sram_waddr4), .raddr(next_sram_raddr4), .rdata(next_sram_rdata4));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w5_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata5), .bytemask(next_sram_wbytemask5), .waddr(next_sram_waddr5), .raddr(next_sram_raddr5), .rdata(next_sram_rdata5));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w6_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata6), .bytemask(next_sram_wbytemask6), .waddr(next_sram_waddr6), .raddr(next_sram_raddr6), .rdata(next_sram_rdata6));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w7_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata7), .bytemask(next_sram_wbytemask7), .waddr(next_sram_waddr7), .raddr(next_sram_raddr7), .rdata(next_sram_rdata7));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w8_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata8), .bytemask(next_sram_wbytemask8), .waddr(next_sram_waddr8), .raddr(next_sram_raddr8), .rdata(next_sram_rdata8));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w9_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata9), .bytemask(next_sram_wbytemask9), .waddr(next_sram_waddr9), .raddr(next_sram_raddr9), .rdata(next_sram_rdata9));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w10_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata10), .bytemask(next_sram_wbytemask10), .waddr(next_sram_waddr10), .raddr(next_sram_raddr10), .rdata(next_sram_rdata10));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w11_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata11), .bytemask(next_sram_wbytemask11), .waddr(next_sram_waddr11), .raddr(next_sram_raddr11), .rdata(next_sram_rdata11));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w12_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata12), .bytemask(next_sram_wbytemask12), .waddr(next_sram_waddr12), .raddr(next_sram_raddr12), .rdata(next_sram_rdata12));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w13_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata13), .bytemask(next_sram_wbytemask13), .waddr(next_sram_waddr13), .raddr(next_sram_raddr13), .rdata(next_sram_rdata13));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w14_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata14), .bytemask(next_sram_wbytemask14), .waddr(next_sram_waddr14), .raddr(next_sram_raddr14), .rdata(next_sram_rdata14));
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW))
w15_next_sram_256x4b(.clk(clk), .wsb(~worker_wen), .wdata(next_sram_wdata15), .bytemask(next_sram_wbytemask15), .waddr(next_sram_waddr15), .raddr(next_sram_raddr15), .rdata(next_sram_rdata15));
// ----- proposal_sram_instn ------
wire [Q*PRO_BW-1:0] pro_sram_wdata0, pro_sram_wdata1, pro_sram_wdata2, pro_sram_wdata3, pro_sram_wdata4, pro_sram_wdata5, pro_sram_wdata6, pro_sram_wdata7, pro_sram_wdata8, pro_sram_wdata9, pro_sram_wdata10, pro_sram_wdata11, pro_sram_wdata12, pro_sram_wdata13, pro_sram_wdata14, pro_sram_wdata15;
wire [Q-1:0] pro_sram_wbytemask0, pro_sram_wbytemask1, pro_sram_wbytemask2, pro_sram_wbytemask3, pro_sram_wbytemask4, pro_sram_wbytemask5, pro_sram_wbytemask6, pro_sram_wbytemask7, pro_sram_wbytemask8, pro_sram_wbytemask9, pro_sram_wbytemask10, pro_sram_wbytemask11, pro_sram_wbytemask12, pro_sram_wbytemask13, pro_sram_wbytemask14, pro_sram_wbytemask15;
wire [PRO_ADDR_SPACE-1:0] pro_sram_waddr0, pro_sram_waddr1, pro_sram_waddr2, pro_sram_waddr3, pro_sram_waddr4, pro_sram_waddr5, pro_sram_waddr6, pro_sram_waddr7, pro_sram_waddr8, pro_sram_waddr9, pro_sram_waddr10, pro_sram_waddr11, pro_sram_waddr12, pro_sram_waddr13, pro_sram_waddr14, pro_sram_waddr15;
wire [PRO_ADDR_SPACE-1:0] pro_sram_raddr0, pro_sram_raddr1, pro_sram_raddr2, pro_sram_raddr3, pro_sram_raddr4, pro_sram_raddr5, pro_sram_raddr6, pro_sram_raddr7, pro_sram_raddr8, pro_sram_raddr9, pro_sram_raddr10, pro_sram_raddr11, pro_sram_raddr12, pro_sram_raddr13, pro_sram_raddr14, pro_sram_raddr15;
wire [Q*PRO_BW-1:0] pro_sram_rdata0, pro_sram_rdata1, pro_sram_rdata2, pro_sram_rdata3, pro_sram_rdata4, pro_sram_rdata5, pro_sram_rdata6, pro_sram_rdata7, pro_sram_rdata8, pro_sram_rdata9, pro_sram_rdata10, pro_sram_rdata11, pro_sram_rdata12, pro_sram_rdata13, pro_sram_rdata14, pro_sram_rdata15;

proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w0_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata0), .bytemask(pro_sram_wbytemask0), .waddr(pro_sram_waddr0), .raddr(pro_sram_raddr0), .rdata(pro_sram_rdata0));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w1_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata1), .bytemask(pro_sram_wbytemask1), .waddr(pro_sram_waddr1), .raddr(pro_sram_raddr1), .rdata(pro_sram_rdata1));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w2_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata2), .bytemask(pro_sram_wbytemask2), .waddr(pro_sram_waddr2), .raddr(pro_sram_raddr2), .rdata(pro_sram_rdata2));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w3_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata3), .bytemask(pro_sram_wbytemask3), .waddr(pro_sram_waddr3), .raddr(pro_sram_raddr3), .rdata(pro_sram_rdata3));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w4_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata4), .bytemask(pro_sram_wbytemask4), .waddr(pro_sram_waddr4), .raddr(pro_sram_raddr4), .rdata(pro_sram_rdata4));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w5_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata5), .bytemask(pro_sram_wbytemask5), .waddr(pro_sram_waddr5), .raddr(pro_sram_raddr5), .rdata(pro_sram_rdata5));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w6_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata6), .bytemask(pro_sram_wbytemask6), .waddr(pro_sram_waddr6), .raddr(pro_sram_raddr6), .rdata(pro_sram_rdata6));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w7_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata7), .bytemask(pro_sram_wbytemask7), .waddr(pro_sram_waddr7), .raddr(pro_sram_raddr7), .rdata(pro_sram_rdata7));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w8_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata8), .bytemask(pro_sram_wbytemask8), .waddr(pro_sram_waddr8), .raddr(pro_sram_raddr8), .rdata(pro_sram_rdata8));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w9_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata9), .bytemask(pro_sram_wbytemask9), .waddr(pro_sram_waddr9), .raddr(pro_sram_raddr9), .rdata(pro_sram_rdata9));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w10_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata10), .bytemask(pro_sram_wbytemask10), .waddr(pro_sram_waddr10), .raddr(pro_sram_raddr10), .rdata(pro_sram_rdata10));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w11_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata11), .bytemask(pro_sram_wbytemask11), .waddr(pro_sram_waddr11), .raddr(pro_sram_raddr11), .rdata(pro_sram_rdata11));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w12_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata12), .bytemask(pro_sram_wbytemask12), .waddr(pro_sram_waddr12), .raddr(pro_sram_raddr12), .rdata(pro_sram_rdata12));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w13_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata13), .bytemask(pro_sram_wbytemask13), .waddr(pro_sram_waddr13), .raddr(pro_sram_raddr13), .rdata(pro_sram_rdata13));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w14_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata14), .bytemask(pro_sram_wbytemask14), .waddr(pro_sram_waddr14), .raddr(pro_sram_raddr14), .rdata(pro_sram_rdata14));
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW))
w15_proposal_sram_16x128b(.clk(clk), .wsb(~worker_wen), .wdata(pro_sram_wdata15), .bytemask(pro_sram_wbytemask15), .waddr(pro_sram_waddr15), .raddr(pro_sram_raddr15), .rdata(pro_sram_rdata15));


//============================== module instance ========================

top #(
.K(K),
.D(D),
.DIST_BW(DIST_BW),
.DIST_ADDR_SPACE(DIST_ADDR_SPACE),
.LOC_BW(LOC_BW),
.LOC_ADDR_SPACE(LOC_ADDR_SPACE),
.NEXT_BW(NEXT_BW),
.NEXT_ADDR_SPACE(NEXT_ADDR_SPACE),
.PRO_BW(PRO_BW),
.PRO_ADDR_SPACE(PRO_ADDR_SPACE),
.VID_BW(VID_BW),
.VID_ADDR_SPACE(VID_ADDR_SPACE),
.Q(Q)
) my_graph_top (
    .clk(clk), .en(enable), .rst_n(rst_n),
    .vidsram_wen(vidsram_wen),
    .vid_sram_rdata0(vid_sram_rdata0), .vid_sram_raddr0(vid_sram_raddr0), .vid_sram_wdata0(vid_sram_wdata0),	.vid_sram_waddr0(vid_sram_waddr0),
    .vid_sram_rdata1(vid_sram_rdata1), .vid_sram_raddr1(vid_sram_raddr1), .vid_sram_wdata1(vid_sram_wdata1),	.vid_sram_waddr1(vid_sram_waddr1),
    .vid_sram_rdata2(vid_sram_rdata2), .vid_sram_raddr2(vid_sram_raddr2), .vid_sram_wdata2(vid_sram_wdata2),	.vid_sram_waddr2(vid_sram_waddr2),
    .vid_sram_rdata3(vid_sram_rdata3), .vid_sram_raddr3(vid_sram_raddr3), .vid_sram_wdata3(vid_sram_wdata3),	.vid_sram_waddr3(vid_sram_waddr3),
    .vid_sram_rdata4(vid_sram_rdata4), .vid_sram_raddr4(vid_sram_raddr4), .vid_sram_wdata4(vid_sram_wdata4),	.vid_sram_waddr4(vid_sram_waddr4),
    .vid_sram_rdata5(vid_sram_rdata5), .vid_sram_raddr5(vid_sram_raddr5), .vid_sram_wdata5(vid_sram_wdata5),	.vid_sram_waddr5(vid_sram_waddr5),
    .vid_sram_rdata6(vid_sram_rdata6), .vid_sram_raddr6(vid_sram_raddr6), .vid_sram_wdata6(vid_sram_wdata6),	.vid_sram_waddr6(vid_sram_waddr6),
    .vid_sram_rdata7(vid_sram_rdata7), .vid_sram_raddr7(vid_sram_raddr7), .vid_sram_wdata7(vid_sram_wdata7),	.vid_sram_waddr7(vid_sram_waddr7),
    .vid_sram_rdata8(vid_sram_rdata8), .vid_sram_raddr8(vid_sram_raddr8), .vid_sram_wdata8(vid_sram_wdata8),	.vid_sram_waddr8(vid_sram_waddr8),
    .vid_sram_rdata9(vid_sram_rdata9), .vid_sram_raddr9(vid_sram_raddr9), .vid_sram_wdata9(vid_sram_wdata9),	.vid_sram_waddr9(vid_sram_waddr9),
    .vid_sram_rdata10(vid_sram_rdata10), .vid_sram_raddr10(vid_sram_raddr10), .vid_sram_wdata10(vid_sram_wdata10), .vid_sram_waddr10(vid_sram_waddr10),
    .vid_sram_rdata11(vid_sram_rdata11), .vid_sram_raddr11(vid_sram_raddr11), .vid_sram_wdata11(vid_sram_wdata11), .vid_sram_waddr11(vid_sram_waddr11),
    .vid_sram_rdata12(vid_sram_rdata12), .vid_sram_raddr12(vid_sram_raddr12), .vid_sram_wdata12(vid_sram_wdata12), .vid_sram_waddr12(vid_sram_waddr12),
    .vid_sram_rdata13(vid_sram_rdata13), .vid_sram_raddr13(vid_sram_raddr13), .vid_sram_wdata13(vid_sram_wdata13), .vid_sram_waddr13(vid_sram_waddr13),
    .vid_sram_rdata14(vid_sram_rdata14), .vid_sram_raddr14(vid_sram_raddr14), .vid_sram_wdata14(vid_sram_wdata14), .vid_sram_waddr14(vid_sram_waddr14),
    .vid_sram_rdata15(vid_sram_rdata15), .vid_sram_raddr15(vid_sram_raddr15), .vid_sram_wdata15(vid_sram_wdata15), .vid_sram_waddr15(vid_sram_waddr15),

    .loc_sram_wen(loc_sram_wen),
    .loc_sram_rdata0(loc_sram_rdata0), .loc_sram_raddr0(loc_sram_raddr0), .loc_sram_wdata0(loc_sram_wdata0), .loc_sram_waddr0(loc_sram_waddr0), .loc_wbytemask0(locsram_wbytemask0),
    .loc_sram_rdata1(loc_sram_rdata1), .loc_sram_raddr1(loc_sram_raddr1), .loc_sram_wdata1(loc_sram_wdata1), .loc_sram_waddr1(loc_sram_waddr1), .loc_wbytemask1(locsram_wbytemask1),
    .loc_sram_rdata2(loc_sram_rdata2), .loc_sram_raddr2(loc_sram_raddr2), .loc_sram_wdata2(loc_sram_wdata2), .loc_sram_waddr2(loc_sram_waddr2), .loc_wbytemask2(locsram_wbytemask2),
    .loc_sram_rdata3(loc_sram_rdata3), .loc_sram_raddr3(loc_sram_raddr3), .loc_sram_wdata3(loc_sram_wdata3), .loc_sram_waddr3(loc_sram_waddr3), .loc_wbytemask3(locsram_wbytemask3),
    .loc_sram_rdata4(loc_sram_rdata4), .loc_sram_raddr4(loc_sram_raddr4), .loc_sram_wdata4(loc_sram_wdata4), .loc_sram_waddr4(loc_sram_waddr4), .loc_wbytemask4(locsram_wbytemask4),
    .loc_sram_rdata5(loc_sram_rdata5), .loc_sram_raddr5(loc_sram_raddr5), .loc_sram_wdata5(loc_sram_wdata5), .loc_sram_waddr5(loc_sram_waddr5), .loc_wbytemask5(locsram_wbytemask5),
    .loc_sram_rdata6(loc_sram_rdata6), .loc_sram_raddr6(loc_sram_raddr6), .loc_sram_wdata6(loc_sram_wdata6), .loc_sram_waddr6(loc_sram_waddr6), .loc_wbytemask6(locsram_wbytemask6),
    .loc_sram_rdata7(loc_sram_rdata7), .loc_sram_raddr7(loc_sram_raddr7), .loc_sram_wdata7(loc_sram_wdata7), .loc_sram_waddr7(loc_sram_waddr7), .loc_wbytemask7(locsram_wbytemask7),
    .loc_sram_rdata8(loc_sram_rdata8), .loc_sram_raddr8(loc_sram_raddr8), .loc_sram_wdata8(loc_sram_wdata8), .loc_sram_waddr8(loc_sram_waddr8), .loc_wbytemask8(locsram_wbytemask8),
    .loc_sram_rdata9(loc_sram_rdata9), .loc_sram_raddr9(loc_sram_raddr9), .loc_sram_wdata9(loc_sram_wdata9), .loc_sram_waddr9(loc_sram_waddr9), .loc_wbytemask9(locsram_wbytemask9),
    .loc_sram_rdata10(loc_sram_rdata10), .loc_sram_raddr10(loc_sram_raddr10), .loc_sram_wdata10(loc_sram_wdata10), .loc_sram_waddr10(loc_sram_waddr10), .loc_wbytemask10(locsram_wbytemask10),
    .loc_sram_rdata11(loc_sram_rdata11), .loc_sram_raddr11(loc_sram_raddr11), .loc_sram_wdata11(loc_sram_wdata11), .loc_sram_waddr11(loc_sram_waddr11), .loc_wbytemask11(locsram_wbytemask11),
    .loc_sram_rdata12(loc_sram_rdata12), .loc_sram_raddr12(loc_sram_raddr12), .loc_sram_wdata12(loc_sram_wdata12), .loc_sram_waddr12(loc_sram_waddr12), .loc_wbytemask12(locsram_wbytemask12),
    .loc_sram_rdata13(loc_sram_rdata13), .loc_sram_raddr13(loc_sram_raddr13), .loc_sram_wdata13(loc_sram_wdata13), .loc_sram_waddr13(loc_sram_waddr13), .loc_wbytemask13(locsram_wbytemask13),
    .loc_sram_rdata14(loc_sram_rdata14), .loc_sram_raddr14(loc_sram_raddr14), .loc_sram_wdata14(loc_sram_wdata14), .loc_sram_waddr14(loc_sram_waddr14), .loc_wbytemask14(locsram_wbytemask14),
    .loc_sram_rdata15(loc_sram_rdata15), .loc_sram_raddr15(loc_sram_raddr15), .loc_sram_wdata15(loc_sram_wdata15), .loc_sram_waddr15(loc_sram_waddr15), .loc_wbytemask15(locsram_wbytemask15),

	.dist_sram_rdata0(dist_sram_rdata0), .dist_sram_raddr0(dist_sram_raddr0),
	.dist_sram_rdata1(dist_sram_rdata1), .dist_sram_raddr1(dist_sram_raddr1),
	.dist_sram_rdata2(dist_sram_rdata2), .dist_sram_raddr2(dist_sram_raddr2),
	.dist_sram_rdata3(dist_sram_rdata3), .dist_sram_raddr3(dist_sram_raddr3),
	.dist_sram_rdata4(dist_sram_rdata4), .dist_sram_raddr4(dist_sram_raddr4),
	.dist_sram_rdata5(dist_sram_rdata5), .dist_sram_raddr5(dist_sram_raddr5),
	.dist_sram_rdata6(dist_sram_rdata6), .dist_sram_raddr6(dist_sram_raddr6),
	.dist_sram_rdata7(dist_sram_rdata7), .dist_sram_raddr7(dist_sram_raddr7),
	.dist_sram_rdata8(dist_sram_rdata8), .dist_sram_raddr8(dist_sram_raddr8),
	.dist_sram_rdata9(dist_sram_rdata9), .dist_sram_raddr9(dist_sram_raddr9),
	.dist_sram_rdata10(dist_sram_rdata10), .dist_sram_raddr10(dist_sram_raddr10),
	.dist_sram_rdata11(dist_sram_rdata11), .dist_sram_raddr11(dist_sram_raddr11),
	.dist_sram_rdata12(dist_sram_rdata12), .dist_sram_raddr12(dist_sram_raddr12),
	.dist_sram_rdata13(dist_sram_rdata13), .dist_sram_raddr13(dist_sram_raddr13),
	.dist_sram_rdata14(dist_sram_rdata14), .dist_sram_raddr14(dist_sram_raddr14),
	.dist_sram_rdata15(dist_sram_rdata15), .dist_sram_raddr15(dist_sram_raddr15),

    .worker_wen(worker_wen),
	.next_sram_rdata0(next_sram_rdata0), .next_sram_raddr0(next_sram_raddr0), .next_sram_wdata0(next_sram_wdata0), .next_sram_waddr0(next_sram_waddr0), .next_wbytemask0(next_sram_wbytemask0),
	.next_sram_rdata1(next_sram_rdata1), .next_sram_raddr1(next_sram_raddr1), .next_sram_wdata1(next_sram_wdata1), .next_sram_waddr1(next_sram_waddr1), .next_wbytemask1(next_sram_wbytemask1),
	.next_sram_rdata2(next_sram_rdata2), .next_sram_raddr2(next_sram_raddr2), .next_sram_wdata2(next_sram_wdata2), .next_sram_waddr2(next_sram_waddr2), .next_wbytemask2(next_sram_wbytemask2),
	.next_sram_rdata3(next_sram_rdata3), .next_sram_raddr3(next_sram_raddr3), .next_sram_wdata3(next_sram_wdata3), .next_sram_waddr3(next_sram_waddr3), .next_wbytemask3(next_sram_wbytemask3),
	.next_sram_rdata4(next_sram_rdata4), .next_sram_raddr4(next_sram_raddr4), .next_sram_wdata4(next_sram_wdata4), .next_sram_waddr4(next_sram_waddr4), .next_wbytemask4(next_sram_wbytemask4),
	.next_sram_rdata5(next_sram_rdata5), .next_sram_raddr5(next_sram_raddr5), .next_sram_wdata5(next_sram_wdata5), .next_sram_waddr5(next_sram_waddr5), .next_wbytemask5(next_sram_wbytemask5),
	.next_sram_rdata6(next_sram_rdata6), .next_sram_raddr6(next_sram_raddr6), .next_sram_wdata6(next_sram_wdata6), .next_sram_waddr6(next_sram_waddr6), .next_wbytemask6(next_sram_wbytemask6),
	.next_sram_rdata7(next_sram_rdata7), .next_sram_raddr7(next_sram_raddr7), .next_sram_wdata7(next_sram_wdata7), .next_sram_waddr7(next_sram_waddr7), .next_wbytemask7(next_sram_wbytemask7),
	.next_sram_rdata8(next_sram_rdata8), .next_sram_raddr8(next_sram_raddr8), .next_sram_wdata8(next_sram_wdata8), .next_sram_waddr8(next_sram_waddr8), .next_wbytemask8(next_sram_wbytemask8),
	.next_sram_rdata9(next_sram_rdata9), .next_sram_raddr9(next_sram_raddr9), .next_sram_wdata9(next_sram_wdata9), .next_sram_waddr9(next_sram_waddr9), .next_wbytemask9(next_sram_wbytemask9),
	.next_sram_rdata10(next_sram_rdata10), .next_sram_raddr10(next_sram_raddr10), .next_sram_wdata10(next_sram_wdata10), .next_sram_waddr10(next_sram_waddr10), .next_wbytemask10(next_sram_wbytemask10),
	.next_sram_rdata11(next_sram_rdata11), .next_sram_raddr11(next_sram_raddr11), .next_sram_wdata11(next_sram_wdata11), .next_sram_waddr11(next_sram_waddr11), .next_wbytemask11(next_sram_wbytemask11),
	.next_sram_rdata12(next_sram_rdata12), .next_sram_raddr12(next_sram_raddr12), .next_sram_wdata12(next_sram_wdata12), .next_sram_waddr12(next_sram_waddr12), .next_wbytemask12(next_sram_wbytemask12),
	.next_sram_rdata13(next_sram_rdata13), .next_sram_raddr13(next_sram_raddr13), .next_sram_wdata13(next_sram_wdata13), .next_sram_waddr13(next_sram_waddr13), .next_wbytemask13(next_sram_wbytemask13),
	.next_sram_rdata14(next_sram_rdata14), .next_sram_raddr14(next_sram_raddr14), .next_sram_wdata14(next_sram_wdata14), .next_sram_waddr14(next_sram_waddr14), .next_wbytemask14(next_sram_wbytemask14),
	.next_sram_rdata15(next_sram_rdata15), .next_sram_raddr15(next_sram_raddr15), .next_sram_wdata15(next_sram_wdata15), .next_sram_waddr15(next_sram_waddr15), .next_wbytemask15(next_sram_wbytemask15),

    .pro_sram_rdata0(pro_sram_rdata0), .pro_sram_raddr0(pro_sram_raddr0), .pro_sram_wdata0(pro_sram_wdata0), .pro_sram_waddr0(pro_sram_waddr0), .pro_wbytemask0(pro_sram_wbytemask0),
    .pro_sram_rdata1(pro_sram_rdata1), .pro_sram_raddr1(pro_sram_raddr1), .pro_sram_wdata1(pro_sram_wdata1), .pro_sram_waddr1(pro_sram_waddr1), .pro_wbytemask1(pro_sram_wbytemask1),
    .pro_sram_rdata2(pro_sram_rdata2), .pro_sram_raddr2(pro_sram_raddr2), .pro_sram_wdata2(pro_sram_wdata2), .pro_sram_waddr2(pro_sram_waddr2), .pro_wbytemask2(pro_sram_wbytemask2),
    .pro_sram_rdata3(pro_sram_rdata3), .pro_sram_raddr3(pro_sram_raddr3), .pro_sram_wdata3(pro_sram_wdata3), .pro_sram_waddr3(pro_sram_waddr3), .pro_wbytemask3(pro_sram_wbytemask3),
    .pro_sram_rdata4(pro_sram_rdata4), .pro_sram_raddr4(pro_sram_raddr4), .pro_sram_wdata4(pro_sram_wdata4), .pro_sram_waddr4(pro_sram_waddr4), .pro_wbytemask4(pro_sram_wbytemask4),
    .pro_sram_rdata5(pro_sram_rdata5), .pro_sram_raddr5(pro_sram_raddr5), .pro_sram_wdata5(pro_sram_wdata5), .pro_sram_waddr5(pro_sram_waddr5), .pro_wbytemask5(pro_sram_wbytemask5),
    .pro_sram_rdata6(pro_sram_rdata6), .pro_sram_raddr6(pro_sram_raddr6), .pro_sram_wdata6(pro_sram_wdata6), .pro_sram_waddr6(pro_sram_waddr6), .pro_wbytemask6(pro_sram_wbytemask6),
    .pro_sram_rdata7(pro_sram_rdata7), .pro_sram_raddr7(pro_sram_raddr7), .pro_sram_wdata7(pro_sram_wdata7), .pro_sram_waddr7(pro_sram_waddr7), .pro_wbytemask7(pro_sram_wbytemask7),
    .pro_sram_rdata8(pro_sram_rdata8), .pro_sram_raddr8(pro_sram_raddr8), .pro_sram_wdata8(pro_sram_wdata8), .pro_sram_waddr8(pro_sram_waddr8), .pro_wbytemask8(pro_sram_wbytemask8),
    .pro_sram_rdata9(pro_sram_rdata9), .pro_sram_raddr9(pro_sram_raddr9), .pro_sram_wdata9(pro_sram_wdata9), .pro_sram_waddr9(pro_sram_waddr9), .pro_wbytemask9(pro_sram_wbytemask9),
    .pro_sram_rdata10(pro_sram_rdata10), .pro_sram_raddr10(pro_sram_raddr10), .pro_sram_wdata10(pro_sram_wdata10), .pro_sram_waddr10(pro_sram_waddr10), .pro_wbytemask10(pro_sram_wbytemask10),
    .pro_sram_rdata11(pro_sram_rdata11), .pro_sram_raddr11(pro_sram_raddr11), .pro_sram_wdata11(pro_sram_wdata11), .pro_sram_waddr11(pro_sram_waddr11), .pro_wbytemask11(pro_sram_wbytemask11),
    .pro_sram_rdata12(pro_sram_rdata12), .pro_sram_raddr12(pro_sram_raddr12), .pro_sram_wdata12(pro_sram_wdata12), .pro_sram_waddr12(pro_sram_waddr12), .pro_wbytemask12(pro_sram_wbytemask12),
    .pro_sram_rdata13(pro_sram_rdata13), .pro_sram_raddr13(pro_sram_raddr13), .pro_sram_wdata13(pro_sram_wdata13), .pro_sram_waddr13(pro_sram_waddr13), .pro_wbytemask13(pro_sram_wbytemask13),
    .pro_sram_rdata14(pro_sram_rdata14), .pro_sram_raddr14(pro_sram_raddr14), .pro_sram_wdata14(pro_sram_wdata14), .pro_sram_waddr14(pro_sram_waddr14), .pro_wbytemask14(pro_sram_wbytemask14),
    .pro_sram_rdata15(pro_sram_rdata15), .pro_sram_raddr15(pro_sram_raddr15), .pro_sram_wdata15(pro_sram_wdata15), .pro_sram_waddr15(pro_sram_waddr15), .pro_wbytemask15(pro_sram_wbytemask15),

	.part_finish(part_finish)
);



// ============================== GOLD ========================
reg [VID_BW*Q-1:0] w0_vgidx[0:15], w0_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w1_vgidx[0:15], w1_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w2_vgidx[0:15], w2_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w3_vgidx[0:15], w3_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w4_vgidx[0:15], w4_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w5_vgidx[0:15], w5_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w6_vgidx[0:15], w6_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w7_vgidx[0:15], w7_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w8_vgidx[0:15], w8_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w9_vgidx[0:15], w9_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w10_vgidx[0:15], w10_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w11_vgidx[0:15], w11_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w12_vgidx[0:15], w12_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w13_vgidx[0:15], w13_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w14_vgidx[0:15], w14_vid_sram_gold[0:16-1];
reg [VID_BW*Q-1:0] w15_vgidx[0:15], w15_vid_sram_gold[0:16-1];
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
reg [NEXT_BW*Q-1:0] w0_next_gold[0:15];     reg [PRO_BW*Q-1:0] w0_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w1_next_gold[0:15];     reg [PRO_BW*Q-1:0] w1_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w2_next_gold[0:15];     reg [PRO_BW*Q-1:0] w2_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w3_next_gold[0:15];     reg [PRO_BW*Q-1:0] w3_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w4_next_gold[0:15];     reg [PRO_BW*Q-1:0] w4_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w5_next_gold[0:15];     reg [PRO_BW*Q-1:0] w5_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w6_next_gold[0:15];     reg [PRO_BW*Q-1:0] w6_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w7_next_gold[0:15];     reg [PRO_BW*Q-1:0] w7_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w8_next_gold[0:15];     reg [PRO_BW*Q-1:0] w8_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w9_next_gold[0:15];     reg [PRO_BW*Q-1:0] w9_pro_gold[0:15];     
reg [NEXT_BW*Q-1:0] w10_next_gold[0:15];    reg [PRO_BW*Q-1:0] w10_pro_gold[0:15];        
reg [NEXT_BW*Q-1:0] w11_next_gold[0:15];    reg [PRO_BW*Q-1:0] w11_pro_gold[0:15];        
reg [NEXT_BW*Q-1:0] w12_next_gold[0:15];    reg [PRO_BW*Q-1:0] w12_pro_gold[0:15];        
reg [NEXT_BW*Q-1:0] w13_next_gold[0:15];    reg [PRO_BW*Q-1:0] w13_pro_gold[0:15];        
reg [NEXT_BW*Q-1:0] w14_next_gold[0:15];    reg [PRO_BW*Q-1:0] w14_pro_gold[0:15];        
reg [NEXT_BW*Q-1:0] w15_next_gold[0:15];    reg [PRO_BW*Q-1:0] w15_pro_gold[0:15];        

// reg [LOC_BW*Q-1:0] loc_init[0:15];

always #(CYCLE/2) clk = ~clk;

initial begin
    $fsdbDumpfile("test_top_module_1.fsdb");
    $fsdbDumpvars("+mda");
end

integer ccc;
reg [8:0] check_epoch;
integer feed, feed_v;
reg [4:0] srami;
reg [8:0] locsrami;
integer sram_i;
reg rerun;
integer rrr, tmp;
integer mi;
reg [VID_BW*Q-1:0] vid_input_w0 [0:16-1], vid_input_w1 [0:16-1], vid_input_w2 [0:16-1], vid_input_w3 [0:16-1], vid_input_w4 [0:16-1], vid_input_w5 [0:16-1], vid_input_w6 [0:16-1], vid_input_w7 [0:16-1], vid_input_w8 [0:16-1], vid_input_w9 [0:16-1], vid_input_w10 [0:16-1], vid_input_w11 [0:16-1], vid_input_w12 [0:16-1], vid_input_w13 [0:16-1], vid_input_w14 [0:16-1], vid_input_w15 [0:16-1];
initial begin 
    // pingpong = 0;
    clk = 0;
    rst_n = 1;
    enable = 1'b0;
    rerun = 1'b0;
    // $readmemh("../software/gold_master_s/v_gidx_w0.dat", w0_vgidx);    $readmemh("../software/gold_master/vid_sram_w0.dat", w0_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w1.dat", w1_vgidx);    $readmemh("../software/gold_master/vid_sram_w1.dat", w1_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w2.dat", w2_vgidx);    $readmemh("../software/gold_master/vid_sram_w2.dat", w2_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w3.dat", w3_vgidx);    $readmemh("../software/gold_master/vid_sram_w3.dat", w3_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w4.dat", w4_vgidx);    $readmemh("../software/gold_master/vid_sram_w4.dat", w4_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w5.dat", w5_vgidx);    $readmemh("../software/gold_master/vid_sram_w5.dat", w5_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w6.dat", w6_vgidx);    $readmemh("../software/gold_master/vid_sram_w6.dat", w6_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w7.dat", w7_vgidx);    $readmemh("../software/gold_master/vid_sram_w7.dat", w7_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w8.dat", w8_vgidx);    $readmemh("../software/gold_master/vid_sram_w8.dat", w8_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w9.dat", w9_vgidx);    $readmemh("../software/gold_master/vid_sram_w9.dat", w9_vid_sram_gold);
    // $readmemh("../software/gold_master_s/v_gidx_w10.dat", w10_vgidx);  $readmemh("../software/gold_master/vid_sram_w10.dat", w10_vid_sram_gold);    
    // $readmemh("../software/gold_master_s/v_gidx_w11.dat", w11_vgidx);  $readmemh("../software/gold_master/vid_sram_w11.dat", w11_vid_sram_gold);    
    // $readmemh("../software/gold_master_s/v_gidx_w12.dat", w12_vgidx);  $readmemh("../software/gold_master/vid_sram_w12.dat", w12_vid_sram_gold);    
    // $readmemh("../software/gold_master_s/v_gidx_w13.dat", w13_vgidx);  $readmemh("../software/gold_master/vid_sram_w13.dat", w13_vid_sram_gold);    
    // $readmemh("../software/gold_master_s/v_gidx_w14.dat", w14_vgidx);  $readmemh("../software/gold_master/vid_sram_w14.dat", w14_vid_sram_gold);    
    // $readmemh("../software/gold_master_s/v_gidx_w15.dat", w15_vgidx);  $readmemh("../software/gold_master/vid_sram_w15.dat", w15_vid_sram_gold);    
    
    $write("read master gold done");
    // ---- prepare for worker data ----
    $readmemh("../software/gold/dist_sram.dat", grand_dist_NxNbxk.mem);
    // for(mi = 0; mi < 65536; mi = mi + 1) begin 
    // w1_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w2_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w3_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w4_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w5_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w6_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w7_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w8_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w9_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w10_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w11_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w12_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w13_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w14_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // w15_dist_sram_NxNb.mem[mi] = w0_dist_sram_NxNb.mem[mi];
    // end 

    $readmemh("../software/gold/0_vid.dat", vid_input_w0);
    $readmemh("../software/gold/1_vid.dat", vid_input_w1);
    $readmemh("../software/gold/2_vid.dat", vid_input_w2);
    $readmemh("../software/gold/3_vid.dat", vid_input_w3);
    $readmemh("../software/gold/4_vid.dat", vid_input_w4);
    $readmemh("../software/gold/5_vid.dat", vid_input_w5);
    $readmemh("../software/gold/6_vid.dat", vid_input_w6);
    $readmemh("../software/gold/7_vid.dat", vid_input_w7);
    $readmemh("../software/gold/8_vid.dat", vid_input_w8);
    $readmemh("../software/gold/9_vid.dat", vid_input_w9);
    $readmemh("../software/gold/10_vid.dat", vid_input_w10);
    $readmemh("../software/gold/11_vid.dat", vid_input_w11);
    $readmemh("../software/gold/12_vid.dat", vid_input_w12);
    $readmemh("../software/gold/13_vid.dat", vid_input_w13);
    $readmemh("../software/gold/14_vid.dat", vid_input_w14);
    $readmemh("../software/gold/15_vid.dat", vid_input_w15);
    for(tmp = 0; tmp < 16; tmp = tmp + 1) begin 
        w0_vid_sram_16x256b.load_param(tmp, vid_input_w0[tmp]);
        w1_vid_sram_16x256b.load_param(tmp, vid_input_w1[tmp]);
        w2_vid_sram_16x256b.load_param(tmp, vid_input_w2[tmp]);
        w3_vid_sram_16x256b.load_param(tmp, vid_input_w3[tmp]);
        w4_vid_sram_16x256b.load_param(tmp, vid_input_w4[tmp]);
        w5_vid_sram_16x256b.load_param(tmp, vid_input_w5[tmp]);
        w6_vid_sram_16x256b.load_param(tmp, vid_input_w6[tmp]);
        w7_vid_sram_16x256b.load_param(tmp, vid_input_w7[tmp]);
        w8_vid_sram_16x256b.load_param(tmp, vid_input_w8[tmp]);
        w9_vid_sram_16x256b.load_param(tmp, vid_input_w9[tmp]);
        w10_vid_sram_16x256b.load_param(tmp, vid_input_w10[tmp]);
        w11_vid_sram_16x256b.load_param(tmp, vid_input_w11[tmp]);
        w12_vid_sram_16x256b.load_param(tmp, vid_input_w12[tmp]);
        w13_vid_sram_16x256b.load_param(tmp, vid_input_w13[tmp]);
        w14_vid_sram_16x256b.load_param(tmp, vid_input_w14[tmp]);
        w15_vid_sram_16x256b.load_param(tmp, vid_input_w15[tmp]);
    end 

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
    
    $readmemb("../software/gold_master_s/loc_w0.dat", w0_loc_sram_16x256b.mem);
    // $write("locsram %b\n", w0_loc_sram_16x256b.mem[3]);

    $write("init done");
    // -------------
    // $readmemb("../software/gold_master_s/locsram_w0.dat",  w0_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w1.dat",  w1_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w2.dat",  w2_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w3.dat",  w3_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w4.dat",  w4_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w5.dat",  w5_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w6.dat",  w6_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w7.dat",  w7_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w8.dat",  w8_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w9.dat",  w9_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w10.dat",  w10_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w11.dat",  w11_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w12.dat",  w12_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w13.dat",  w13_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w14.dat",  w14_loc_sram_gold);
    //$readmemb("../software/gold_master_s/locsram_w15.dat",  w15_loc_sram_gold);
    
     $write("read worker gold ");
    #(CYCLE) rst_n = 1'b0; 

    #(CYCLE) rst_n = 1'b1;   enable = 1'b1;
    
    wait(part_finish == 1);
    $readmemh("../software/gold_master_s/proposal_nums_w0.dat", w0_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w0.dat", w0_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w1.dat", w1_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w1.dat", w1_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w2.dat", w2_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w2.dat", w2_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w3.dat", w3_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w3.dat", w3_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w4.dat", w4_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w4.dat", w4_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w5.dat", w5_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w5.dat", w5_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w6.dat", w6_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w6.dat", w6_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w7.dat", w7_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w7.dat", w7_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w8.dat", w8_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w8.dat", w8_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w9.dat", w9_pro_gold);       $readmemh("../software/gold_master_s/next_sram_w9.dat", w9_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w10.dat", w10_pro_gold);     $readmemh("../software/gold_master_s/next_sram_w10.dat", w10_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w11.dat", w11_pro_gold);     $readmemh("../software/gold_master_s/next_sram_w11.dat", w11_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w12.dat", w12_pro_gold);     $readmemh("../software/gold_master_s/next_sram_w12.dat", w12_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w13.dat", w13_pro_gold);     $readmemh("../software/gold_master_s/next_sram_w13.dat", w13_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w14.dat", w14_pro_gold);     $readmemh("../software/gold_master_s/next_sram_w14.dat", w14_next_gold);
    $readmemh("../software/gold_master_s/proposal_nums_w15.dat", w15_pro_gold);     $readmemh("../software/gold_master_s/next_sram_w15.dat", w15_next_gold);
    
    enable = 1'b0;
    $write("DONEE\n");
    for(sram_i = 0; sram_i < 16; sram_i = sram_i + 1) begin
        if(w0_next_sram_256x4b.mem[sram_i] !== w0_next_gold[sram_i]) begin $write("FAIL at w0 next sram[%d]: %h vs gold: %h\n", sram_i, w0_next_sram_256x4b.mem[sram_i], w0_next_gold[sram_i]); end
        if(w1_next_sram_256x4b.mem[sram_i] !== w1_next_gold[sram_i]) begin $write("FAIL at w1 next sram[%d]: %h vs gold: %h\n", sram_i, w1_next_sram_256x4b.mem[sram_i], w1_next_gold[sram_i]); end
        if(w2_next_sram_256x4b.mem[sram_i] !== w2_next_gold[sram_i]) begin $write("FAIL at w2 next sram[%d]: %h vs gold: %h\n", sram_i, w2_next_sram_256x4b.mem[sram_i], w2_next_gold[sram_i]); end
        if(w3_next_sram_256x4b.mem[sram_i] !== w3_next_gold[sram_i]) begin $write("FAIL at w3 next sram[%d]: %h vs gold: %h\n", sram_i, w3_next_sram_256x4b.mem[sram_i], w3_next_gold[sram_i]); end
        if(w4_next_sram_256x4b.mem[sram_i] !== w4_next_gold[sram_i]) begin $write("FAIL at w4 next sram[%d]: %h vs gold: %h\n", sram_i, w4_next_sram_256x4b.mem[sram_i], w4_next_gold[sram_i]); end
        if(w5_next_sram_256x4b.mem[sram_i] !== w5_next_gold[sram_i]) begin $write("FAIL at w5 next sram[%d]: %h vs gold: %h\n", sram_i, w5_next_sram_256x4b.mem[sram_i], w5_next_gold[sram_i]); end
        if(w6_next_sram_256x4b.mem[sram_i] !== w6_next_gold[sram_i]) begin $write("FAIL at w6 next sram[%d]: %h vs gold: %h\n", sram_i, w6_next_sram_256x4b.mem[sram_i], w6_next_gold[sram_i]); end
        if(w7_next_sram_256x4b.mem[sram_i] !== w7_next_gold[sram_i]) begin $write("FAIL at w7 next sram[%d]: %h vs gold: %h\n", sram_i, w7_next_sram_256x4b.mem[sram_i], w7_next_gold[sram_i]); end
        if(w8_next_sram_256x4b.mem[sram_i] !== w8_next_gold[sram_i]) begin $write("FAIL at w8 next sram[%d]: %h vs gold: %h\n", sram_i, w8_next_sram_256x4b.mem[sram_i], w8_next_gold[sram_i]); end
        if(w9_next_sram_256x4b.mem[sram_i] !== w9_next_gold[sram_i]) begin $write("FAIL at w9 next sram[%d]: %h vs gold: %h\n", sram_i, w9_next_sram_256x4b.mem[sram_i], w9_next_gold[sram_i]); end
        if(w10_next_sram_256x4b.mem[sram_i] !== w10_next_gold[sram_i]) begin $write("FAIL at w10 next sram[%d]: %h vs gold: %h\n", sram_i, w10_next_sram_256x4b.mem[sram_i], w10_next_gold[sram_i]); end
        if(w11_next_sram_256x4b.mem[sram_i] !== w11_next_gold[sram_i]) begin $write("FAIL at w11 next sram[%d]: %h vs gold: %h\n", sram_i, w11_next_sram_256x4b.mem[sram_i], w11_next_gold[sram_i]); end
        if(w12_next_sram_256x4b.mem[sram_i] !== w12_next_gold[sram_i]) begin $write("FAIL at w12 next sram[%d]: %h vs gold: %h\n", sram_i, w12_next_sram_256x4b.mem[sram_i], w12_next_gold[sram_i]); end
        if(w13_next_sram_256x4b.mem[sram_i] !== w13_next_gold[sram_i]) begin $write("FAIL at w13 next sram[%d]: %h vs gold: %h\n", sram_i, w13_next_sram_256x4b.mem[sram_i], w13_next_gold[sram_i]); end
        if(w14_next_sram_256x4b.mem[sram_i] !== w14_next_gold[sram_i]) begin $write("FAIL at w14 next sram[%d]: %h vs gold: %h\n", sram_i, w14_next_sram_256x4b.mem[sram_i], w14_next_gold[sram_i]); end
        if(w15_next_sram_256x4b.mem[sram_i] !== w15_next_gold[sram_i]) begin $write("FAIL at w15 next sram[%d]: %h vs gold: %h\n", sram_i, w15_next_sram_256x4b.mem[sram_i], w15_next_gold[sram_i]); end

        if(w0_proposal_sram_16x128b.mem[sram_i] !== w0_pro_gold[sram_i]) begin $write("FAIL at w0 proposal sram[%d]: %h vs gold: %h\n", sram_i, w0_proposal_sram_16x128b.mem[sram_i], w0_pro_gold[sram_i]); end 
        if(w1_proposal_sram_16x128b.mem[sram_i] !== w1_pro_gold[sram_i]) begin $write("FAIL at w1 proposal sram[%d]: %h vs gold: %h\n", sram_i, w1_proposal_sram_16x128b.mem[sram_i], w1_pro_gold[sram_i]); end 
        if(w2_proposal_sram_16x128b.mem[sram_i] !== w2_pro_gold[sram_i]) begin $write("FAIL at w2 proposal sram[%d]: %h vs gold: %h\n", sram_i, w2_proposal_sram_16x128b.mem[sram_i], w2_pro_gold[sram_i]); end 
        if(w3_proposal_sram_16x128b.mem[sram_i] !== w3_pro_gold[sram_i]) begin $write("FAIL at w3 proposal sram[%d]: %h vs gold: %h\n", sram_i, w3_proposal_sram_16x128b.mem[sram_i], w3_pro_gold[sram_i]); end 
        if(w4_proposal_sram_16x128b.mem[sram_i] !== w4_pro_gold[sram_i]) begin $write("FAIL at w4 proposal sram[%d]: %h vs gold: %h\n", sram_i, w4_proposal_sram_16x128b.mem[sram_i], w4_pro_gold[sram_i]); end 
        if(w5_proposal_sram_16x128b.mem[sram_i] !== w5_pro_gold[sram_i]) begin $write("FAIL at w5 proposal sram[%d]: %h vs gold: %h\n", sram_i, w5_proposal_sram_16x128b.mem[sram_i], w5_pro_gold[sram_i]); end 
        if(w6_proposal_sram_16x128b.mem[sram_i] !== w6_pro_gold[sram_i]) begin $write("FAIL at w6 proposal sram[%d]: %h vs gold: %h\n", sram_i, w6_proposal_sram_16x128b.mem[sram_i], w6_pro_gold[sram_i]); end 
        if(w7_proposal_sram_16x128b.mem[sram_i] !== w7_pro_gold[sram_i]) begin $write("FAIL at w7 proposal sram[%d]: %h vs gold: %h\n", sram_i, w7_proposal_sram_16x128b.mem[sram_i], w7_pro_gold[sram_i]); end 
        if(w8_proposal_sram_16x128b.mem[sram_i] !== w8_pro_gold[sram_i]) begin $write("FAIL at w8 proposal sram[%d]: %h vs gold: %h\n", sram_i, w8_proposal_sram_16x128b.mem[sram_i], w8_pro_gold[sram_i]); end 
        if(w9_proposal_sram_16x128b.mem[sram_i] !== w9_pro_gold[sram_i]) begin $write("FAIL at w9 proposal sram[%d]: %h vs gold: %h\n", sram_i, w9_proposal_sram_16x128b.mem[sram_i], w9_pro_gold[sram_i]); end 
        if(w10_proposal_sram_16x128b.mem[sram_i] !== w10_pro_gold[sram_i]) begin $write("FAIL at w10 proposal sram[%d]: %h vs gold: %h\n", sram_i, w10_proposal_sram_16x128b.mem[sram_i], w10_pro_gold[sram_i]); end 
        if(w11_proposal_sram_16x128b.mem[sram_i] !== w11_pro_gold[sram_i]) begin $write("FAIL at w11 proposal sram[%d]: %h vs gold: %h\n", sram_i, w11_proposal_sram_16x128b.mem[sram_i], w11_pro_gold[sram_i]); end 
        if(w12_proposal_sram_16x128b.mem[sram_i] !== w12_pro_gold[sram_i]) begin $write("FAIL at w12 proposal sram[%d]: %h vs gold: %h\n", sram_i, w12_proposal_sram_16x128b.mem[sram_i], w12_pro_gold[sram_i]); end 
        if(w13_proposal_sram_16x128b.mem[sram_i] !== w13_pro_gold[sram_i]) begin $write("FAIL at w13 proposal sram[%d]: %h vs gold: %h\n", sram_i, w13_proposal_sram_16x128b.mem[sram_i], w13_pro_gold[sram_i]); end 
        if(w14_proposal_sram_16x128b.mem[sram_i] !== w14_pro_gold[sram_i]) begin $write("FAIL at w14 proposal sram[%d]: %h vs gold: %h\n", sram_i, w14_proposal_sram_16x128b.mem[sram_i], w14_pro_gold[sram_i]); end 
        if(w15_proposal_sram_16x128b.mem[sram_i] !== w15_pro_gold[sram_i]) begin $write("FAIL at w15 proposal sram[%d]: %h vs gold: %h\n", sram_i, w15_proposal_sram_16x128b.mem[sram_i], w15_pro_gold[sram_i]); end
       
    end 
    
    // for(srami = 0; srami < 16; srami = srami + 1) begin 
    //     if(w0_vid_sram_gold[srami] !== w0_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 0 at %d (%h vs gold %h) \n", srami, w0_vid_sram_gold[srami], w0_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w1_vid_sram_gold[srami] !== w1_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 1 at %d (%h vs gold %h) \n", srami, w1_vid_sram_gold[srami], w1_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w2_vid_sram_gold[srami] !== w2_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 2 at %d (%h vs gold %h) \n", srami, w2_vid_sram_gold[srami], w2_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w3_vid_sram_gold[srami] !== w3_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 3 at %d (%h vs gold %h) \n", srami, w3_vid_sram_gold[srami], w3_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w4_vid_sram_gold[srami] !== w4_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 4 at %d (%h vs gold %h) \n", srami, w4_vid_sram_gold[srami], w4_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w5_vid_sram_gold[srami] !== w5_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 5 at %d (%h vs gold %h) \n", srami, w5_vid_sram_gold[srami], w5_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w6_vid_sram_gold[srami] !== w6_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 6 at %d (%h vs gold %h) \n", srami, w6_vid_sram_gold[srami], w6_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w7_vid_sram_gold[srami] !== w7_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 7 at %d (%h vs gold %h) \n", srami, w7_vid_sram_gold[srami], w7_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w8_vid_sram_gold[srami] !== w8_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 8 at %d (%h vs gold %h) \n", srami, w8_vid_sram_gold[srami], w8_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w9_vid_sram_gold[srami] !== w9_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 9 at %d (%h vs gold %h) \n", srami, w9_vid_sram_gold[srami], w9_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w10_vid_sram_gold[srami] !== w10_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 10  at %d (%h vs gold %h)\n", srami, w10_vid_sram_gold[srami], w10_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w11_vid_sram_gold[srami] !== w11_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 11  at %d (%h vs gold %h)\n", srami, w11_vid_sram_gold[srami], w11_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w12_vid_sram_gold[srami] !== w12_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 12  at %d (%h vs gold %h)\n", srami, w12_vid_sram_gold[srami], w12_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w13_vid_sram_gold[srami] !== w13_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 13  at %d (%h vs gold %h)\n", srami, w13_vid_sram_gold[srami], w13_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w14_vid_sram_gold[srami] !== w14_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 14  at %d (%h vs gold %h)\n", srami, w14_vid_sram_gold[srami], w14_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     if(w15_vid_sram_gold[srami] !== w15_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]) begin  $write("FAIL vidsram 15  at %d (%h vs gold %h)\n", srami, w15_vid_sram_gold[srami], w15_vid_sram_16x256b.mem[(1-pingpong) * 16 + srami]); $finish; end 
    //     // $write("\n");
    // end 
    // $write("=========== locsram =============\n");
    // for(locsrami = 0; locsrami < 16; locsrami = locsrami + 1) begin 
    //     if(w0_loc_sram_16x256b.mem[locsrami] !== w0_loc_sram_gold[locsrami]) begin $write("FAIL locsram (%h vs gold %h)\n", w0_loc_sram_16x256b.mem[locsrami],w0_loc_sram_gold[locsrami]); $finish; end 
    //     if(w1_loc_sram_16x256b.mem[locsrami] !== w1_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w2_loc_sram_16x256b.mem[locsrami] !== w2_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w3_loc_sram_16x256b.mem[locsrami] !== w3_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w4_loc_sram_16x256b.mem[locsrami] !== w4_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w5_loc_sram_16x256b.mem[locsrami] !== w5_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w6_loc_sram_16x256b.mem[locsrami] !== w6_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w7_loc_sram_16x256b.mem[locsrami] !== w7_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w8_loc_sram_16x256b.mem[locsrami] !== w8_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w9_loc_sram_16x256b.mem[locsrami] !== w9_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w10_loc_sram_16x256b.mem[locsrami] !== w10_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w11_loc_sram_16x256b.mem[locsrami] !== w11_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w12_loc_sram_16x256b.mem[locsrami] !== w12_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w13_loc_sram_16x256b.mem[locsrami] !== w13_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w14_loc_sram_16x256b.mem[locsrami] !== w14_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end 
    //     if(w15_loc_sram_16x256b.mem[locsrami] !== w15_loc_sram_gold[locsrami]) begin $write("FAIL locsram\n"); $finish; end //else $write("good locsrma0 %h vs gold %h\n",w15_loc_sram_16x256b.mem[locsrami] , w15_loc_sram_gold[locsrami]);
    // end  
    // $write("\n");

    $finish;
end 
initial begin 
    #(CYCLE*10000);
    $finish;
end

endmodule

