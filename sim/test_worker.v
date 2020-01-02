// `timescale 1ns/100ps
// TEST worker 0 currently for first iteration 
// to change worker go line 90
module test_worker;
localparam N = 4096;
localparam K = 16;
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
localparam TOTAL_VID = 256; // in one worker N / K 
localparam BATCH_BW = 8;
real CYCLE = 10;

//====== module I/O =====
reg clk;
reg rst_n;
reg enable;


integer sub_bat;
integer i; 
integer flag;
// input 
reg [BATCH_BW-1:0] batch;
reg [Q*VID_BW-1:0] vid_rdata;
reg [D*DIST_BW-1:0] dist_rdata;
reg [D*LOC_BW-1:0] loc_rdata;

// output 
wire [VID_BW-1:0] vid;
wire [Q*NEXT_BW-1:0] next_wdata;
wire [NEXT_ADDR_SPACE-1:0] next_waddr;
wire [Q*PRO_BW-1:0] pro_wdata;
wire [PRO_ADDR_SPACE-1:0] pro_waddr;
wire ready;         // test sub-tach part[k] 
wire batch_finish;  // test next & proposal         
// assign vid = 10; // for testing testbench ==
// =================== instance sram ================================
// TODO: connect the wire and modify IO above and here 
worker worker_instn(
    .clk(clk),
    .en(enable),
    .rst_n(rst_n),
    .batch_num(batch),
    .vid_rdata(vid_rdata),
    .dist_rdata(dist_rdata),
    .loc_rdata(loc_rdata),
    // output 
    .vid(vid), // for indexing the Dist
    .next_wdata(next_wdata),
    .next_waddr(next_waddr),
    .pro_wdata(pro_wdata),
    .pro_waddr(pro_waddr),
    .ready(ready),
    .batch_finish(batch_finish)
);

// each worker is responsible for N/K = 4096 / 16 = 256 totaly for one round
// this module test only first round currently 
reg [NEXT_BW-1:0] next_gold[0:TOTAL_VID-1]; // 4 bit 
// TODO: extend to match the right place in next_wdata
reg [PRO_BW-1:0] pro_gold[0:TOTAL_VID-1]; // proposal number 
// TODO: extend to match the right place in pro_wdata

// TODO: take output of vid select for Dist

// input 
reg [VID_BW-1:0] vid_input[0:255]; // N/(K*Q) 
// reg [D-1:0] dist_input[0:65535];
reg [N-1:0] dist_input[0:N-1];
reg [LOC_BW-1:0] loc_input[0:N-1];
reg [PRO_BW*K-1:0] part_gold[0:15]; // 16(K) , total sub_bat number = 16 for first batch 
always #(CYCLE/2) clk = ~clk;

//// load test pattern //
// initial begin 

