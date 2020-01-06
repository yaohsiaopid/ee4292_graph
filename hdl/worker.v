module worker
#(
    parameter K = 16,
    parameter D = 256,
    parameter DIST_BW = 1,
    parameter DIST_ADDR_SPACE = 16,
    parameter LOC_BW = 5,
    parameter LOC_ADDR_SPACE = 4,
    parameter NEXT_BW = 4,
    parameter NEXT_ADDR_SPACE = 4,
    parameter PRO_BW = 8,
    parameter PRO_ADDR_SPACE = 4,
    parameter VID_BW = 16,  // TODO: 12???
    parameter VID_ADDR_SPACE = 4,
    parameter Q = 16,
    parameter BATCH_BW = 8
)
(
    input clk,
    input en,
    input rst_n,
    input [BATCH_BW-1:0] batch_num,
    input [Q*VID_BW-1:0] vid_rdata,
    input [D*DIST_BW-1:0] dist_rdata,
    input [D*LOC_BW-1:0] loc_rdata,

    output reg [VID_BW-1:0] vid,
    output reg [Q*NEXT_BW-1:0] next_wdata,
    output reg [NEXT_ADDR_SPACE-1:0] next_waddr,
    output reg [Q*PRO_BW-1:0] pro_wdata,
    output reg [PRO_ADDR_SPACE-1:0] pro_waddr,
    output reg ready, //  if sub-batch is ready, test each cycle 
    output reg batch_finish // if a vertex is finish, test next & proposal # next cycle
);
reg [7:0] b [0:K-1] [0:K-1];
integer i, j;
always @* begin 
    for(i = 0; i < K; i = i + 1) begin
        for(j = 0; j < K; j = j + 1) begin  
            b[i][j] = i * j;
        end  
    end 
end 
// reg [VID_BW-1:0] vid [0:Q-1];
// reg [D-1:0] dist;
// reg [LOC_BW-2:0] loc [0:D-1];
// reg [K-1:0] dloc [0:D-1];
// reg [4:0] dsum [8*K-1:0];       // 256/32 = 8
// reg [7:0] part [K-1:0];
// reg next,

// integer i;

// always@(posedge clk) begin
//     if(~rst_n) begin
//         {vid[0], vid[1], vid[2], vid[3]} <= {16'd0, 16'd0, 16'd0, 16'd0};
//         {vid[4], vid[5], vid[6], vid[7]} <= {16'd0, 16'd0, 16'd0, 16'd0};
//         {vid[8], vid[9], vid[10], vid[11]} <= {16'd0, 16'd0, 16'd0, 16'd0};
//         {vid[12], vid[13], vid[14], vid[15]} <= {16'd0, 16'd0, 16'd0, 16'd0};
//         vid_raddr <= 0;

//         dist_raddr <= 0;
//         dist <= 256'd0;

//         loc_raddr <= 0;
//         loc_rdata???
//     end else begin
//         {vid[0], vid[1], vid[2], vid[3]} <= {vid_rdata[255:240], vid_rdata[239:224], vid_rdata[223:208], vid_rdata[207:192]};
//         {vid[4], vid[5], vid[6], vid[7]} <= {vid_rdata[191:176], vid_rdata[175:160], vid_rdata[159:144], vid_rdata[143:128]};
//         {vid[8], vid[9], vid[10], vid[11]} <= {vid_rdata[127:112], vid_rdata[111:96], vid_rdata[95:80], vid_rdata[79:64]};
//         {vid[12], vid[13], vid[14], vid[15]} <= {vid_rdata[63:48], vid_rdata[47:32], vid_rdata[31:16], vid_rdata[15:0]};
//         vid_raddr <= vid_raddr < 16 ? vid_raddr + 1 : 0;

//         dist_raddr <= {vid[num_subbatch], num_subbatch};    // vid + offset
//         dist <= dist_rdata;

//         loc_raddr <= num_subbatch;
//         loc_rdata???

//         n_dloc <= dloc???
//     end
// end

// always@* begin
//     // for one subatch for on vid
//     n_dloc = {k{dist[]}} & k_bit_onehot_loc;
//     n_dsum[i][0] = sum(dloc[0~31][i]);
//     part[k] = sum(dsum[k][0~7]);

//     // after N/D sub-batches, move to next vid, and do comparison at the same time (present vid)
//     n_next = max(part[0~K-1]); // and write out

    
// end

// // fsm ??
// always@(posedge clk) begin
//     if(~rst_n) begin

//     end else begin

//     end
// end

endmodule
