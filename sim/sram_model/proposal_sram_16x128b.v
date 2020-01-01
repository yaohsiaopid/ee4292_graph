// FOR proposal
module proposal_sram_16x128b #(    
parameter ADDR_SPACE = 4, // 256 / 16
parameter Q = 16,
parameter BW = 8
)
(
input clk,
input wsb,  //write enable """"ACTIVE LOW""""
input [BW*Q-1:0] wdata, //write data (master)
input [Q-1:0] bytemask, //
input [ADDR_SPACE-1:0] waddr, //write address
input [ADDR_SPACE-1:0] raddr, //read address
output reg [BW*Q-1:0] rdata 
);

reg [BW*Q-1:0] _rdata;
reg [BW*Q-1:0] mem [0:15]; // N / (K * Q)
wire [BW*Q-1:0] bit_mask;
assign bit_mask = { {8{bytemask[15]}},{8{bytemask[14]}},{8{bytemask[13]}},{8{bytemask[12]}},
{8{bytemask[11]}},{8{bytemask[10]}},{8{bytemask[9]}},{8{bytemask[8]}},{8{bytemask[7]}},{8{bytemask[6]}},{8{bytemask[5]}},{8{bytemask[4]}},{8{bytemask[3]}},{8{bytemask[2]}},{8{bytemask[1]}},{8{bytemask[0]}}};

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