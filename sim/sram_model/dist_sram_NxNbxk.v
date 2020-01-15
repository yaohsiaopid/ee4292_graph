// FOR Dist bank 
module dist_sram_NxNbxk #( 
parameter N = 4096, // batch number = N / (K * Q)
parameter BW = 1,
parameter D = 256,
parameter ADDR_SPACE = 16 // log (4096 * 4096) / O_BW   
)
(
input clk,
input wsb,  //write enable
input [D*BW-1:0] wdata, //write data
input [ADDR_SPACE-1:0] waddr, //write address

input [ADDR_SPACE-1:0] raddr0,
input [ADDR_SPACE-1:0] raddr1,
input [ADDR_SPACE-1:0] raddr2,
input [ADDR_SPACE-1:0] raddr3,
input [ADDR_SPACE-1:0] raddr4,
input [ADDR_SPACE-1:0] raddr5,
input [ADDR_SPACE-1:0] raddr6,
input [ADDR_SPACE-1:0] raddr7,
input [ADDR_SPACE-1:0] raddr8,
input [ADDR_SPACE-1:0] raddr9,
input [ADDR_SPACE-1:0] raddr10,
input [ADDR_SPACE-1:0] raddr11,
input [ADDR_SPACE-1:0] raddr12,
input [ADDR_SPACE-1:0] raddr13,
input [ADDR_SPACE-1:0] raddr14,
input [ADDR_SPACE-1:0] raddr15,


output reg [D*BW-1:0] rdata0,
output reg [D*BW-1:0] rdata1,
output reg [D*BW-1:0] rdata2,
output reg [D*BW-1:0] rdata3,
output reg [D*BW-1:0] rdata4,
output reg [D*BW-1:0] rdata5,
output reg [D*BW-1:0] rdata6,
output reg [D*BW-1:0] rdata7,
output reg [D*BW-1:0] rdata8,
output reg [D*BW-1:0] rdata9,
output reg [D*BW-1:0] rdata10,
output reg [D*BW-1:0] rdata11,
output reg [D*BW-1:0] rdata12,
output reg [D*BW-1:0] rdata13,
output reg [D*BW-1:0] rdata14,
output reg [D*BW-1:0] rdata15
);
reg [D*BW-1:0] mem [0:65536-1]; // 2 ^ 16

reg [D*BW-1:0] _rdata0;
reg [D*BW-1:0] _rdata1;
reg [D*BW-1:0] _rdata2;
reg [D*BW-1:0] _rdata3;
reg [D*BW-1:0] _rdata4;
reg [D*BW-1:0] _rdata5;
reg [D*BW-1:0] _rdata6;
reg [D*BW-1:0] _rdata7;
reg [D*BW-1:0] _rdata8;
reg [D*BW-1:0] _rdata9;
reg [D*BW-1:0] _rdata10;
reg [D*BW-1:0] _rdata11;
reg [D*BW-1:0] _rdata12;
reg [D*BW-1:0] _rdata13;
reg [D*BW-1:0] _rdata14;
reg [D*BW-1:0] _rdata15;
always @(posedge clk) begin
    if(~wsb)
        mem[waddr] <= wdata;
end

always @(posedge clk) begin
    _rdata0 <= mem[raddr0];
    _rdata1 <= mem[raddr1];
    _rdata2 <= mem[raddr2];
    _rdata3 <= mem[raddr3];
    _rdata4 <= mem[raddr4];
    _rdata5 <= mem[raddr5];
    _rdata6 <= mem[raddr6];
    _rdata7 <= mem[raddr7];
    _rdata8 <= mem[raddr8];
    _rdata9 <= mem[raddr9];
    _rdata10 <= mem[raddr10];
    _rdata11 <= mem[raddr11];
    _rdata12 <= mem[raddr12];
    _rdata13 <= mem[raddr13];
    _rdata14 <= mem[raddr14];
    _rdata15 <= mem[raddr15]; 
end

always @* begin
    // rdata = #(1) _rdata;
    {rdata0 ,rdata1 ,rdata2 ,rdata3 ,rdata4 ,rdata5 ,rdata6 ,rdata7 ,rdata8 ,rdata9 ,rdata10,rdata11,rdata12,rdata13,rdata14,rdata15}
        = #(1) {_rdata0,_rdata1,_rdata2,_rdata3,_rdata4,_rdata5,_rdata6,_rdata7,_rdata8,_rdata9,_rdata10,_rdata11,_rdata12,_rdata13,_rdata14,_rdata15};
end

task load_param(
    input integer index,
    input [D*BW-1:0] param_input
);
    mem[index] = param_input;
endtask

endmodule