// end 
integer tmp;
reg [N-1:0] tmpdist;
initial begin 
    clk = 0;
    rst_n = 0;
    enable = 1'b0;
    $readmemh("../software/gold/0_vid.dat", vid_input);
    $readmemh("../software/gold/dist.dat", dist_input); 
    // $write("%b\n", dist_input[4095]);
    // for(tmp = 0; tmp < 256; tmp = tmp + 1)
    //     $write("%d;",vid_input[tmp]);
    $readmemh("../software/gold/loc.dat", loc_input);
    $write("loc %h\n", loc_input[4095]);
    $readmemh("../software/gold/0_bat0_part.dat", part_gold); // only batch number 0's 16 sub-batch's part[0-K] 
    $write("part %h\n", part_gold[15]);
    $readmemh("../software/gold/0_next.dat", next_gold);
    $write("next 24 %d\n", next_gold[24]);
    $readmemh("../software/gold/0_proposal_num.dat", pro_gold);
    $write("proposal_num 30 %d\n", pro_gold[30]);
    // $readmemh/
    #(CYCLE) rst_n = 1; 
    // input test pattern
    batch = 0;
    vid_rdata = {vid_input[Q*batch+0],vid_input[Q*batch+1],vid_input[Q*batch+2],vid_input[Q*batch+3],vid_input[Q*batch+4],vid_input[Q*batch+5],vid_input[Q*batch+6],vid_input[Q*batch+7],vid_input[Q*batch+8],vid_input[Q*batch+9],vid_input[Q*batch+10],vid_input[Q*batch+11],vid_input[Q*batch+12],vid_input[Q*batch+13],vid_input[Q*batch+14],vid_input[Q*batch+15]};
    sub_bat = 0;
    loc_rdata = {loc_input[D*sub_bat+0],loc_input[D*sub_bat+1],loc_input[D*sub_bat+2],loc_input[D*sub_bat+3],loc_input[D*sub_bat+4],loc_input[D*sub_bat+5],loc_input[D*sub_bat+6],loc_input[D*sub_bat+7],loc_input[D*sub_bat+8],loc_input[D*sub_bat+9],loc_input[D*sub_bat+10],loc_input[D*sub_bat+11],loc_input[D*sub_bat+12],loc_input[D*sub_bat+13],loc_input[D*sub_bat+14],loc_input[D*sub_bat+15],loc_input[D*sub_bat+16],loc_input[D*sub_bat+17],loc_input[D*sub_bat+18],loc_input[D*sub_bat+19],loc_input[D*sub_bat+20],loc_input[D*sub_bat+21],loc_input[D*sub_bat+22],loc_input[D*sub_bat+23],loc_input[D*sub_bat+24],loc_input[D*sub_bat+25],loc_input[D*sub_bat+26],loc_input[D*sub_bat+27],loc_input[D*sub_bat+28],loc_input[D*sub_bat+29],loc_input[D*sub_bat+30],loc_input[D*sub_bat+31],loc_input[D*sub_bat+32],loc_input[D*sub_bat+33],loc_input[D*sub_bat+34],loc_input[D*sub_bat+35],loc_input[D*sub_bat+36],loc_input[D*sub_bat+37],loc_input[D*sub_bat+38],loc_input[D*sub_bat+39],loc_input[D*sub_bat+40],loc_input[D*sub_bat+41],loc_input[D*sub_bat+42],loc_input[D*sub_bat+43],loc_input[D*sub_bat+44],loc_input[D*sub_bat+45],loc_input[D*sub_bat+46],loc_input[D*sub_bat+47],loc_input[D*sub_bat+48],loc_input[D*sub_bat+49],loc_input[D*sub_bat+50],loc_input[D*sub_bat+51],loc_input[D*sub_bat+52],loc_input[D*sub_bat+53],loc_input[D*sub_bat+54],loc_input[D*sub_bat+55],loc_input[D*sub_bat+56],loc_input[D*sub_bat+57],loc_input[D*sub_bat+58],loc_input[D*sub_bat+59],loc_input[D*sub_bat+60],loc_input[D*sub_bat+61],loc_input[D*sub_bat+62],loc_input[D*sub_bat+63],loc_input[D*sub_bat+64],loc_input[D*sub_bat+65],loc_input[D*sub_bat+66],loc_input[D*sub_bat+67],loc_input[D*sub_bat+68],loc_input[D*sub_bat+69],loc_input[D*sub_bat+70],loc_input[D*sub_bat+71],loc_input[D*sub_bat+72],loc_input[D*sub_bat+73],loc_input[D*sub_bat+74],loc_input[D*sub_bat+75],loc_input[D*sub_bat+76],loc_input[D*sub_bat+77],loc_input[D*sub_bat+78],loc_input[D*sub_bat+79],loc_input[D*sub_bat+80],loc_input[D*sub_bat+81],loc_input[D*sub_bat+82],loc_input[D*sub_bat+83],loc_input[D*sub_bat+84],loc_input[D*sub_bat+85],loc_input[D*sub_bat+86],loc_input[D*sub_bat+87],loc_input[D*sub_bat+88],loc_input[D*sub_bat+89],loc_input[D*sub_bat+90],loc_input[D*sub_bat+91],loc_input[D*sub_bat+92],loc_input[D*sub_bat+93],loc_input[D*sub_bat+94],loc_input[D*sub_bat+95],loc_input[D*sub_bat+96],loc_input[D*sub_bat+97],loc_input[D*sub_bat+98],loc_input[D*sub_bat+99],loc_input[D*sub_bat+100],loc_input[D*sub_bat+101],loc_input[D*sub_bat+102],loc_input[D*sub_bat+103],loc_input[D*sub_bat+104],loc_input[D*sub_bat+105],loc_input[D*sub_bat+106],loc_input[D*sub_bat+107],loc_input[D*sub_bat+108],loc_input[D*sub_bat+109],loc_input[D*sub_bat+110],loc_input[D*sub_bat+111],loc_input[D*sub_bat+112],loc_input[D*sub_bat+113],loc_input[D*sub_bat+114],loc_input[D*sub_bat+115],loc_input[D*sub_bat+116],loc_input[D*sub_bat+117],loc_input[D*sub_bat+118],loc_input[D*sub_bat+119],loc_input[D*sub_bat+120],loc_input[D*sub_bat+121],loc_input[D*sub_bat+122],loc_input[D*sub_bat+123],loc_input[D*sub_bat+124],loc_input[D*sub_bat+125],loc_input[D*sub_bat+126],loc_input[D*sub_bat+127],loc_input[D*sub_bat+128],loc_input[D*sub_bat+129],loc_input[D*sub_bat+130],loc_input[D*sub_bat+131],loc_input[D*sub_bat+132],loc_input[D*sub_bat+133],loc_input[D*sub_bat+134],loc_input[D*sub_bat+135],loc_input[D*sub_bat+136],loc_input[D*sub_bat+137],loc_input[D*sub_bat+138],loc_input[D*sub_bat+139],loc_input[D*sub_bat+140],loc_input[D*sub_bat+141],loc_input[D*sub_bat+142],loc_input[D*sub_bat+143],loc_input[D*sub_bat+144],loc_input[D*sub_bat+145],loc_input[D*sub_bat+146],loc_input[D*sub_bat+147],loc_input[D*sub_bat+148],loc_input[D*sub_bat+149],loc_input[D*sub_bat+150],loc_input[D*sub_bat+151],loc_input[D*sub_bat+152],loc_input[D*sub_bat+153],loc_input[D*sub_bat+154],loc_input[D*sub_bat+155],loc_input[D*sub_bat+156],loc_input[D*sub_bat+157],loc_input[D*sub_bat+158],loc_input[D*sub_bat+159],loc_input[D*sub_bat+160],loc_input[D*sub_bat+161],loc_input[D*sub_bat+162],loc_input[D*sub_bat+163],loc_input[D*sub_bat+164],loc_input[D*sub_bat+165],loc_input[D*sub_bat+166],loc_input[D*sub_bat+167],loc_input[D*sub_bat+168],loc_input[D*sub_bat+169],loc_input[D*sub_bat+170],loc_input[D*sub_bat+171],loc_input[D*sub_bat+172],loc_input[D*sub_bat+173],loc_input[D*sub_bat+174],loc_input[D*sub_bat+175],loc_input[D*sub_bat+176],loc_input[D*sub_bat+177],loc_input[D*sub_bat+178],loc_input[D*sub_bat+179],loc_input[D*sub_bat+180],loc_input[D*sub_bat+181],loc_input[D*sub_bat+182],loc_input[D*sub_bat+183],loc_input[D*sub_bat+184],loc_input[D*sub_bat+185],loc_input[D*sub_bat+186],loc_input[D*sub_bat+187],loc_input[D*sub_bat+188],loc_input[D*sub_bat+189],loc_input[D*sub_bat+190],loc_input[D*sub_bat+191],loc_input[D*sub_bat+192],loc_input[D*sub_bat+193],loc_input[D*sub_bat+194],loc_input[D*sub_bat+195],loc_input[D*sub_bat+196],loc_input[D*sub_bat+197],loc_input[D*sub_bat+198],loc_input[D*sub_bat+199],loc_input[D*sub_bat+200],loc_input[D*sub_bat+201],loc_input[D*sub_bat+202],loc_input[D*sub_bat+203],loc_input[D*sub_bat+204],loc_input[D*sub_bat+205],loc_input[D*sub_bat+206],loc_input[D*sub_bat+207],loc_input[D*sub_bat+208],loc_input[D*sub_bat+209],loc_input[D*sub_bat+210],loc_input[D*sub_bat+211],loc_input[D*sub_bat+212],loc_input[D*sub_bat+213],loc_input[D*sub_bat+214],loc_input[D*sub_bat+215],loc_input[D*sub_bat+216],loc_input[D*sub_bat+217],loc_input[D*sub_bat+218],loc_input[D*sub_bat+219],loc_input[D*sub_bat+220],loc_input[D*sub_bat+221],loc_input[D*sub_bat+222],loc_input[D*sub_bat+223],loc_input[D*sub_bat+224],loc_input[D*sub_bat+225],loc_input[D*sub_bat+226],loc_input[D*sub_bat+227],loc_input[D*sub_bat+228],loc_input[D*sub_bat+229],loc_input[D*sub_bat+230],loc_input[D*sub_bat+231],loc_input[D*sub_bat+232],loc_input[D*sub_bat+233],loc_input[D*sub_bat+234],loc_input[D*sub_bat+235],loc_input[D*sub_bat+236],loc_input[D*sub_bat+237],loc_input[D*sub_bat+238],loc_input[D*sub_bat+239],loc_input[D*sub_bat+240],loc_input[D*sub_bat+241],loc_input[D*sub_bat+242],loc_input[D*sub_bat+243],loc_input[D*sub_bat+244],loc_input[D*sub_bat+245],loc_input[D*sub_bat+246],loc_input[D*sub_bat+247],loc_input[D*sub_bat+248],loc_input[D*sub_bat+249],loc_input[D*sub_bat+250],loc_input[D*sub_bat+251],loc_input[D*sub_bat+252],loc_input[D*sub_bat+253],loc_input[D*sub_bat+254],loc_input[D*sub_bat+255]};
    tmpdist = dist_input[vid]; // 0 at MSB
    dist_rdata = { tmpdist[N-1-(D*sub_bat+0)], tmpdist[N-1-(D*sub_bat+1)], tmpdist[N-1-(D*sub_bat+2)], tmpdist[N-1-(D*sub_bat+3)], tmpdist[N-1-(D*sub_bat+4)], tmpdist[N-1-(D*sub_bat+5)], tmpdist[N-1-(D*sub_bat+6)], tmpdist[N-1-(D*sub_bat+7)], tmpdist[N-1-(D*sub_bat+8)], tmpdist[N-1-(D*sub_bat+9)], tmpdist[N-1-(D*sub_bat+10)], tmpdist[N-1-(D*sub_bat+11)], tmpdist[N-1-(D*sub_bat+12)], tmpdist[N-1-(D*sub_bat+13)], tmpdist[N-1-(D*sub_bat+14)], tmpdist[N-1-(D*sub_bat+15)], tmpdist[N-1-(D*sub_bat+16)], tmpdist[N-1-(D*sub_bat+17)], tmpdist[N-1-(D*sub_bat+18)], tmpdist[N-1-(D*sub_bat+19)], tmpdist[N-1-(D*sub_bat+20)], tmpdist[N-1-(D*sub_bat+21)], tmpdist[N-1-(D*sub_bat+22)], tmpdist[N-1-(D*sub_bat+23)], tmpdist[N-1-(D*sub_bat+24)], tmpdist[N-1-(D*sub_bat+25)], tmpdist[N-1-(D*sub_bat+26)], tmpdist[N-1-(D*sub_bat+27)], tmpdist[N-1-(D*sub_bat+28)], tmpdist[N-1-(D*sub_bat+29)], tmpdist[N-1-(D*sub_bat+30)], tmpdist[N-1-(D*sub_bat+31)], tmpdist[N-1-(D*sub_bat+32)], tmpdist[N-1-(D*sub_bat+33)], tmpdist[N-1-(D*sub_bat+34)], tmpdist[N-1-(D*sub_bat+35)], tmpdist[N-1-(D*sub_bat+36)], tmpdist[N-1-(D*sub_bat+37)], tmpdist[N-1-(D*sub_bat+38)], tmpdist[N-1-(D*sub_bat+39)], tmpdist[N-1-(D*sub_bat+40)], tmpdist[N-1-(D*sub_bat+41)], tmpdist[N-1-(D*sub_bat+42)], tmpdist[N-1-(D*sub_bat+43)], tmpdist[N-1-(D*sub_bat+44)], tmpdist[N-1-(D*sub_bat+45)], tmpdist[N-1-(D*sub_bat+46)], tmpdist[N-1-(D*sub_bat+47)], tmpdist[N-1-(D*sub_bat+48)], tmpdist[N-1-(D*sub_bat+49)], tmpdist[N-1-(D*sub_bat+50)], tmpdist[N-1-(D*sub_bat+51)], tmpdist[N-1-(D*sub_bat+52)], tmpdist[N-1-(D*sub_bat+53)], tmpdist[N-1-(D*sub_bat+54)], tmpdist[N-1-(D*sub_bat+55)], tmpdist[N-1-(D*sub_bat+56)], tmpdist[N-1-(D*sub_bat+57)], tmpdist[N-1-(D*sub_bat+58)], tmpdist[N-1-(D*sub_bat+59)], tmpdist[N-1-(D*sub_bat+60)], tmpdist[N-1-(D*sub_bat+61)], tmpdist[N-1-(D*sub_bat+62)], tmpdist[N-1-(D*sub_bat+63)], tmpdist[N-1-(D*sub_bat+64)], tmpdist[N-1-(D*sub_bat+65)], tmpdist[N-1-(D*sub_bat+66)], tmpdist[N-1-(D*sub_bat+67)], tmpdist[N-1-(D*sub_bat+68)], tmpdist[N-1-(D*sub_bat+69)], tmpdist[N-1-(D*sub_bat+70)], tmpdist[N-1-(D*sub_bat+71)], tmpdist[N-1-(D*sub_bat+72)], tmpdist[N-1-(D*sub_bat+73)], tmpdist[N-1-(D*sub_bat+74)], tmpdist[N-1-(D*sub_bat+75)], tmpdist[N-1-(D*sub_bat+76)], tmpdist[N-1-(D*sub_bat+77)], tmpdist[N-1-(D*sub_bat+78)], tmpdist[N-1-(D*sub_bat+79)], tmpdist[N-1-(D*sub_bat+80)], tmpdist[N-1-(D*sub_bat+81)], tmpdist[N-1-(D*sub_bat+82)], tmpdist[N-1-(D*sub_bat+83)], tmpdist[N-1-(D*sub_bat+84)], tmpdist[N-1-(D*sub_bat+85)], tmpdist[N-1-(D*sub_bat+86)], tmpdist[N-1-(D*sub_bat+87)], tmpdist[N-1-(D*sub_bat+88)], tmpdist[N-1-(D*sub_bat+89)], tmpdist[N-1-(D*sub_bat+90)], tmpdist[N-1-(D*sub_bat+91)], tmpdist[N-1-(D*sub_bat+92)], tmpdist[N-1-(D*sub_bat+93)], tmpdist[N-1-(D*sub_bat+94)], tmpdist[N-1-(D*sub_bat+95)], tmpdist[N-1-(D*sub_bat+96)], tmpdist[N-1-(D*sub_bat+97)], tmpdist[N-1-(D*sub_bat+98)], tmpdist[N-1-(D*sub_bat+99)], tmpdist[N-1-(D*sub_bat+100)], tmpdist[N-1-(D*sub_bat+101)], tmpdist[N-1-(D*sub_bat+102)], tmpdist[N-1-(D*sub_bat+103)], tmpdist[N-1-(D*sub_bat+104)], tmpdist[N-1-(D*sub_bat+105)], tmpdist[N-1-(D*sub_bat+106)], tmpdist[N-1-(D*sub_bat+107)], tmpdist[N-1-(D*sub_bat+108)], tmpdist[N-1-(D*sub_bat+109)], tmpdist[N-1-(D*sub_bat+110)], tmpdist[N-1-(D*sub_bat+111)], tmpdist[N-1-(D*sub_bat+112)], tmpdist[N-1-(D*sub_bat+113)], tmpdist[N-1-(D*sub_bat+114)], tmpdist[N-1-(D*sub_bat+115)], tmpdist[N-1-(D*sub_bat+116)], tmpdist[N-1-(D*sub_bat+117)], tmpdist[N-1-(D*sub_bat+118)], tmpdist[N-1-(D*sub_bat+119)], tmpdist[N-1-(D*sub_bat+120)], tmpdist[N-1-(D*sub_bat+121)], tmpdist[N-1-(D*sub_bat+122)], tmpdist[N-1-(D*sub_bat+123)], tmpdist[N-1-(D*sub_bat+124)], tmpdist[N-1-(D*sub_bat+125)], tmpdist[N-1-(D*sub_bat+126)], tmpdist[N-1-(D*sub_bat+127)], tmpdist[N-1-(D*sub_bat+128)], tmpdist[N-1-(D*sub_bat+129)], tmpdist[N-1-(D*sub_bat+130)], tmpdist[N-1-(D*sub_bat+131)], tmpdist[N-1-(D*sub_bat+132)], tmpdist[N-1-(D*sub_bat+133)], tmpdist[N-1-(D*sub_bat+134)], tmpdist[N-1-(D*sub_bat+135)], tmpdist[N-1-(D*sub_bat+136)], tmpdist[N-1-(D*sub_bat+137)], tmpdist[N-1-(D*sub_bat+138)], tmpdist[N-1-(D*sub_bat+139)], tmpdist[N-1-(D*sub_bat+140)], tmpdist[N-1-(D*sub_bat+141)], tmpdist[N-1-(D*sub_bat+142)], tmpdist[N-1-(D*sub_bat+143)], tmpdist[N-1-(D*sub_bat+144)], tmpdist[N-1-(D*sub_bat+145)], tmpdist[N-1-(D*sub_bat+146)], tmpdist[N-1-(D*sub_bat+147)], tmpdist[N-1-(D*sub_bat+148)], tmpdist[N-1-(D*sub_bat+149)], tmpdist[N-1-(D*sub_bat+150)], tmpdist[N-1-(D*sub_bat+151)], tmpdist[N-1-(D*sub_bat+152)], tmpdist[N-1-(D*sub_bat+153)], tmpdist[N-1-(D*sub_bat+154)], tmpdist[N-1-(D*sub_bat+155)], tmpdist[N-1-(D*sub_bat+156)], tmpdist[N-1-(D*sub_bat+157)], tmpdist[N-1-(D*sub_bat+158)], tmpdist[N-1-(D*sub_bat+159)], tmpdist[N-1-(D*sub_bat+160)], tmpdist[N-1-(D*sub_bat+161)], tmpdist[N-1-(D*sub_bat+162)], tmpdist[N-1-(D*sub_bat+163)], tmpdist[N-1-(D*sub_bat+164)], tmpdist[N-1-(D*sub_bat+165)], tmpdist[N-1-(D*sub_bat+166)], tmpdist[N-1-(D*sub_bat+167)], tmpdist[N-1-(D*sub_bat+168)], tmpdist[N-1-(D*sub_bat+169)], tmpdist[N-1-(D*sub_bat+170)], tmpdist[N-1-(D*sub_bat+171)], tmpdist[N-1-(D*sub_bat+172)], tmpdist[N-1-(D*sub_bat+173)], tmpdist[N-1-(D*sub_bat+174)], tmpdist[N-1-(D*sub_bat+175)], tmpdist[N-1-(D*sub_bat+176)], tmpdist[N-1-(D*sub_bat+177)], tmpdist[N-1-(D*sub_bat+178)], tmpdist[N-1-(D*sub_bat+179)], tmpdist[N-1-(D*sub_bat+180)], tmpdist[N-1-(D*sub_bat+181)], tmpdist[N-1-(D*sub_bat+182)], tmpdist[N-1-(D*sub_bat+183)], tmpdist[N-1-(D*sub_bat+184)], tmpdist[N-1-(D*sub_bat+185)], tmpdist[N-1-(D*sub_bat+186)], tmpdist[N-1-(D*sub_bat+187)], tmpdist[N-1-(D*sub_bat+188)], tmpdist[N-1-(D*sub_bat+189)], tmpdist[N-1-(D*sub_bat+190)], tmpdist[N-1-(D*sub_bat+191)], tmpdist[N-1-(D*sub_bat+192)], tmpdist[N-1-(D*sub_bat+193)], tmpdist[N-1-(D*sub_bat+194)], tmpdist[N-1-(D*sub_bat+195)], tmpdist[N-1-(D*sub_bat+196)], tmpdist[N-1-(D*sub_bat+197)], tmpdist[N-1-(D*sub_bat+198)], tmpdist[N-1-(D*sub_bat+199)], tmpdist[N-1-(D*sub_bat+200)], tmpdist[N-1-(D*sub_bat+201)], tmpdist[N-1-(D*sub_bat+202)], tmpdist[N-1-(D*sub_bat+203)], tmpdist[N-1-(D*sub_bat+204)], tmpdist[N-1-(D*sub_bat+205)], tmpdist[N-1-(D*sub_bat+206)], tmpdist[N-1-(D*sub_bat+207)], tmpdist[N-1-(D*sub_bat+208)], tmpdist[N-1-(D*sub_bat+209)], tmpdist[N-1-(D*sub_bat+210)], tmpdist[N-1-(D*sub_bat+211)], tmpdist[N-1-(D*sub_bat+212)], tmpdist[N-1-(D*sub_bat+213)], tmpdist[N-1-(D*sub_bat+214)], tmpdist[N-1-(D*sub_bat+215)], tmpdist[N-1-(D*sub_bat+216)], tmpdist[N-1-(D*sub_bat+217)], tmpdist[N-1-(D*sub_bat+218)], tmpdist[N-1-(D*sub_bat+219)], tmpdist[N-1-(D*sub_bat+220)], tmpdist[N-1-(D*sub_bat+221)], tmpdist[N-1-(D*sub_bat+222)], tmpdist[N-1-(D*sub_bat+223)], tmpdist[N-1-(D*sub_bat+224)], tmpdist[N-1-(D*sub_bat+225)], tmpdist[N-1-(D*sub_bat+226)], tmpdist[N-1-(D*sub_bat+227)], tmpdist[N-1-(D*sub_bat+228)], tmpdist[N-1-(D*sub_bat+229)], tmpdist[N-1-(D*sub_bat+230)], tmpdist[N-1-(D*sub_bat+231)], tmpdist[N-1-(D*sub_bat+232)], tmpdist[N-1-(D*sub_bat+233)], tmpdist[N-1-(D*sub_bat+234)], tmpdist[N-1-(D*sub_bat+235)], tmpdist[N-1-(D*sub_bat+236)], tmpdist[N-1-(D*sub_bat+237)], tmpdist[N-1-(D*sub_bat+238)], tmpdist[N-1-(D*sub_bat+239)], tmpdist[N-1-(D*sub_bat+240)], tmpdist[N-1-(D*sub_bat+241)], tmpdist[N-1-(D*sub_bat+242)], tmpdist[N-1-(D*sub_bat+243)], tmpdist[N-1-(D*sub_bat+244)], tmpdist[N-1-(D*sub_bat+245)], tmpdist[N-1-(D*sub_bat+246)], tmpdist[N-1-(D*sub_bat+247)], tmpdist[N-1-(D*sub_bat+248)], tmpdist[N-1-(D*sub_bat+249)], tmpdist[N-1-(D*sub_bat+250)], tmpdist[N-1-(D*sub_bat+251)], tmpdist[N-1-(D*sub_bat+252)], tmpdist[N-1-(D*sub_bat+253)], tmpdist[N-1-(D*sub_bat+254)], tmpdist[N-1-(D*sub_bat+255)]};
    $write("vid_sram: %h\n", vid_rdata);
    $write("index_vid: %d dist: %b , tmpdist : %h \n", vid, dist_rdata, tmpdist);
    $write("loc: %h\n", loc_rdata);
    #(CYCLE) enable = 1'b1;
    
    $finish;
