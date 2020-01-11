module loc_sram_16x1280b #(
parameter ADDR_SPACE = 8, // 2^16 / 256 = 256
parameter BW = 5,
parameter D = 256
)
(
input clk,
input wsb,  //write enable
input [D-1:0] bytemask,  //16 bits
input [D*BW-1:0] wdata, //write data
input [ADDR_SPACE-1:0] waddr, //write address
input [ADDR_SPACE-1:0] raddr, //read address
output reg [D*BW-1:0] rdata //read data 36 bits
);
// TODO: after read , reset valid bit
// TODO: write only one element of D   
// vid = 0 at bytemask[255] ..... 
reg [D*BW-1:0] mem [0:15];
reg [D*BW-1:0] _rdata;
wire [D*BW-1:0] bit_mask;
assign bit_mask = {
{5{bytemask[255]}},{5{bytemask[254]}},{5{bytemask[253]}},{5{bytemask[252]}},{5{bytemask[251]}},{5{bytemask[250]}},{5{bytemask[249]}},{5{bytemask[248]}},{5{bytemask[247]}},{5{bytemask[246]}},{5{bytemask[245]}},{5{bytemask[244]}},{5{bytemask[243]}},{5{bytemask[242]}},{5{bytemask[241]}},{5{bytemask[240]}},
{5{bytemask[239]}},{5{bytemask[238]}},{5{bytemask[237]}},{5{bytemask[236]}},{5{bytemask[235]}},{5{bytemask[234]}},{5{bytemask[233]}},{5{bytemask[232]}},{5{bytemask[231]}},{5{bytemask[230]}},{5{bytemask[229]}},{5{bytemask[228]}},{5{bytemask[227]}},{5{bytemask[226]}},{5{bytemask[225]}},{5{bytemask[224]}},
{5{bytemask[223]}},{5{bytemask[222]}},{5{bytemask[221]}},{5{bytemask[220]}},{5{bytemask[219]}},{5{bytemask[218]}},{5{bytemask[217]}},{5{bytemask[216]}},{5{bytemask[215]}},{5{bytemask[214]}},{5{bytemask[213]}},{5{bytemask[212]}},{5{bytemask[211]}},{5{bytemask[210]}},{5{bytemask[209]}},{5{bytemask[208]}},
{5{bytemask[207]}},{5{bytemask[206]}},{5{bytemask[205]}},{5{bytemask[204]}},{5{bytemask[203]}},{5{bytemask[202]}},{5{bytemask[201]}},{5{bytemask[200]}},{5{bytemask[199]}},{5{bytemask[198]}},{5{bytemask[197]}},{5{bytemask[196]}},{5{bytemask[195]}},{5{bytemask[194]}},{5{bytemask[193]}},{5{bytemask[192]}},
{5{bytemask[191]}},{5{bytemask[190]}},{5{bytemask[189]}},{5{bytemask[188]}},{5{bytemask[187]}},{5{bytemask[186]}},{5{bytemask[185]}},{5{bytemask[184]}},{5{bytemask[183]}},{5{bytemask[182]}},{5{bytemask[181]}},{5{bytemask[180]}},{5{bytemask[179]}},{5{bytemask[178]}},{5{bytemask[177]}},{5{bytemask[176]}},
{5{bytemask[175]}},{5{bytemask[174]}},{5{bytemask[173]}},{5{bytemask[172]}},{5{bytemask[171]}},{5{bytemask[170]}},{5{bytemask[169]}},{5{bytemask[168]}},{5{bytemask[167]}},{5{bytemask[166]}},{5{bytemask[165]}},{5{bytemask[164]}},{5{bytemask[163]}},{5{bytemask[162]}},{5{bytemask[161]}},{5{bytemask[160]}},
{5{bytemask[159]}},{5{bytemask[158]}},{5{bytemask[157]}},{5{bytemask[156]}},{5{bytemask[155]}},{5{bytemask[154]}},{5{bytemask[153]}},{5{bytemask[152]}},{5{bytemask[151]}},{5{bytemask[150]}},{5{bytemask[149]}},{5{bytemask[148]}},{5{bytemask[147]}},{5{bytemask[146]}},{5{bytemask[145]}},{5{bytemask[144]}},
{5{bytemask[143]}},{5{bytemask[142]}},{5{bytemask[141]}},{5{bytemask[140]}},{5{bytemask[139]}},{5{bytemask[138]}},{5{bytemask[137]}},{5{bytemask[136]}},{5{bytemask[135]}},{5{bytemask[134]}},{5{bytemask[133]}},{5{bytemask[132]}},{5{bytemask[131]}},{5{bytemask[130]}},{5{bytemask[129]}},{5{bytemask[128]}},
{5{bytemask[127]}},{5{bytemask[126]}},{5{bytemask[125]}},{5{bytemask[124]}},{5{bytemask[123]}},{5{bytemask[122]}},{5{bytemask[121]}},{5{bytemask[120]}},{5{bytemask[119]}},{5{bytemask[118]}},{5{bytemask[117]}},{5{bytemask[116]}},{5{bytemask[115]}},{5{bytemask[114]}},{5{bytemask[113]}},{5{bytemask[112]}},
{5{bytemask[111]}},{5{bytemask[110]}},{5{bytemask[109]}},{5{bytemask[108]}},{5{bytemask[107]}},{5{bytemask[106]}},{5{bytemask[105]}},{5{bytemask[104]}},{5{bytemask[103]}},{5{bytemask[102]}},{5{bytemask[101]}},{5{bytemask[100]}},{5{bytemask[99]}},{5{bytemask[98]}},{5{bytemask[97]}},{5{bytemask[96]}},
{5{bytemask[95]}},{5{bytemask[94]}},{5{bytemask[93]}},{5{bytemask[92]}},{5{bytemask[91]}},{5{bytemask[90]}},{5{bytemask[89]}},{5{bytemask[88]}},{5{bytemask[87]}},{5{bytemask[86]}},{5{bytemask[85]}},{5{bytemask[84]}},{5{bytemask[83]}},{5{bytemask[82]}},{5{bytemask[81]}},{5{bytemask[80]}},
{5{bytemask[79]}},{5{bytemask[78]}},{5{bytemask[77]}},{5{bytemask[76]}},{5{bytemask[75]}},{5{bytemask[74]}},{5{bytemask[73]}},{5{bytemask[72]}},{5{bytemask[71]}},{5{bytemask[70]}},{5{bytemask[69]}},{5{bytemask[68]}},{5{bytemask[67]}},{5{bytemask[66]}},{5{bytemask[65]}},{5{bytemask[64]}},
{5{bytemask[63]}},{5{bytemask[62]}},{5{bytemask[61]}},{5{bytemask[60]}},{5{bytemask[59]}},{5{bytemask[58]}},{5{bytemask[57]}},{5{bytemask[56]}},{5{bytemask[55]}},{5{bytemask[54]}},{5{bytemask[53]}},{5{bytemask[52]}},{5{bytemask[51]}},{5{bytemask[50]}},{5{bytemask[49]}},{5{bytemask[48]}},
{5{bytemask[47]}},{5{bytemask[46]}},{5{bytemask[45]}},{5{bytemask[44]}},{5{bytemask[43]}},{5{bytemask[42]}},{5{bytemask[41]}},{5{bytemask[40]}},{5{bytemask[39]}},{5{bytemask[38]}},{5{bytemask[37]}},{5{bytemask[36]}},{5{bytemask[35]}},{5{bytemask[34]}},{5{bytemask[33]}},{5{bytemask[32]}},
{5{bytemask[31]}},{5{bytemask[30]}},{5{bytemask[29]}},{5{bytemask[28]}},{5{bytemask[27]}},{5{bytemask[26]}},{5{bytemask[25]}},{5{bytemask[24]}},{5{bytemask[23]}},{5{bytemask[22]}},{5{bytemask[21]}},{5{bytemask[20]}},{5{bytemask[19]}},{5{bytemask[18]}},{5{bytemask[17]}},{5{bytemask[16]}},
{5{bytemask[15]}},{5{bytemask[14]}},{5{bytemask[13]}},{5{bytemask[12]}},{5{bytemask[11]}},{5{bytemask[10]}},{5{bytemask[9]}},{5{bytemask[8]}},{5{bytemask[7]}},{5{bytemask[6]}},{5{bytemask[5]}},{5{bytemask[4]}},{5{bytemask[3]}},{5{bytemask[2]}},{5{bytemask[1]}},{5{bytemask[0]}}
};

always @(posedge clk) begin
    if(~wsb)
        mem[waddr] <= (wdata & ~(bit_mask)) | (mem[waddr] & bit_mask);
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