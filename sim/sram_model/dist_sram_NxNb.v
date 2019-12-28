// FOR Dist bank 
module dist_sram_NxNb #( 
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
input [ADDR_SPACE-1:0] raddr, //read address
output reg [D*BW-1:0] rdata //read data 4 bits
);
reg [D*BW-1:0] mem [0:65536-1]; // 2 ^ 16
reg [D*BW-1:0] _rdata;

always @(posedge clk) begin
    if(~wsb)
        mem[waddr] <= wdata;
end

always @(posedge clk) begin
    _rdata <= mem[raddr];
end

always @* begin
    rdata = #(1) _rdata;
end

task load_param(
    input integer index,
    input [D*BW-1:0] param_input
);
    mem[index] = param_input;
endtask

endmodule