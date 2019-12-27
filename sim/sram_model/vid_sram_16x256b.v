// FOR Vid
module vid_sram_16x256b #(     
parameter ADDR_SPACE = 4, // batch number = N / (K * Q)
parameter Q = 16,
parameter VID_BW = 16
)
(
input clk,
input wsb,  //write enable """"ACTIVE LOW""""
input [VID_BW*Q-1:0] wdata, //write data (master)
input [ADDR_SPACE-1:0] waddr, //write address
input [ADDR_SPACE-1:0] raddr, //read address
output reg [VID_BW*Q-1:0] rdata //read data 128 bits
);

reg [VID_BW*Q-1:0] _rdata;
reg [VID_BW*Q-1:0] mem [0:15]; // N / (K * Q)

always @(posedge clk) begin
    if(~wsb) begin
        mem[waddr] <= wdata; // (wdata & ~(bit_mask)) | (mem[waddr] & bit_mask);
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
    input [VID_BW*Q-1:0] param_input
);
    mem[index] = param_input;
endtask

endmodule