end 

localparam max_batch = 256;
localparam max_sub_bat = 16;
// TODO: check ".internal" params name  eg. line 118
integer check_sub;
integer check_batch;
initial begin 
    check_sub = 0;
    check_batch = 0;
    wait(enable == 1);
    #(CYCLE);
    while(batch < max_batch) begin
        @(negedge clk);
        sub_bat = sub_bat + 1;
        if(sub_bat == max_sub_bat)begin 
            batch = batch + 1;
            // ** if bacth == max_batch , the later data is non-sense
            sub_bat = 0;
        end 
        vid_rdata = {vid_input[Q*batch+0],vid_input[Q*batch+1],vid_input[Q*batch+2],vid_input[Q*batch+3],vid_input[Q*batch+4],vid_input[Q*batch+5],vid_input[Q*batch+6],vid_input[Q*batch+7],vid_input[Q*batch+8],vid_input[Q*batch+9],vid_input[Q*batch+10],vid_input[Q*batch+11],vid_input[Q*batch+12],vid_input[Q*batch+13],vid_input[Q*batch+14],vid_input[Q*batch+15]};
        loc_rdata = {loc_input[D*sub_bat+0],loc_input[D*sub_bat+1],loc_input[D*sub_bat+2],loc_input[D*sub_bat+3],loc_input[D*sub_bat+4],loc_input[D*sub_bat+5],loc_input[D*sub_bat+6],loc_input[D*sub_bat+7],loc_input[D*sub_bat+8],loc_input[D*sub_bat+9],loc_input[D*sub_bat+10],loc_input[D*sub_bat+11],loc_input[D*sub_bat+12],loc_input[D*sub_bat+13],loc_input[D*sub_bat+14],loc_input[D*sub_bat+15],loc_input[D*sub_bat+16],loc_input[D*sub_bat+17],loc_input[D*sub_bat+18],loc_input[D*sub_bat+19],loc_input[D*sub_bat+20],loc_input[D*sub_bat+21],loc_input[D*sub_bat+22],loc_input[D*sub_bat+23],loc_input[D*sub_bat+24],loc_input[D*sub_bat+25],loc_input[D*sub_bat+26],loc_input[D*sub_bat+27],loc_input[D*sub_bat+28],loc_input[D*sub_bat+29],loc_input[D*sub_bat+30],loc_input[D*sub_bat+31],loc_input[D*sub_bat+32],loc_input[D*sub_bat+33],loc_input[D*sub_bat+34],loc_input[D*sub_bat+35],loc_input[D*sub_bat+36],loc_input[D*sub_bat+37],loc_input[D*sub_bat+38],loc_input[D*sub_bat+39],loc_input[D*sub_bat+40],loc_input[D*sub_bat+41],loc_input[D*sub_bat+42],loc_input[D*sub_bat+43],loc_input[D*sub_bat+44],loc_input[D*sub_bat+45],loc_input[D*sub_bat+46],loc_input[D*sub_bat+47],loc_input[D*sub_bat+48],loc_input[D*sub_bat+49],loc_input[D*sub_bat+50],loc_input[D*sub_bat+51],loc_input[D*sub_bat+52],loc_input[D*sub_bat+53],loc_input[D*sub_bat+54],loc_input[D*sub_bat+55],loc_input[D*sub_bat+56],loc_input[D*sub_bat+57],loc_input[D*sub_bat+58],loc_input[D*sub_bat+59],loc_input[D*sub_bat+60],loc_input[D*sub_bat+61],loc_input[D*sub_bat+62],loc_input[D*sub_bat+63],loc_input[D*sub_bat+64],loc_input[D*sub_bat+65],loc_input[D*sub_bat+66],loc_input[D*sub_bat+67],loc_input[D*sub_bat+68],loc_input[D*sub_bat+69],loc_input[D*sub_bat+70],loc_input[D*sub_bat+71],loc_input[D*sub_bat+72],loc_input[D*sub_bat+73],loc_input[D*sub_bat+74],loc_input[D*sub_bat+75],loc_input[D*sub_bat+76],loc_input[D*sub_bat+77],loc_input[D*sub_bat+78],loc_input[D*sub_bat+79],loc_input[D*sub_bat+80],loc_input[D*sub_bat+81],loc_input[D*sub_bat+82],loc_input[D*sub_bat+83],loc_input[D*sub_bat+84],loc_input[D*sub_bat+85],loc_input[D*sub_bat+86],loc_input[D*sub_bat+87],loc_input[D*sub_bat+88],loc_input[D*sub_bat+89],loc_input[D*sub_bat+90],loc_input[D*sub_bat+91],loc_input[D*sub_bat+92],loc_input[D*sub_bat+93],loc_input[D*sub_bat+94],loc_input[D*sub_bat+95],loc_input[D*sub_bat+96],loc_input[D*sub_bat+97],loc_input[D*sub_bat+98],loc_input[D*sub_bat+99],loc_input[D*sub_bat+100],loc_input[D*sub_bat+101],loc_input[D*sub_bat+102],loc_input[D*sub_bat+103],loc_input[D*sub_bat+104],loc_input[D*sub_bat+105],loc_input[D*sub_bat+106],loc_input[D*sub_bat+107],loc_input[D*sub_bat+108],loc_input[D*sub_bat+109],loc_input[D*sub_bat+110],loc_input[D*sub_bat+111],loc_input[D*sub_bat+112],loc_input[D*sub_bat+113],loc_input[D*sub_bat+114],loc_input[D*sub_bat+115],loc_input[D*sub_bat+116],loc_input[D*sub_bat+117],loc_input[D*sub_bat+118],loc_input[D*sub_bat+119],loc_input[D*sub_bat+120],loc_input[D*sub_bat+121],loc_input[D*sub_bat+122],loc_input[D*sub_bat+123],loc_input[D*sub_bat+124],loc_input[D*sub_bat+125],loc_input[D*sub_bat+126],loc_input[D*sub_bat+127],loc_input[D*sub_bat+128],loc_input[D*sub_bat+129],loc_input[D*sub_bat+130],loc_input[D*sub_bat+131],loc_input[D*sub_bat+132],loc_input[D*sub_bat+133],loc_input[D*sub_bat+134],loc_input[D*sub_bat+135],loc_input[D*sub_bat+136],loc_input[D*sub_bat+137],loc_input[D*sub_bat+138],loc_input[D*sub_bat+139],loc_input[D*sub_bat+140],loc_input[D*sub_bat+141],loc_input[D*sub_bat+142],loc_input[D*sub_bat+143],loc_input[D*sub_bat+144],loc_input[D*sub_bat+145],loc_input[D*sub_bat+146],loc_input[D*sub_bat+147],loc_input[D*sub_bat+148],loc_input[D*sub_bat+149],loc_input[D*sub_bat+150],loc_input[D*sub_bat+151],loc_input[D*sub_bat+152],loc_input[D*sub_bat+153],loc_input[D*sub_bat+154],loc_input[D*sub_bat+155],loc_input[D*sub_bat+156],loc_input[D*sub_bat+157],loc_input[D*sub_bat+158],loc_input[D*sub_bat+159],loc_input[D*sub_bat+160],loc_input[D*sub_bat+161],loc_input[D*sub_bat+162],loc_input[D*sub_bat+163],loc_input[D*sub_bat+164],loc_input[D*sub_bat+165],loc_input[D*sub_bat+166],loc_input[D*sub_bat+167],loc_input[D*sub_bat+168],loc_input[D*sub_bat+169],loc_input[D*sub_bat+170],loc_input[D*sub_bat+171],loc_input[D*sub_bat+172],loc_input[D*sub_bat+173],loc_input[D*sub_bat+174],loc_input[D*sub_bat+175],loc_input[D*sub_bat+176],loc_input[D*sub_bat+177],loc_input[D*sub_bat+178],loc_input[D*sub_bat+179],loc_input[D*sub_bat+180],loc_input[D*sub_bat+181],loc_input[D*sub_bat+182],loc_input[D*sub_bat+183],loc_input[D*sub_bat+184],loc_input[D*sub_bat+185],loc_input[D*sub_bat+186],loc_input[D*sub_bat+187],loc_input[D*sub_bat+188],loc_input[D*sub_bat+189],loc_input[D*sub_bat+190],loc_input[D*sub_bat+191],loc_input[D*sub_bat+192],loc_input[D*sub_bat+193],loc_input[D*sub_bat+194],loc_input[D*sub_bat+195],loc_input[D*sub_bat+196],loc_input[D*sub_bat+197],loc_input[D*sub_bat+198],loc_input[D*sub_bat+199],loc_input[D*sub_bat+200],loc_input[D*sub_bat+201],loc_input[D*sub_bat+202],loc_input[D*sub_bat+203],loc_input[D*sub_bat+204],loc_input[D*sub_bat+205],loc_input[D*sub_bat+206],loc_input[D*sub_bat+207],loc_input[D*sub_bat+208],loc_input[D*sub_bat+209],loc_input[D*sub_bat+210],loc_input[D*sub_bat+211],loc_input[D*sub_bat+212],loc_input[D*sub_bat+213],loc_input[D*sub_bat+214],loc_input[D*sub_bat+215],loc_input[D*sub_bat+216],loc_input[D*sub_bat+217],loc_input[D*sub_bat+218],loc_input[D*sub_bat+219],loc_input[D*sub_bat+220],loc_input[D*sub_bat+221],loc_input[D*sub_bat+222],loc_input[D*sub_bat+223],loc_input[D*sub_bat+224],loc_input[D*sub_bat+225],loc_input[D*sub_bat+226],loc_input[D*sub_bat+227],loc_input[D*sub_bat+228],loc_input[D*sub_bat+229],loc_input[D*sub_bat+230],loc_input[D*sub_bat+231],loc_input[D*sub_bat+232],loc_input[D*sub_bat+233],loc_input[D*sub_bat+234],loc_input[D*sub_bat+235],loc_input[D*sub_bat+236],loc_input[D*sub_bat+237],loc_input[D*sub_bat+238],loc_input[D*sub_bat+239],loc_input[D*sub_bat+240],loc_input[D*sub_bat+241],loc_input[D*sub_bat+242],loc_input[D*sub_bat+243],loc_input[D*sub_bat+244],loc_input[D*sub_bat+245],loc_input[D*sub_bat+246],loc_input[D*sub_bat+247],loc_input[D*sub_bat+248],loc_input[D*sub_bat+249],loc_input[D*sub_bat+250],loc_input[D*sub_bat+251],loc_input[D*sub_bat+252],loc_input[D*sub_bat+253],loc_input[D*sub_bat+254],loc_input[D*sub_bat+255]};
        tmpdist = dist_input[vid]; // 0 at MSB
        dist_rdata = { tmpdist[N-1-(D*sub_bat+0)], tmpdist[N-1-(D*sub_bat+1)], tmpdist[N-1-(D*sub_bat+2)], tmpdist[N-1-(D*sub_bat+3)], tmpdist[N-1-(D*sub_bat+4)], tmpdist[N-1-(D*sub_bat+5)], tmpdist[N-1-(D*sub_bat+6)], tmpdist[N-1-(D*sub_bat+7)], tmpdist[N-1-(D*sub_bat+8)], tmpdist[N-1-(D*sub_bat+9)], tmpdist[N-1-(D*sub_bat+10)], tmpdist[N-1-(D*sub_bat+11)], tmpdist[N-1-(D*sub_bat+12)], tmpdist[N-1-(D*sub_bat+13)], tmpdist[N-1-(D*sub_bat+14)], tmpdist[N-1-(D*sub_bat+15)], tmpdist[N-1-(D*sub_bat+16)], tmpdist[N-1-(D*sub_bat+17)], tmpdist[N-1-(D*sub_bat+18)], tmpdist[N-1-(D*sub_bat+19)], tmpdist[N-1-(D*sub_bat+20)], tmpdist[N-1-(D*sub_bat+21)], tmpdist[N-1-(D*sub_bat+22)], tmpdist[N-1-(D*sub_bat+23)], tmpdist[N-1-(D*sub_bat+24)], tmpdist[N-1-(D*sub_bat+25)], tmpdist[N-1-(D*sub_bat+26)], tmpdist[N-1-(D*sub_bat+27)], tmpdist[N-1-(D*sub_bat+28)], tmpdist[N-1-(D*sub_bat+29)], tmpdist[N-1-(D*sub_bat+30)], tmpdist[N-1-(D*sub_bat+31)], tmpdist[N-1-(D*sub_bat+32)], tmpdist[N-1-(D*sub_bat+33)], tmpdist[N-1-(D*sub_bat+34)], tmpdist[N-1-(D*sub_bat+35)], tmpdist[N-1-(D*sub_bat+36)], tmpdist[N-1-(D*sub_bat+37)], tmpdist[N-1-(D*sub_bat+38)], tmpdist[N-1-(D*sub_bat+39)], tmpdist[N-1-(D*sub_bat+40)], tmpdist[N-1-(D*sub_bat+41)], tmpdist[N-1-(D*sub_bat+42)], tmpdist[N-1-(D*sub_bat+43)], tmpdist[N-1-(D*sub_bat+44)], tmpdist[N-1-(D*sub_bat+45)], tmpdist[N-1-(D*sub_bat+46)], tmpdist[N-1-(D*sub_bat+47)], tmpdist[N-1-(D*sub_bat+48)], tmpdist[N-1-(D*sub_bat+49)], tmpdist[N-1-(D*sub_bat+50)], tmpdist[N-1-(D*sub_bat+51)], tmpdist[N-1-(D*sub_bat+52)], tmpdist[N-1-(D*sub_bat+53)], tmpdist[N-1-(D*sub_bat+54)], tmpdist[N-1-(D*sub_bat+55)], tmpdist[N-1-(D*sub_bat+56)], tmpdist[N-1-(D*sub_bat+57)], tmpdist[N-1-(D*sub_bat+58)], tmpdist[N-1-(D*sub_bat+59)], tmpdist[N-1-(D*sub_bat+60)], tmpdist[N-1-(D*sub_bat+61)], tmpdist[N-1-(D*sub_bat+62)], tmpdist[N-1-(D*sub_bat+63)], tmpdist[N-1-(D*sub_bat+64)], tmpdist[N-1-(D*sub_bat+65)], tmpdist[N-1-(D*sub_bat+66)], tmpdist[N-1-(D*sub_bat+67)], tmpdist[N-1-(D*sub_bat+68)], tmpdist[N-1-(D*sub_bat+69)], tmpdist[N-1-(D*sub_bat+70)], tmpdist[N-1-(D*sub_bat+71)], tmpdist[N-1-(D*sub_bat+72)], tmpdist[N-1-(D*sub_bat+73)], tmpdist[N-1-(D*sub_bat+74)], tmpdist[N-1-(D*sub_bat+75)], tmpdist[N-1-(D*sub_bat+76)], tmpdist[N-1-(D*sub_bat+77)], tmpdist[N-1-(D*sub_bat+78)], tmpdist[N-1-(D*sub_bat+79)], tmpdist[N-1-(D*sub_bat+80)], tmpdist[N-1-(D*sub_bat+81)], tmpdist[N-1-(D*sub_bat+82)], tmpdist[N-1-(D*sub_bat+83)], tmpdist[N-1-(D*sub_bat+84)], tmpdist[N-1-(D*sub_bat+85)], tmpdist[N-1-(D*sub_bat+86)], tmpdist[N-1-(D*sub_bat+87)], tmpdist[N-1-(D*sub_bat+88)], tmpdist[N-1-(D*sub_bat+89)], tmpdist[N-1-(D*sub_bat+90)], tmpdist[N-1-(D*sub_bat+91)], tmpdist[N-1-(D*sub_bat+92)], tmpdist[N-1-(D*sub_bat+93)], tmpdist[N-1-(D*sub_bat+94)], tmpdist[N-1-(D*sub_bat+95)], tmpdist[N-1-(D*sub_bat+96)], tmpdist[N-1-(D*sub_bat+97)], tmpdist[N-1-(D*sub_bat+98)], tmpdist[N-1-(D*sub_bat+99)], tmpdist[N-1-(D*sub_bat+100)], tmpdist[N-1-(D*sub_bat+101)], tmpdist[N-1-(D*sub_bat+102)], tmpdist[N-1-(D*sub_bat+103)], tmpdist[N-1-(D*sub_bat+104)], tmpdist[N-1-(D*sub_bat+105)], tmpdist[N-1-(D*sub_bat+106)], tmpdist[N-1-(D*sub_bat+107)], tmpdist[N-1-(D*sub_bat+108)], tmpdist[N-1-(D*sub_bat+109)], tmpdist[N-1-(D*sub_bat+110)], tmpdist[N-1-(D*sub_bat+111)], tmpdist[N-1-(D*sub_bat+112)], tmpdist[N-1-(D*sub_bat+113)], tmpdist[N-1-(D*sub_bat+114)], tmpdist[N-1-(D*sub_bat+115)], tmpdist[N-1-(D*sub_bat+116)], tmpdist[N-1-(D*sub_bat+117)], tmpdist[N-1-(D*sub_bat+118)], tmpdist[N-1-(D*sub_bat+119)], tmpdist[N-1-(D*sub_bat+120)], tmpdist[N-1-(D*sub_bat+121)], tmpdist[N-1-(D*sub_bat+122)], tmpdist[N-1-(D*sub_bat+123)], tmpdist[N-1-(D*sub_bat+124)], tmpdist[N-1-(D*sub_bat+125)], tmpdist[N-1-(D*sub_bat+126)], tmpdist[N-1-(D*sub_bat+127)], tmpdist[N-1-(D*sub_bat+128)], tmpdist[N-1-(D*sub_bat+129)], tmpdist[N-1-(D*sub_bat+130)], tmpdist[N-1-(D*sub_bat+131)], tmpdist[N-1-(D*sub_bat+132)], tmpdist[N-1-(D*sub_bat+133)], tmpdist[N-1-(D*sub_bat+134)], tmpdist[N-1-(D*sub_bat+135)], tmpdist[N-1-(D*sub_bat+136)], tmpdist[N-1-(D*sub_bat+137)], tmpdist[N-1-(D*sub_bat+138)], tmpdist[N-1-(D*sub_bat+139)], tmpdist[N-1-(D*sub_bat+140)], tmpdist[N-1-(D*sub_bat+141)], tmpdist[N-1-(D*sub_bat+142)], tmpdist[N-1-(D*sub_bat+143)], tmpdist[N-1-(D*sub_bat+144)], tmpdist[N-1-(D*sub_bat+145)], tmpdist[N-1-(D*sub_bat+146)], tmpdist[N-1-(D*sub_bat+147)], tmpdist[N-1-(D*sub_bat+148)], tmpdist[N-1-(D*sub_bat+149)], tmpdist[N-1-(D*sub_bat+150)], tmpdist[N-1-(D*sub_bat+151)], tmpdist[N-1-(D*sub_bat+152)], tmpdist[N-1-(D*sub_bat+153)], tmpdist[N-1-(D*sub_bat+154)], tmpdist[N-1-(D*sub_bat+155)], tmpdist[N-1-(D*sub_bat+156)], tmpdist[N-1-(D*sub_bat+157)], tmpdist[N-1-(D*sub_bat+158)], tmpdist[N-1-(D*sub_bat+159)], tmpdist[N-1-(D*sub_bat+160)], tmpdist[N-1-(D*sub_bat+161)], tmpdist[N-1-(D*sub_bat+162)], tmpdist[N-1-(D*sub_bat+163)], tmpdist[N-1-(D*sub_bat+164)], tmpdist[N-1-(D*sub_bat+165)], tmpdist[N-1-(D*sub_bat+166)], tmpdist[N-1-(D*sub_bat+167)], tmpdist[N-1-(D*sub_bat+168)], tmpdist[N-1-(D*sub_bat+169)], tmpdist[N-1-(D*sub_bat+170)], tmpdist[N-1-(D*sub_bat+171)], tmpdist[N-1-(D*sub_bat+172)], tmpdist[N-1-(D*sub_bat+173)], tmpdist[N-1-(D*sub_bat+174)], tmpdist[N-1-(D*sub_bat+175)], tmpdist[N-1-(D*sub_bat+176)], tmpdist[N-1-(D*sub_bat+177)], tmpdist[N-1-(D*sub_bat+178)], tmpdist[N-1-(D*sub_bat+179)], tmpdist[N-1-(D*sub_bat+180)], tmpdist[N-1-(D*sub_bat+181)], tmpdist[N-1-(D*sub_bat+182)], tmpdist[N-1-(D*sub_bat+183)], tmpdist[N-1-(D*sub_bat+184)], tmpdist[N-1-(D*sub_bat+185)], tmpdist[N-1-(D*sub_bat+186)], tmpdist[N-1-(D*sub_bat+187)], tmpdist[N-1-(D*sub_bat+188)], tmpdist[N-1-(D*sub_bat+189)], tmpdist[N-1-(D*sub_bat+190)], tmpdist[N-1-(D*sub_bat+191)], tmpdist[N-1-(D*sub_bat+192)], tmpdist[N-1-(D*sub_bat+193)], tmpdist[N-1-(D*sub_bat+194)], tmpdist[N-1-(D*sub_bat+195)], tmpdist[N-1-(D*sub_bat+196)], tmpdist[N-1-(D*sub_bat+197)], tmpdist[N-1-(D*sub_bat+198)], tmpdist[N-1-(D*sub_bat+199)], tmpdist[N-1-(D*sub_bat+200)], tmpdist[N-1-(D*sub_bat+201)], tmpdist[N-1-(D*sub_bat+202)], tmpdist[N-1-(D*sub_bat+203)], tmpdist[N-1-(D*sub_bat+204)], tmpdist[N-1-(D*sub_bat+205)], tmpdist[N-1-(D*sub_bat+206)], tmpdist[N-1-(D*sub_bat+207)], tmpdist[N-1-(D*sub_bat+208)], tmpdist[N-1-(D*sub_bat+209)], tmpdist[N-1-(D*sub_bat+210)], tmpdist[N-1-(D*sub_bat+211)], tmpdist[N-1-(D*sub_bat+212)], tmpdist[N-1-(D*sub_bat+213)], tmpdist[N-1-(D*sub_bat+214)], tmpdist[N-1-(D*sub_bat+215)], tmpdist[N-1-(D*sub_bat+216)], tmpdist[N-1-(D*sub_bat+217)], tmpdist[N-1-(D*sub_bat+218)], tmpdist[N-1-(D*sub_bat+219)], tmpdist[N-1-(D*sub_bat+220)], tmpdist[N-1-(D*sub_bat+221)], tmpdist[N-1-(D*sub_bat+222)], tmpdist[N-1-(D*sub_bat+223)], tmpdist[N-1-(D*sub_bat+224)], tmpdist[N-1-(D*sub_bat+225)], tmpdist[N-1-(D*sub_bat+226)], tmpdist[N-1-(D*sub_bat+227)], tmpdist[N-1-(D*sub_bat+228)], tmpdist[N-1-(D*sub_bat+229)], tmpdist[N-1-(D*sub_bat+230)], tmpdist[N-1-(D*sub_bat+231)], tmpdist[N-1-(D*sub_bat+232)], tmpdist[N-1-(D*sub_bat+233)], tmpdist[N-1-(D*sub_bat+234)], tmpdist[N-1-(D*sub_bat+235)], tmpdist[N-1-(D*sub_bat+236)], tmpdist[N-1-(D*sub_bat+237)], tmpdist[N-1-(D*sub_bat+238)], tmpdist[N-1-(D*sub_bat+239)], tmpdist[N-1-(D*sub_bat+240)], tmpdist[N-1-(D*sub_bat+241)], tmpdist[N-1-(D*sub_bat+242)], tmpdist[N-1-(D*sub_bat+243)], tmpdist[N-1-(D*sub_bat+244)], tmpdist[N-1-(D*sub_bat+245)], tmpdist[N-1-(D*sub_bat+246)], tmpdist[N-1-(D*sub_bat+247)], tmpdist[N-1-(D*sub_bat+248)], tmpdist[N-1-(D*sub_bat+249)], tmpdist[N-1-(D*sub_bat+250)], tmpdist[N-1-(D*sub_bat+251)], tmpdist[N-1-(D*sub_bat+252)], tmpdist[N-1-(D*sub_bat+253)], tmpdist[N-1-(D*sub_bat+254)], tmpdist[N-1-(D*sub_bat+255)]};    
        if(ready == 1) begin 
            // part[k] for a sub-batch finish
            $write("sub-batch %d :", sub_bat);
            // for(i = 0; i < K; i = i + 1) begin 
                // $write("%d ", worker_instn.part[i]);
                // if(worker_instn.part[i] != )
            // end 
            // $write("\n");
            check_sub = check_sub + 1;
        end 
        if(batch_finish == 1) begin
            // TODO: check , compare with propsal # and next
            //if(pro_gold[check_batch] !=  pro_wdata)
            //$write("proposal number fail");
            //$finish;
            //end 
            // 
            //
            check_batch = check_batch + 1;
        end 
    end 
    $write("bat: %d\n",batch);
    $finish;
end 
initial begin 
    #(CYCLE*100000);
    $finish;
end 
endmodule