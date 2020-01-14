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
localparam VID_ADDR_SPACE = 5;
localparam Q = 16;
localparam TOTAL_VID = 256; // in one worker N / K 
localparam BATCH_BW = 8;
real CYCLE = 10;

//====== module I/O =====
reg clk;
reg rst_n;
reg enable;


wire [4-1:0] sub_bat;
integer i; 
integer flag;
// input 
reg [BATCH_BW:0] batch;
reg [Q*VID_BW-1:0] vid_rdata;
reg [D*DIST_BW-1:0] dist_rdata;
reg [D*(LOC_BW-1)-1:0] loc_rdata;
wire [VID_BW*Q-1:0] vid_sram_rdata0;
wire [D*DIST_BW-1:0] dist_sram_rdata0;
// output 
wire [VID_BW-1:0] vid;
wire [Q*NEXT_BW-1:0] next_wdata;
wire [NEXT_ADDR_SPACE-1:0] next_waddr;
wire [Q*PRO_BW-1:0] pro_wdata;
wire [PRO_ADDR_SPACE-1:0] pro_waddr;
wire ready;         // test sub-tach part[k] 
wire batch_finish;  // 256 batches are finish === MODULE FINISH !!! 
wire worker_wen; // save into next_srams and proposal srams 
wire [Q-1:0] next_bytemask;
wire [Q-1:0] pro_bytemask;
wire [VID_ADDR_SPACE-1:0] vid_sram_raddr0;
wire [DIST_ADDR_SPACE-1:0] dist_sram_raddr0;
// =================== instance sram ================================
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE), .Q(Q), .VID_BW(VID_BW)) w0_vid_sram_16x256b(
    .clk(clk),
    .wsb(),
    .wdata(),
    .waddr(),
    .raddr(vid_sram_raddr0),
    .rdata(vid_sram_rdata0)
);
dist_sram_NxNb #(.N(N), .BW(DIST_BW), .D(D), .ADDR_SPACE(DIST_ADDR_SPACE)) w0_dist_sram_NxNb(
    .clk(clk),
    .wsb(),
    .wdata(),
    .waddr(),
    .raddr(dist_sram_raddr0),
    .rdata(dist_sram_rdata0)
);
// ----- write ------
next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE), .Q(Q), .BW(NEXT_BW)) w0_next_sram_256x4b(
    .clk(clk),
    .wsb(~worker_wen),
    .wdata(next_wdata),
    .bytemask(next_bytemask),
    .waddr(next_waddr),
    .raddr({NEXT_ADDR_SPACE{1'b0}}),
    .rdata()
);
proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE), .Q(Q), .BW(PRO_BW)) w0_proposal_sram_16x128b(
    .clk(clk),
    .wsb(~worker_wen),
    .wdata(pro_wdata),
    .bytemask(pro_bytemask),
    .waddr(pro_waddr),
    .raddr({PRO_ADDR_SPACE{1'b0}}),
    .rdata()
);
 // ==================================================================== 
 worker_sram #(.WORK_IDX(15)) worker_instn(
     .clk(clk),
     .en(enable),
     .rst_n(~rst_n),
     .batch_num(batch[7:0]),
     .vid_sram_rdata(vid_sram_rdata0),// .vid_rdata(vid_rdata),
     .dist_sram_rdata(dist_sram_rdata0),// .dist_rdata(dist_rdata),
     .loc_rdata(loc_rdata),
     // output 
     .sub_bat(sub_bat),
     .vid_sram_raddr(vid_sram_raddr0),// .vid(vid), // for indexing the Dist
     .dist_sram_raddr(dist_sram_raddr0),
     .loc_sram_raddr(),
     .next_bytemask(next_bytemask),
     .next_wdata(next_wdata),
     .next_waddr(next_waddr),
     .pro_bytemask(pro_bytemask),
     .pro_wdata(pro_wdata),
     .pro_waddr(pro_waddr),
     .ready(ready),
     .batch_finish(batch_finish),
     .wen(worker_wen)
 );

// each worker is responsible for N/K = 4096 / 16 = 256 totaly for one round
// this module test only first round currently 
// TODO: HARDCODE TO CHANGE
reg [NEXT_BW*Q-1:0] next_gold[0:16-1]; // 4 bit 
reg [PRO_BW*Q-1:0] pro_gold[0:16-1]; // proposal number 

// reg [VID_BW-1:0] vid_input[0:255]; // N/(K*Q) 
// reg [N-1:0] dist_input[0:N-1];
reg [VID_BW*Q-1:0] vid_input[0:31];
reg [D*DIST_BW-1:0] dist_input[0:65535];
reg [LOC_BW-1:0] loc_input[0:N-1];
reg [PRO_BW*K-1:0] part_gold[0:255]; // 16(K) , total sub_bat number = 16 for first batch 
always #(CYCLE/2) clk = ~clk;

 initial begin
 	$fsdbDumpfile("proj_presim_workersram_temp.fsdb");
 	$fsdbDumpvars("+mda");
 end

integer tmp;
reg [N-1:0] tmpdist;
reg [16:0] idxr;
localparam iter = 0; // even iteration
localparam testworkerid = 15;
initial begin 
    clk = 0;
    rst_n = 0;
    enable = 1'b0;
    $readmemh("../software/gold/15_vid.dat", vid_input);
    for(tmp = 0; tmp < 16; tmp = tmp + 1) 
        w0_vid_sram_16x256b.load_param(iter * 16 + tmp, vid_input[tmp]);
    $write("vidsram %h\n", w0_vid_sram_16x256b.mem[3] );
    $readmemh("../software/gold/dist_sram.dat", dist_input); 
    $write("loading dist to sram\n");
    $readmemh("../software/gold/dist_sram.dat", w0_dist_sram_NxNb.mem);
    $write("dist: %h\n", w0_dist_sram_NxNb.mem[2]);
    $write("RRRRRR\n");
    $readmemh("../software/gold/loc.dat", loc_input);
    $write("loc %h\n", loc_input[4095]);
    $readmemh("../software/gold/15_bat_part.dat", part_gold); // only batch number 0's 16 sub-batch's part[0-K] 
    $write("part %h\n", part_gold[1]);
    $readmemh("../software/gold/15_next.dat", next_gold);
    $write("next 15 %h\n", next_gold[15]);
    $readmemh("../software/gold/15_proposal_num.dat", pro_gold);
    $write("proposal_num 15 %h\n", pro_gold[15]);
    // $finish;

    #(CYCLE) rst_n = 1; 
    #(CYCLE) enable = 1'b1;
    rst_n = 0;    
    batch = 0;
    // sub_bat = 0;
    // loc_rdata = {loc_input[D*15+0][3:0], loc_input[D*15+1][3:0], loc_input[D*15+2][3:0], loc_input[D*15+3][3:0], loc_input[D*15+4][3:0], loc_input[D*15+5][3:0], loc_input[D*15+6][3:0], loc_input[D*15+7][3:0], loc_input[D*15+8][3:0], loc_input[D*15+9][3:0], loc_input[D*15+10][3:0], loc_input[D*15+11][3:0], loc_input[D*15+12][3:0], loc_input[D*15+13][3:0], loc_input[D*15+14][3:0], loc_input[D*15+15][3:0], loc_input[D*15+16][3:0], loc_input[D*15+17][3:0], loc_input[D*15+18][3:0], loc_input[D*15+19][3:0], loc_input[D*15+20][3:0], loc_input[D*15+21][3:0], loc_input[D*15+22][3:0], loc_input[D*15+23][3:0], loc_input[D*15+24][3:0], loc_input[D*15+25][3:0], loc_input[D*15+26][3:0], loc_input[D*15+27][3:0], loc_input[D*15+28][3:0], loc_input[D*15+29][3:0], loc_input[D*15+30][3:0], loc_input[D*15+31][3:0], loc_input[D*15+32][3:0], loc_input[D*15+33][3:0], loc_input[D*15+34][3:0], loc_input[D*15+35][3:0], loc_input[D*15+36][3:0], loc_input[D*15+37][3:0], loc_input[D*15+38][3:0], loc_input[D*15+39][3:0], loc_input[D*15+40][3:0], loc_input[D*15+41][3:0], loc_input[D*15+42][3:0], loc_input[D*15+43][3:0], loc_input[D*15+44][3:0], loc_input[D*15+45][3:0], loc_input[D*15+46][3:0], loc_input[D*15+47][3:0], loc_input[D*15+48][3:0], loc_input[D*15+49][3:0], loc_input[D*15+50][3:0], loc_input[D*15+51][3:0], loc_input[D*15+52][3:0], loc_input[D*15+53][3:0], loc_input[D*15+54][3:0], loc_input[D*15+55][3:0], loc_input[D*15+56][3:0], loc_input[D*15+57][3:0], loc_input[D*15+58][3:0], loc_input[D*15+59][3:0], loc_input[D*15+60][3:0], loc_input[D*15+61][3:0], loc_input[D*15+62][3:0], loc_input[D*15+63][3:0], loc_input[D*15+64][3:0], loc_input[D*15+65][3:0], loc_input[D*15+66][3:0], loc_input[D*15+67][3:0], loc_input[D*15+68][3:0], loc_input[D*15+69][3:0], loc_input[D*15+70][3:0], loc_input[D*15+71][3:0], loc_input[D*15+72][3:0], loc_input[D*15+73][3:0], loc_input[D*15+74][3:0], loc_input[D*15+75][3:0], loc_input[D*15+76][3:0], loc_input[D*15+77][3:0], loc_input[D*15+78][3:0], loc_input[D*15+79][3:0], loc_input[D*15+80][3:0], loc_input[D*15+81][3:0], loc_input[D*15+82][3:0], loc_input[D*15+83][3:0], loc_input[D*15+84][3:0], loc_input[D*15+85][3:0], loc_input[D*15+86][3:0], loc_input[D*15+87][3:0], loc_input[D*15+88][3:0], loc_input[D*15+89][3:0], loc_input[D*15+90][3:0], loc_input[D*15+91][3:0], loc_input[D*15+92][3:0], loc_input[D*15+93][3:0], loc_input[D*15+94][3:0], loc_input[D*15+95][3:0], loc_input[D*15+96][3:0], loc_input[D*15+97][3:0], loc_input[D*15+98][3:0], loc_input[D*15+99][3:0], loc_input[D*15+100][3:0], loc_input[D*15+101][3:0], loc_input[D*15+102][3:0], loc_input[D*15+103][3:0], loc_input[D*15+104][3:0], loc_input[D*15+105][3:0], loc_input[D*15+106][3:0], loc_input[D*15+107][3:0], loc_input[D*15+108][3:0], loc_input[D*15+109][3:0], loc_input[D*15+110][3:0], loc_input[D*15+111][3:0], loc_input[D*15+112][3:0], loc_input[D*15+113][3:0], loc_input[D*15+114][3:0], loc_input[D*15+115][3:0], loc_input[D*15+116][3:0], loc_input[D*15+117][3:0], loc_input[D*15+118][3:0], loc_input[D*15+119][3:0], loc_input[D*15+120][3:0], loc_input[D*15+121][3:0], loc_input[D*15+122][3:0], loc_input[D*15+123][3:0], loc_input[D*15+124][3:0], loc_input[D*15+125][3:0], loc_input[D*15+126][3:0], loc_input[D*15+127][3:0], loc_input[D*15+128][3:0], loc_input[D*15+129][3:0], loc_input[D*15+130][3:0], loc_input[D*15+131][3:0], loc_input[D*15+132][3:0], loc_input[D*15+133][3:0], loc_input[D*15+134][3:0], loc_input[D*15+135][3:0], loc_input[D*15+136][3:0], loc_input[D*15+137][3:0], loc_input[D*15+138][3:0], loc_input[D*15+139][3:0], loc_input[D*15+140][3:0], loc_input[D*15+141][3:0], loc_input[D*15+142][3:0], loc_input[D*15+143][3:0], loc_input[D*15+144][3:0], loc_input[D*15+145][3:0], loc_input[D*15+146][3:0], loc_input[D*15+147][3:0], loc_input[D*15+148][3:0], loc_input[D*15+149][3:0], loc_input[D*15+150][3:0], loc_input[D*15+151][3:0], loc_input[D*15+152][3:0], loc_input[D*15+153][3:0], loc_input[D*15+154][3:0], loc_input[D*15+155][3:0], loc_input[D*15+156][3:0], loc_input[D*15+157][3:0], loc_input[D*15+158][3:0], loc_input[D*15+159][3:0], loc_input[D*15+160][3:0], loc_input[D*15+161][3:0], loc_input[D*15+162][3:0], loc_input[D*15+163][3:0], loc_input[D*15+164][3:0], loc_input[D*15+165][3:0], loc_input[D*15+166][3:0], loc_input[D*15+167][3:0], loc_input[D*15+168][3:0], loc_input[D*15+169][3:0], loc_input[D*15+170][3:0], loc_input[D*15+171][3:0], loc_input[D*15+172][3:0], loc_input[D*15+173][3:0], loc_input[D*15+174][3:0], loc_input[D*15+175][3:0], loc_input[D*15+176][3:0], loc_input[D*15+177][3:0], loc_input[D*15+178][3:0], loc_input[D*15+179][3:0], loc_input[D*15+180][3:0], loc_input[D*15+181][3:0], loc_input[D*15+182][3:0], loc_input[D*15+183][3:0], loc_input[D*15+184][3:0], loc_input[D*15+185][3:0], loc_input[D*15+186][3:0], loc_input[D*15+187][3:0], loc_input[D*15+188][3:0], loc_input[D*15+189][3:0], loc_input[D*15+190][3:0], loc_input[D*15+191][3:0], loc_input[D*15+192][3:0], loc_input[D*15+193][3:0], loc_input[D*15+194][3:0], loc_input[D*15+195][3:0], loc_input[D*15+196][3:0], loc_input[D*15+197][3:0], loc_input[D*15+198][3:0], loc_input[D*15+199][3:0], loc_input[D*15+200][3:0], loc_input[D*15+201][3:0], loc_input[D*15+202][3:0], loc_input[D*15+203][3:0], loc_input[D*15+204][3:0], loc_input[D*15+205][3:0], loc_input[D*15+206][3:0], loc_input[D*15+207][3:0], loc_input[D*15+208][3:0], loc_input[D*15+209][3:0], loc_input[D*15+210][3:0], loc_input[D*15+211][3:0], loc_input[D*15+212][3:0], loc_input[D*15+213][3:0], loc_input[D*15+214][3:0], loc_input[D*15+215][3:0], loc_input[D*15+216][3:0], loc_input[D*15+217][3:0], loc_input[D*15+218][3:0], loc_input[D*15+219][3:0], loc_input[D*15+220][3:0], loc_input[D*15+221][3:0], loc_input[D*15+222][3:0], loc_input[D*15+223][3:0], loc_input[D*15+224][3:0], loc_input[D*15+225][3:0], loc_input[D*15+226][3:0], loc_input[D*15+227][3:0], loc_input[D*15+228][3:0], loc_input[D*15+229][3:0], loc_input[D*15+230][3:0], loc_input[D*15+231][3:0], loc_input[D*15+232][3:0], loc_input[D*15+233][3:0], loc_input[D*15+234][3:0], loc_input[D*15+235][3:0], loc_input[D*15+236][3:0], loc_input[D*15+237][3:0], loc_input[D*15+238][3:0], loc_input[D*15+239][3:0], loc_input[D*15+240][3:0], loc_input[D*15+241][3:0], loc_input[D*15+242][3:0], loc_input[D*15+243][3:0], loc_input[D*15+244][3:0], loc_input[D*15+245][3:0], loc_input[D*15+246][3:0], loc_input[D*15+247][3:0], loc_input[D*15+248][3:0], loc_input[D*15+249][3:0], loc_input[D*15+250][3:0], loc_input[D*15+251][3:0], loc_input[D*15+252][3:0], loc_input[D*15+253][3:0], loc_input[D*15+254][3:0], loc_input[D*15+255][3:0]};
end 
integer loadidx;

localparam max_batch = 256;
localparam max_sub_bat = 15;
integer check_sub;
integer check_batch;
integer sram_i;
wire [NEXT_BW*Q-1:0] bit_mask;
assign bit_mask = { {4{next_bytemask[15]}},{4{next_bytemask[14]}},{4{next_bytemask[13]}},{4{next_bytemask[12]}},
{4{next_bytemask[11]}},{4{next_bytemask[10]}},{4{next_bytemask[9]}},{4{next_bytemask[8]}},{4{next_bytemask[7]}},{4{next_bytemask[6]}},{4{next_bytemask[5]}},{4{next_bytemask[4]}},{4{next_bytemask[3]}},{4{next_bytemask[2]}},{4{next_bytemask[1]}},{4{next_bytemask[0]}}};
initial begin 
    check_sub = 0;
    check_batch = 0;
    wait(enable == 1);
    #(CYCLE);
    while(batch_finish == 0) begin
        @(negedge clk);
        if(sub_bat == max_sub_bat)begin 
            batch = batch + 1;
        end
        if(sub_bat == 0) begin
            loc_rdata = {loc_input[D*15+0][3:0], loc_input[D*15+1][3:0], loc_input[D*15+2][3:0], loc_input[D*15+3][3:0], loc_input[D*15+4][3:0], loc_input[D*15+5][3:0], loc_input[D*15+6][3:0], loc_input[D*15+7][3:0], loc_input[D*15+8][3:0], loc_input[D*15+9][3:0], loc_input[D*15+10][3:0], loc_input[D*15+11][3:0], loc_input[D*15+12][3:0], loc_input[D*15+13][3:0], loc_input[D*15+14][3:0], loc_input[D*15+15][3:0], loc_input[D*15+16][3:0], loc_input[D*15+17][3:0], loc_input[D*15+18][3:0], loc_input[D*15+19][3:0], loc_input[D*15+20][3:0], loc_input[D*15+21][3:0], loc_input[D*15+22][3:0], loc_input[D*15+23][3:0], loc_input[D*15+24][3:0], loc_input[D*15+25][3:0], loc_input[D*15+26][3:0], loc_input[D*15+27][3:0], loc_input[D*15+28][3:0], loc_input[D*15+29][3:0], loc_input[D*15+30][3:0], loc_input[D*15+31][3:0], loc_input[D*15+32][3:0], loc_input[D*15+33][3:0], loc_input[D*15+34][3:0], loc_input[D*15+35][3:0], loc_input[D*15+36][3:0], loc_input[D*15+37][3:0], loc_input[D*15+38][3:0], loc_input[D*15+39][3:0], loc_input[D*15+40][3:0], loc_input[D*15+41][3:0], loc_input[D*15+42][3:0], loc_input[D*15+43][3:0], loc_input[D*15+44][3:0], loc_input[D*15+45][3:0], loc_input[D*15+46][3:0], loc_input[D*15+47][3:0], loc_input[D*15+48][3:0], loc_input[D*15+49][3:0], loc_input[D*15+50][3:0], loc_input[D*15+51][3:0], loc_input[D*15+52][3:0], loc_input[D*15+53][3:0], loc_input[D*15+54][3:0], loc_input[D*15+55][3:0], loc_input[D*15+56][3:0], loc_input[D*15+57][3:0], loc_input[D*15+58][3:0], loc_input[D*15+59][3:0], loc_input[D*15+60][3:0], loc_input[D*15+61][3:0], loc_input[D*15+62][3:0], loc_input[D*15+63][3:0], loc_input[D*15+64][3:0], loc_input[D*15+65][3:0], loc_input[D*15+66][3:0], loc_input[D*15+67][3:0], loc_input[D*15+68][3:0], loc_input[D*15+69][3:0], loc_input[D*15+70][3:0], loc_input[D*15+71][3:0], loc_input[D*15+72][3:0], loc_input[D*15+73][3:0], loc_input[D*15+74][3:0], loc_input[D*15+75][3:0], loc_input[D*15+76][3:0], loc_input[D*15+77][3:0], loc_input[D*15+78][3:0], loc_input[D*15+79][3:0], loc_input[D*15+80][3:0], loc_input[D*15+81][3:0], loc_input[D*15+82][3:0], loc_input[D*15+83][3:0], loc_input[D*15+84][3:0], loc_input[D*15+85][3:0], loc_input[D*15+86][3:0], loc_input[D*15+87][3:0], loc_input[D*15+88][3:0], loc_input[D*15+89][3:0], loc_input[D*15+90][3:0], loc_input[D*15+91][3:0], loc_input[D*15+92][3:0], loc_input[D*15+93][3:0], loc_input[D*15+94][3:0], loc_input[D*15+95][3:0], loc_input[D*15+96][3:0], loc_input[D*15+97][3:0], loc_input[D*15+98][3:0], loc_input[D*15+99][3:0], loc_input[D*15+100][3:0], loc_input[D*15+101][3:0], loc_input[D*15+102][3:0], loc_input[D*15+103][3:0], loc_input[D*15+104][3:0], loc_input[D*15+105][3:0], loc_input[D*15+106][3:0], loc_input[D*15+107][3:0], loc_input[D*15+108][3:0], loc_input[D*15+109][3:0], loc_input[D*15+110][3:0], loc_input[D*15+111][3:0], loc_input[D*15+112][3:0], loc_input[D*15+113][3:0], loc_input[D*15+114][3:0], loc_input[D*15+115][3:0], loc_input[D*15+116][3:0], loc_input[D*15+117][3:0], loc_input[D*15+118][3:0], loc_input[D*15+119][3:0], loc_input[D*15+120][3:0], loc_input[D*15+121][3:0], loc_input[D*15+122][3:0], loc_input[D*15+123][3:0], loc_input[D*15+124][3:0], loc_input[D*15+125][3:0], loc_input[D*15+126][3:0], loc_input[D*15+127][3:0], loc_input[D*15+128][3:0], loc_input[D*15+129][3:0], loc_input[D*15+130][3:0], loc_input[D*15+131][3:0], loc_input[D*15+132][3:0], loc_input[D*15+133][3:0], loc_input[D*15+134][3:0], loc_input[D*15+135][3:0], loc_input[D*15+136][3:0], loc_input[D*15+137][3:0], loc_input[D*15+138][3:0], loc_input[D*15+139][3:0], loc_input[D*15+140][3:0], loc_input[D*15+141][3:0], loc_input[D*15+142][3:0], loc_input[D*15+143][3:0], loc_input[D*15+144][3:0], loc_input[D*15+145][3:0], loc_input[D*15+146][3:0], loc_input[D*15+147][3:0], loc_input[D*15+148][3:0], loc_input[D*15+149][3:0], loc_input[D*15+150][3:0], loc_input[D*15+151][3:0], loc_input[D*15+152][3:0], loc_input[D*15+153][3:0], loc_input[D*15+154][3:0], loc_input[D*15+155][3:0], loc_input[D*15+156][3:0], loc_input[D*15+157][3:0], loc_input[D*15+158][3:0], loc_input[D*15+159][3:0], loc_input[D*15+160][3:0], loc_input[D*15+161][3:0], loc_input[D*15+162][3:0], loc_input[D*15+163][3:0], loc_input[D*15+164][3:0], loc_input[D*15+165][3:0], loc_input[D*15+166][3:0], loc_input[D*15+167][3:0], loc_input[D*15+168][3:0], loc_input[D*15+169][3:0], loc_input[D*15+170][3:0], loc_input[D*15+171][3:0], loc_input[D*15+172][3:0], loc_input[D*15+173][3:0], loc_input[D*15+174][3:0], loc_input[D*15+175][3:0], loc_input[D*15+176][3:0], loc_input[D*15+177][3:0], loc_input[D*15+178][3:0], loc_input[D*15+179][3:0], loc_input[D*15+180][3:0], loc_input[D*15+181][3:0], loc_input[D*15+182][3:0], loc_input[D*15+183][3:0], loc_input[D*15+184][3:0], loc_input[D*15+185][3:0], loc_input[D*15+186][3:0], loc_input[D*15+187][3:0], loc_input[D*15+188][3:0], loc_input[D*15+189][3:0], loc_input[D*15+190][3:0], loc_input[D*15+191][3:0], loc_input[D*15+192][3:0], loc_input[D*15+193][3:0], loc_input[D*15+194][3:0], loc_input[D*15+195][3:0], loc_input[D*15+196][3:0], loc_input[D*15+197][3:0], loc_input[D*15+198][3:0], loc_input[D*15+199][3:0], loc_input[D*15+200][3:0], loc_input[D*15+201][3:0], loc_input[D*15+202][3:0], loc_input[D*15+203][3:0], loc_input[D*15+204][3:0], loc_input[D*15+205][3:0], loc_input[D*15+206][3:0], loc_input[D*15+207][3:0], loc_input[D*15+208][3:0], loc_input[D*15+209][3:0], loc_input[D*15+210][3:0], loc_input[D*15+211][3:0], loc_input[D*15+212][3:0], loc_input[D*15+213][3:0], loc_input[D*15+214][3:0], loc_input[D*15+215][3:0], loc_input[D*15+216][3:0], loc_input[D*15+217][3:0], loc_input[D*15+218][3:0], loc_input[D*15+219][3:0], loc_input[D*15+220][3:0], loc_input[D*15+221][3:0], loc_input[D*15+222][3:0], loc_input[D*15+223][3:0], loc_input[D*15+224][3:0], loc_input[D*15+225][3:0], loc_input[D*15+226][3:0], loc_input[D*15+227][3:0], loc_input[D*15+228][3:0], loc_input[D*15+229][3:0], loc_input[D*15+230][3:0], loc_input[D*15+231][3:0], loc_input[D*15+232][3:0], loc_input[D*15+233][3:0], loc_input[D*15+234][3:0], loc_input[D*15+235][3:0], loc_input[D*15+236][3:0], loc_input[D*15+237][3:0], loc_input[D*15+238][3:0], loc_input[D*15+239][3:0], loc_input[D*15+240][3:0], loc_input[D*15+241][3:0], loc_input[D*15+242][3:0], loc_input[D*15+243][3:0], loc_input[D*15+244][3:0], loc_input[D*15+245][3:0], loc_input[D*15+246][3:0], loc_input[D*15+247][3:0], loc_input[D*15+248][3:0], loc_input[D*15+249][3:0], loc_input[D*15+250][3:0], loc_input[D*15+251][3:0], loc_input[D*15+252][3:0], loc_input[D*15+253][3:0], loc_input[D*15+254][3:0], loc_input[D*15+255][3:0]}; 
        end else begin
            loc_rdata = {loc_input[D*(sub_bat-1)+0][3:0], loc_input[D*(sub_bat-1)+1][3:0], loc_input[D*(sub_bat-1)+2][3:0], loc_input[D*(sub_bat-1)+3][3:0], loc_input[D*(sub_bat-1)+4][3:0], loc_input[D*(sub_bat-1)+5][3:0], loc_input[D*(sub_bat-1)+6][3:0], loc_input[D*(sub_bat-1)+7][3:0], loc_input[D*(sub_bat-1)+8][3:0], loc_input[D*(sub_bat-1)+9][3:0], loc_input[D*(sub_bat-1)+10][3:0], loc_input[D*(sub_bat-1)+11][3:0], loc_input[D*(sub_bat-1)+12][3:0], loc_input[D*(sub_bat-1)+13][3:0], loc_input[D*(sub_bat-1)+14][3:0], loc_input[D*(sub_bat-1)+15][3:0], loc_input[D*(sub_bat-1)+16][3:0], loc_input[D*(sub_bat-1)+17][3:0], loc_input[D*(sub_bat-1)+18][3:0], loc_input[D*(sub_bat-1)+19][3:0], loc_input[D*(sub_bat-1)+20][3:0], loc_input[D*(sub_bat-1)+21][3:0], loc_input[D*(sub_bat-1)+22][3:0], loc_input[D*(sub_bat-1)+23][3:0], loc_input[D*(sub_bat-1)+24][3:0], loc_input[D*(sub_bat-1)+25][3:0], loc_input[D*(sub_bat-1)+26][3:0], loc_input[D*(sub_bat-1)+27][3:0], loc_input[D*(sub_bat-1)+28][3:0], loc_input[D*(sub_bat-1)+29][3:0], loc_input[D*(sub_bat-1)+30][3:0], loc_input[D*(sub_bat-1)+31][3:0], loc_input[D*(sub_bat-1)+32][3:0], loc_input[D*(sub_bat-1)+33][3:0], loc_input[D*(sub_bat-1)+34][3:0], loc_input[D*(sub_bat-1)+35][3:0], loc_input[D*(sub_bat-1)+36][3:0], loc_input[D*(sub_bat-1)+37][3:0], loc_input[D*(sub_bat-1)+38][3:0], loc_input[D*(sub_bat-1)+39][3:0], loc_input[D*(sub_bat-1)+40][3:0], loc_input[D*(sub_bat-1)+41][3:0], loc_input[D*(sub_bat-1)+42][3:0], loc_input[D*(sub_bat-1)+43][3:0], loc_input[D*(sub_bat-1)+44][3:0], loc_input[D*(sub_bat-1)+45][3:0], loc_input[D*(sub_bat-1)+46][3:0], loc_input[D*(sub_bat-1)+47][3:0], loc_input[D*(sub_bat-1)+48][3:0], loc_input[D*(sub_bat-1)+49][3:0], loc_input[D*(sub_bat-1)+50][3:0], loc_input[D*(sub_bat-1)+51][3:0], loc_input[D*(sub_bat-1)+52][3:0], loc_input[D*(sub_bat-1)+53][3:0], loc_input[D*(sub_bat-1)+54][3:0], loc_input[D*(sub_bat-1)+55][3:0], loc_input[D*(sub_bat-1)+56][3:0], loc_input[D*(sub_bat-1)+57][3:0], loc_input[D*(sub_bat-1)+58][3:0], loc_input[D*(sub_bat-1)+59][3:0], loc_input[D*(sub_bat-1)+60][3:0], loc_input[D*(sub_bat-1)+61][3:0], loc_input[D*(sub_bat-1)+62][3:0], loc_input[D*(sub_bat-1)+63][3:0], loc_input[D*(sub_bat-1)+64][3:0], loc_input[D*(sub_bat-1)+65][3:0], loc_input[D*(sub_bat-1)+66][3:0], loc_input[D*(sub_bat-1)+67][3:0], loc_input[D*(sub_bat-1)+68][3:0], loc_input[D*(sub_bat-1)+69][3:0], loc_input[D*(sub_bat-1)+70][3:0], loc_input[D*(sub_bat-1)+71][3:0], loc_input[D*(sub_bat-1)+72][3:0], loc_input[D*(sub_bat-1)+73][3:0], loc_input[D*(sub_bat-1)+74][3:0], loc_input[D*(sub_bat-1)+75][3:0], loc_input[D*(sub_bat-1)+76][3:0], loc_input[D*(sub_bat-1)+77][3:0], loc_input[D*(sub_bat-1)+78][3:0], loc_input[D*(sub_bat-1)+79][3:0], loc_input[D*(sub_bat-1)+80][3:0], loc_input[D*(sub_bat-1)+81][3:0], loc_input[D*(sub_bat-1)+82][3:0], loc_input[D*(sub_bat-1)+83][3:0], loc_input[D*(sub_bat-1)+84][3:0], loc_input[D*(sub_bat-1)+85][3:0], loc_input[D*(sub_bat-1)+86][3:0], loc_input[D*(sub_bat-1)+87][3:0], loc_input[D*(sub_bat-1)+88][3:0], loc_input[D*(sub_bat-1)+89][3:0], loc_input[D*(sub_bat-1)+90][3:0], loc_input[D*(sub_bat-1)+91][3:0], loc_input[D*(sub_bat-1)+92][3:0], loc_input[D*(sub_bat-1)+93][3:0], loc_input[D*(sub_bat-1)+94][3:0], loc_input[D*(sub_bat-1)+95][3:0], loc_input[D*(sub_bat-1)+96][3:0], loc_input[D*(sub_bat-1)+97][3:0], loc_input[D*(sub_bat-1)+98][3:0], loc_input[D*(sub_bat-1)+99][3:0], loc_input[D*(sub_bat-1)+100][3:0], loc_input[D*(sub_bat-1)+101][3:0], loc_input[D*(sub_bat-1)+102][3:0], loc_input[D*(sub_bat-1)+103][3:0], loc_input[D*(sub_bat-1)+104][3:0], loc_input[D*(sub_bat-1)+105][3:0], loc_input[D*(sub_bat-1)+106][3:0], loc_input[D*(sub_bat-1)+107][3:0], loc_input[D*(sub_bat-1)+108][3:0], loc_input[D*(sub_bat-1)+109][3:0], loc_input[D*(sub_bat-1)+110][3:0], loc_input[D*(sub_bat-1)+111][3:0], loc_input[D*(sub_bat-1)+112][3:0], loc_input[D*(sub_bat-1)+113][3:0], loc_input[D*(sub_bat-1)+114][3:0], loc_input[D*(sub_bat-1)+115][3:0], loc_input[D*(sub_bat-1)+116][3:0], loc_input[D*(sub_bat-1)+117][3:0], loc_input[D*(sub_bat-1)+118][3:0], loc_input[D*(sub_bat-1)+119][3:0], loc_input[D*(sub_bat-1)+120][3:0], loc_input[D*(sub_bat-1)+121][3:0], loc_input[D*(sub_bat-1)+122][3:0], loc_input[D*(sub_bat-1)+123][3:0], loc_input[D*(sub_bat-1)+124][3:0], loc_input[D*(sub_bat-1)+125][3:0], loc_input[D*(sub_bat-1)+126][3:0], loc_input[D*(sub_bat-1)+127][3:0], loc_input[D*(sub_bat-1)+128][3:0], loc_input[D*(sub_bat-1)+129][3:0], loc_input[D*(sub_bat-1)+130][3:0], loc_input[D*(sub_bat-1)+131][3:0], loc_input[D*(sub_bat-1)+132][3:0], loc_input[D*(sub_bat-1)+133][3:0], loc_input[D*(sub_bat-1)+134][3:0], loc_input[D*(sub_bat-1)+135][3:0], loc_input[D*(sub_bat-1)+136][3:0], loc_input[D*(sub_bat-1)+137][3:0], loc_input[D*(sub_bat-1)+138][3:0], loc_input[D*(sub_bat-1)+139][3:0], loc_input[D*(sub_bat-1)+140][3:0], loc_input[D*(sub_bat-1)+141][3:0], loc_input[D*(sub_bat-1)+142][3:0], loc_input[D*(sub_bat-1)+143][3:0], loc_input[D*(sub_bat-1)+144][3:0], loc_input[D*(sub_bat-1)+145][3:0], loc_input[D*(sub_bat-1)+146][3:0], loc_input[D*(sub_bat-1)+147][3:0], loc_input[D*(sub_bat-1)+148][3:0], loc_input[D*(sub_bat-1)+149][3:0], loc_input[D*(sub_bat-1)+150][3:0], loc_input[D*(sub_bat-1)+151][3:0], loc_input[D*(sub_bat-1)+152][3:0], loc_input[D*(sub_bat-1)+153][3:0], loc_input[D*(sub_bat-1)+154][3:0], loc_input[D*(sub_bat-1)+155][3:0], loc_input[D*(sub_bat-1)+156][3:0], loc_input[D*(sub_bat-1)+157][3:0], loc_input[D*(sub_bat-1)+158][3:0], loc_input[D*(sub_bat-1)+159][3:0], loc_input[D*(sub_bat-1)+160][3:0], loc_input[D*(sub_bat-1)+161][3:0], loc_input[D*(sub_bat-1)+162][3:0], loc_input[D*(sub_bat-1)+163][3:0], loc_input[D*(sub_bat-1)+164][3:0], loc_input[D*(sub_bat-1)+165][3:0], loc_input[D*(sub_bat-1)+166][3:0], loc_input[D*(sub_bat-1)+167][3:0], loc_input[D*(sub_bat-1)+168][3:0], loc_input[D*(sub_bat-1)+169][3:0], loc_input[D*(sub_bat-1)+170][3:0], loc_input[D*(sub_bat-1)+171][3:0], loc_input[D*(sub_bat-1)+172][3:0], loc_input[D*(sub_bat-1)+173][3:0], loc_input[D*(sub_bat-1)+174][3:0], loc_input[D*(sub_bat-1)+175][3:0], loc_input[D*(sub_bat-1)+176][3:0], loc_input[D*(sub_bat-1)+177][3:0], loc_input[D*(sub_bat-1)+178][3:0], loc_input[D*(sub_bat-1)+179][3:0], loc_input[D*(sub_bat-1)+180][3:0], loc_input[D*(sub_bat-1)+181][3:0], loc_input[D*(sub_bat-1)+182][3:0], loc_input[D*(sub_bat-1)+183][3:0], loc_input[D*(sub_bat-1)+184][3:0], loc_input[D*(sub_bat-1)+185][3:0], loc_input[D*(sub_bat-1)+186][3:0], loc_input[D*(sub_bat-1)+187][3:0], loc_input[D*(sub_bat-1)+188][3:0], loc_input[D*(sub_bat-1)+189][3:0], loc_input[D*(sub_bat-1)+190][3:0], loc_input[D*(sub_bat-1)+191][3:0], loc_input[D*(sub_bat-1)+192][3:0], loc_input[D*(sub_bat-1)+193][3:0], loc_input[D*(sub_bat-1)+194][3:0], loc_input[D*(sub_bat-1)+195][3:0], loc_input[D*(sub_bat-1)+196][3:0], loc_input[D*(sub_bat-1)+197][3:0], loc_input[D*(sub_bat-1)+198][3:0], loc_input[D*(sub_bat-1)+199][3:0], loc_input[D*(sub_bat-1)+200][3:0], loc_input[D*(sub_bat-1)+201][3:0], loc_input[D*(sub_bat-1)+202][3:0], loc_input[D*(sub_bat-1)+203][3:0], loc_input[D*(sub_bat-1)+204][3:0], loc_input[D*(sub_bat-1)+205][3:0], loc_input[D*(sub_bat-1)+206][3:0], loc_input[D*(sub_bat-1)+207][3:0], loc_input[D*(sub_bat-1)+208][3:0], loc_input[D*(sub_bat-1)+209][3:0], loc_input[D*(sub_bat-1)+210][3:0], loc_input[D*(sub_bat-1)+211][3:0], loc_input[D*(sub_bat-1)+212][3:0], loc_input[D*(sub_bat-1)+213][3:0], loc_input[D*(sub_bat-1)+214][3:0], loc_input[D*(sub_bat-1)+215][3:0], loc_input[D*(sub_bat-1)+216][3:0], loc_input[D*(sub_bat-1)+217][3:0], loc_input[D*(sub_bat-1)+218][3:0], loc_input[D*(sub_bat-1)+219][3:0], loc_input[D*(sub_bat-1)+220][3:0], loc_input[D*(sub_bat-1)+221][3:0], loc_input[D*(sub_bat-1)+222][3:0], loc_input[D*(sub_bat-1)+223][3:0], loc_input[D*(sub_bat-1)+224][3:0], loc_input[D*(sub_bat-1)+225][3:0], loc_input[D*(sub_bat-1)+226][3:0], loc_input[D*(sub_bat-1)+227][3:0], loc_input[D*(sub_bat-1)+228][3:0], loc_input[D*(sub_bat-1)+229][3:0], loc_input[D*(sub_bat-1)+230][3:0], loc_input[D*(sub_bat-1)+231][3:0], loc_input[D*(sub_bat-1)+232][3:0], loc_input[D*(sub_bat-1)+233][3:0], loc_input[D*(sub_bat-1)+234][3:0], loc_input[D*(sub_bat-1)+235][3:0], loc_input[D*(sub_bat-1)+236][3:0], loc_input[D*(sub_bat-1)+237][3:0], loc_input[D*(sub_bat-1)+238][3:0], loc_input[D*(sub_bat-1)+239][3:0], loc_input[D*(sub_bat-1)+240][3:0], loc_input[D*(sub_bat-1)+241][3:0], loc_input[D*(sub_bat-1)+242][3:0], loc_input[D*(sub_bat-1)+243][3:0], loc_input[D*(sub_bat-1)+244][3:0], loc_input[D*(sub_bat-1)+245][3:0], loc_input[D*(sub_bat-1)+246][3:0], loc_input[D*(sub_bat-1)+247][3:0], loc_input[D*(sub_bat-1)+248][3:0], loc_input[D*(sub_bat-1)+249][3:0], loc_input[D*(sub_bat-1)+250][3:0], loc_input[D*(sub_bat-1)+251][3:0], loc_input[D*(sub_bat-1)+252][3:0], loc_input[D*(sub_bat-1)+253][3:0], loc_input[D*(sub_bat-1)+254][3:0], loc_input[D*(sub_bat-1)+255][3:0]};
        end
        if(ready == 1 && batch > 0) begin    
            // part[k] for a sub-batch finish
            $write("batch %d sub-batch %d :", batch, sub_bat);
            for(i = 0; i < K; i = i + 1) begin 
                $write("%h ", worker_instn.worker_0.part_reg[i]);
            end 
            
             if(part_gold[batch - 1] !== {
                 worker_instn.worker_0.part_reg[0],worker_instn.worker_0.part_reg[1],worker_instn.worker_0.part_reg[2],worker_instn.worker_0.part_reg[3],worker_instn.worker_0.part_reg[4],worker_instn.worker_0.part_reg[5],worker_instn.worker_0.part_reg[6],worker_instn.worker_0.part_reg[7],worker_instn.worker_0.part_reg[8],worker_instn.worker_0.part_reg[9],worker_instn.worker_0.part_reg[10],worker_instn.worker_0.part_reg[11],worker_instn.worker_0.part_reg[12],worker_instn.worker_0.part_reg[13],worker_instn.worker_0.part_reg[14],worker_instn.worker_0.part_reg[15]
             }) begin 
                $write("gold :: %h\n", part_gold[batch - 1]);
             end
            // TODO 
//            if (batch == 2) begin
//                $finish;
//            end
        end
        if(worker_instn.wen == 1) begin
            $write("| next: %h with mask: %b | proposal: %h with mask: %b|\n", next_wdata, next_bytemask, pro_wdata, pro_bytemask);
            // (next_wdata & ~(bit_mask))
            check_sub = check_sub + 1;
        end 

        
    end 
    enable = 0;
    //    $write("\nbat: %d\n",batch);
    $write("SRAM dump:\n");
    for(sram_i = 0; sram_i < 16; sram_i = sram_i + 1) begin
        if(w0_next_sram_256x4b.mem[sram_i] !== next_gold[sram_i]) begin 
            $write("FAIL next sram[%d]: %h vs gold: %h\n", sram_i, 
            w0_next_sram_256x4b.mem[sram_i], next_gold[sram_i]);
//            $finish;
        end 
        if(w0_proposal_sram_16x128b.mem[sram_i] !== pro_gold[sram_i]) begin 
            $write("FAIL proposal sram[%d]: %h vs gold: %h\n", sram_i, w0_proposal_sram_16x128b.mem[sram_i], pro_gold[sram_i]);
//            $finish;
        end 
    end 
    $write("\n");
    $finish;
end 

initial begin 
    #(CYCLE*100000);
    $finish;
end 
endmodule
