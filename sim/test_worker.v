`timescale 1ns/100ps
module test_worker;
localparam N = 4096;
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
localparam BATCH_BW = 8;
real CYCLE = 10;

//====== module I/O =====
reg clk;
reg rst_n;
reg enable; // 

reg [BATCH_BW-1:0] batch;
integer sub_bat;
integer i; 
integer flag;
// input 
wire [Q*VID_BW-1:0] vid_rdata;
wire [D*DIST_BW-1:0] dist_rdata;
wire [D*LOC_BW-1:0] loc_rdata;

// output 

// wire [NEXT_BW*Q-1:0] next_sram_wdata[0:K-1];
// wire [NEXT_ADDR_SPACE-1:0] next_sram_waddr[0:K-1];
// wire next_sram_wen[0:K-1];
// wire [Q-1:0] next_sram_bytemask[0:K-1];

// wire pro_sram_wen[0:K-1];
// wire [PRO_BW*Q-1:0] pro_sram_wdata[0:K-1];
// wire [PRO_ADDR_SPACE-1:0] pro_sram_waddr; // internal batch # 
// wire [Q-1:0] pro_sram_bytemask[0:K-1];


// =================== instance sram ================================
dist_sram_NxNb dist_sram0(
.clk(clk),
.wsb(1'b1),
.wdata(256'd0), 
.waddr(16'd0), 
// TODO
.raddr(dist_sram_raddr[0]), 
.rdata(dist_sram_rdata[0])
);

// worker worker_instn(
//     .clk(clk),
//     .en(enable),
//     .rst_n(rst_n),
//     .batch_num(batch),
//     .vid_rdata(vid_rdata),
//     .dist_rdata(dist_rdata),
//     .loc_rdata()
//     // output 

// );

// TEST worker 0 currently 
reg [3:0] locs [0:D-1];
// reg [Q*VID_BW-1:0] vid_sram0_rdata; // Q DIST_BW vids
// reg [D*DIST_BW-1:0] dist_sram0_rdata;
reg [D*LOC_BW-1:0] loc_rdata; // processed already

wire [Q*NEXT_BW-1:0] next_wdata;
wire [Q*PRO_BW-1:0] pro_wdata;
wire ready;         // test sub-tach part[k] 
wire batch_finish;  // test next & proposal 

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
reg [7:0] part_gold[0:255]; // 16(K) * total sub_bat number = 16 for first batch 
always #(CYCLE/2) clk = ~clk;

//// load test pattern //
// initial begin 

// end 
integer tmp;
initial begin 
    clk = 0;
    rst_n = 0;
    enable = 1'b0;
    $readmemh("vids.dat", vid_input);
    for(tmp = 0; tmp < 256; tmp = tmp + 1)
        $display("%d", vid_input[tmp]);
    // $readmemh("dist.dat", dist_input);
    // $readmemh("loc.dat", loc_input);
    // $readmemh("part.dat", part_gold);
    #(CYCLE) rst_n = 1;
    // input test pattern
    #(CYCLE) enable = 1'b1;
    
end 

localparam max_batch = 256;
localparam max_sub_bat = 16;
// TODO: check ".internal" params name  eg. line 118
initial begin 
    batch = 0;
    sub_bat = 0;
    while(batch < max_batch) begin
        @(negedge clk);
        flag = 1;
        if(ready) begin 
            // part[k] for a sub-batch finish
            $write("sub-batch %d :", sub_bat);
            for(i = 0; i < K; i = i + 1) begin 
                $write("%d ", worker_instn.part[i]);
                // if(worker_instn.part[i] != )
            end 
            $write("\n");
            sub_bat = sub_bat + 1;
        end 
        if(batch_finish) begin

            batch = batch + 1;
        end 
    end 
    $finish;
end 
initial begin 
    #(CYCLE*100000);
    $finish;
end 
endmodule;