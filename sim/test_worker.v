`timescale 1ns/100ps
module test_worker;

localparam K = 1;
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
localparam VID_ADDR_SPACE = 4;
localparam Q = 16;
localparam TOTAL_VID = 256; // N / K 
real CYCLE = 10;

//====== module I/O =====
reg clk;
reg rst_n;
reg enable; // 

// wire [DIST_BW*D -1:0] dist_sram_rdata[0:K-1];
// wire [DIST_ADDR_SPACE-1:0] dist_sram_raddr[0:K-1];

// wire [LOC_BW*D-1:0] loc_sram_rdata[0:Q-1];
// wire [LOC_ADDR_SPACE-1:0] loc_sram_raddr;

// wire pro_sram_wen[0:K-1];
// wire [PRO_BW*Q-1:0] pro_sram_wdata[0:K-1];
// wire [PRO_ADDR_SPACE-1:0] pro_sram_waddr; // internal batch # 
// wire [Q-1:0] pro_sram_bytemask[0:K-1];

// wire [VID_BW*Q-1:0] vid_sram_rdata[0:K-1];
// wire [VID_ADDR_SPACE-1:0] vid_sram_raddr;


// wire [NEXT_BW*Q-1:0] next_sram_wdata[0:K-1];
// wire [NEXT_ADDR_SPACE-1:0] next_sram_waddr[0:K-1];
// wire next_sram_wen[0:K-1];
// wire [Q-1:0] next_sram_bytemask[0:K-1];

// =================== instance sram ================================
dist_sram_NxNb dist_sram0(
.clk(clk),
.wsb(1'b1),
.wdata(256'd0), 
.waddr(16'd0), 
.raddr(dist_sram_raddr[0]), 
.rdata(dist_sram_rdata[0])
);

// TEST worker 0 currently 
reg [3:0] locs [0:D-1];
// reg [Q*VID_BW-1:0] vid_sram0_rdata; // Q DIST_BW vids
// reg [D*DIST_BW-1:0] dist_sram0_rdata;
reg [D*LOC_BW-1:0] loc_rdata; // processed already

wire [Q*NEXT_BW-1:0] next_wdata;
wire [Q*PRO_BW-1:0] pro_wdata;
wire ready;

// each worker is responsible for N/K = 4096 / 16 = 256 totaly for one round
// this module test only first round currently 
reg [NEXT_BW-1:0] next_gold[0:TOTAL_VID-1]; // 4 bit 
// TODO: extend to match the right place in next_wdata

reg [NEXT_BW-1:0] pro_gold[0:TOTAL_VID-1];
// TODO: extend to match the right place in pro_wdata

// TODO: take output of vid select for Dist


// input 
reg [VID_BW-1:0] vid_input[0:255]; // N/(K*Q) 
reg dist_input[0:N*N-1];
reg [LOC_BW-1:0] loc_input[0:N-1];

always #(CYCLE/2) clk = ~clk;

//// load test pattern //
initial begin 
    
end 
initial begin 
    clk = 0;
    rst_n = 0;
    enable = 1'b0;
    $readmemh("vids.dat", vid_input);
    $readmemh("dist.dat", dist_input);
    $readmemh("loc.dat", loc_input);
    #(cyc) rst_n = 1;
    // input test pattern

    
end 
integer batch;
integer max_batch = ; // 4096 / 
initial begin 
    batch = 0;
    while(batch < max_batch) begin 
    end 

end 
initial begin 
    #(CYCLE*100000);
    $finish;
end 
endmodule;