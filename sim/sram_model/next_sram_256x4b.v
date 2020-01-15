// FOR next
module next_sram_256x4b #(    
parameter ADDR_SPACE = 4, // 256 / 16
parameter Q = 16,
parameter BW = 4
)
(
input clk,
input wsb,  //write enable """"ACTIVE LOW""""
input [BW*Q-1:0] wdata, //write data (master)
input [Q-1:0] bytemask, // """ACTIVE LOW"""
input [ADDR_SPACE-1:0] waddr, //write address
input [ADDR_SPACE-1:0] raddr, //read address
output reg [BW*Q-1:0] rdata 
);

reg [BW*Q-1:0] _rdata;
reg [BW*Q-1:0] mem [0:15]; // N / (K * Q)
wire [BW*Q-1:0] bit_mask;
assign bit_mask = { {4{bytemask[15]}},{4{bytemask[14]}},{4{bytemask[13]}},{4{bytemask[12]}},
{4{bytemask[11]}},{4{bytemask[10]}},{4{bytemask[9]}},{4{bytemask[8]}},{4{bytemask[7]}},{4{bytemask[6]}},{4{bytemask[5]}},{4{bytemask[4]}},{4{bytemask[3]}},{4{bytemask[2]}},{4{bytemask[1]}},{4{bytemask[0]}}};

always @(posedge clk) begin
    if(~wsb) begin
        mem[waddr] <= (wdata & ~(bit_mask)) | (mem[waddr] & bit_mask);
    end
end

always @(posedge clk) begin
    _rdata <= mem[raddr];
end

always @* begin
    rdata = #(1) _rdata;
end

task load_param(
    input integer index,
    input [BW*Q-1:0] param_input
);
    mem[index] = param_input;
endtask

endmodule