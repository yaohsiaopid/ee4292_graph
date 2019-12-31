module master_top #(
parameter Q = 16;
parameter RPO_BW = 8;
parameter  = ;
) (
input clk,
input rst_n,
input enable,
// inputs 
input pro_num // vertex' proposal number 

// outputs 
output [7:0] reg epoch,

);
// total epoch = N(4096) / Q(16)


endmodule