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
// worker_sram #(.WORK_IDX(15)) worker_instn(
//     .clk(clk),
//     .en(enable),
//     .rst_n(~rst_n),
//     .batch_num(batch[7:0]),
//     .vid_sram_rdata(vid_sram_rdata0),// .vid_rdata(vid_rdata),
//     .dist_sram_rdata(dist_sram_rdata0),// .dist_rdata(dist_rdata),
//     .loc_rdata(loc_rdata),
//     // output 
//     .sub_bat(sub_bat),
//     .vid_sram_raddr(vid_sram_raddr0)// .vid(vid), // for indexing the Dist
//     .dist_sram_raddr(dist_sram_raddr0),
//     .next_bytemask(next_bytemask),
//     .next_wdata(next_wdata),
//     .next_waddr(next_waddr),
//     .pro_bytemask(pro_bytemask),
//     .pro_wdata(pro_wdata),
//     .pro_waddr(pro_waddr),
//     .ready(ready),
//     .batch_finish(batch_finish),
//     .wen(worker_wen)
// );

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

// initial begin
// 	$fsdbDumpfile("proj_presim_worker_temp.fsdb");
// 	$fsdbDumpvars("+mda");
// end

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
    $write("loading dist to sram");
    for(idxr = testworkerid * 256 * 16 ; idxr < testworkerid * 256 * 16 + 16; idxr = idxr + 1) 
        w0_dist_sram_NxNb.load_param(idxr, dist_input[idxr]);
    $write("RRRRRR\n");
    $readmemh("../software/gold/loc.dat", loc_input);
    $write("loc %h\n", loc_input[4095]);
    $readmemh("../software/gold/15_bat_part.dat", part_gold); // only batch number 0's 16 sub-batch's part[0-K] 
    $write("part %h\n", part_gold[1]);
    $readmemh("../software/gold/15_next.dat", next_gold);
    $write("next 15 %h\n", next_gold[15]);
    $readmemh("../software/gold/15_proposal_num.dat", pro_gold);
    $write("proposal_num 15 %h\n", pro_gold[15]);
    $finish;

    #(CYCLE) rst_n = 1; 
    #(CYCLE) enable = 1'b1;
    rst_n = 0;    
    batch = 0;
    // sub_bat = 0;
    loc_rdata = {loc_input[D*sub_bat+0][3:0], loc_input[D*sub_bat+1][3:0], loc_input[D*sub_bat+2][3:0], loc_input[D*sub_bat+3][3:0], loc_input[D*sub_bat+4][3:0], loc_input[D*sub_bat+5][3:0], loc_input[D*sub_bat+6][3:0], loc_input[D*sub_bat+7][3:0], loc_input[D*sub_bat+8][3:0], loc_input[D*sub_bat+9][3:0], loc_input[D*sub_bat+10][3:0], loc_input[D*sub_bat+11][3:0], loc_input[D*sub_bat+12][3:0], loc_input[D*sub_bat+13][3:0], loc_input[D*sub_bat+14][3:0], loc_input[D*sub_bat+15][3:0], loc_input[D*sub_bat+16][3:0], loc_input[D*sub_bat+17][3:0], loc_input[D*sub_bat+18][3:0], loc_input[D*sub_bat+19][3:0], loc_input[D*sub_bat+20][3:0], loc_input[D*sub_bat+21][3:0], loc_input[D*sub_bat+22][3:0], loc_input[D*sub_bat+23][3:0], loc_input[D*sub_bat+24][3:0], loc_input[D*sub_bat+25][3:0], loc_input[D*sub_bat+26][3:0], loc_input[D*sub_bat+27][3:0], loc_input[D*sub_bat+28][3:0], loc_input[D*sub_bat+29][3:0], loc_input[D*sub_bat+30][3:0], loc_input[D*sub_bat+31][3:0], loc_input[D*sub_bat+32][3:0], loc_input[D*sub_bat+33][3:0], loc_input[D*sub_bat+34][3:0], loc_input[D*sub_bat+35][3:0], loc_input[D*sub_bat+36][3:0], loc_input[D*sub_bat+37][3:0], loc_input[D*sub_bat+38][3:0], loc_input[D*sub_bat+39][3:0], loc_input[D*sub_bat+40][3:0], loc_input[D*sub_bat+41][3:0], loc_input[D*sub_bat+42][3:0], loc_input[D*sub_bat+43][3:0], loc_input[D*sub_bat+44][3:0], loc_input[D*sub_bat+45][3:0], loc_input[D*sub_bat+46][3:0], loc_input[D*sub_bat+47][3:0], loc_input[D*sub_bat+48][3:0], loc_input[D*sub_bat+49][3:0], loc_input[D*sub_bat+50][3:0], loc_input[D*sub_bat+51][3:0], loc_input[D*sub_bat+52][3:0], loc_input[D*sub_bat+53][3:0], loc_input[D*sub_bat+54][3:0], loc_input[D*sub_bat+55][3:0], loc_input[D*sub_bat+56][3:0], loc_input[D*sub_bat+57][3:0], loc_input[D*sub_bat+58][3:0], loc_input[D*sub_bat+59][3:0], loc_input[D*sub_bat+60][3:0], loc_input[D*sub_bat+61][3:0], loc_input[D*sub_bat+62][3:0], loc_input[D*sub_bat+63][3:0], loc_input[D*sub_bat+64][3:0], loc_input[D*sub_bat+65][3:0], loc_input[D*sub_bat+66][3:0], loc_input[D*sub_bat+67][3:0], loc_input[D*sub_bat+68][3:0], loc_input[D*sub_bat+69][3:0], loc_input[D*sub_bat+70][3:0], loc_input[D*sub_bat+71][3:0], loc_input[D*sub_bat+72][3:0], loc_input[D*sub_bat+73][3:0], loc_input[D*sub_bat+74][3:0], loc_input[D*sub_bat+75][3:0], loc_input[D*sub_bat+76][3:0], loc_input[D*sub_bat+77][3:0], loc_input[D*sub_bat+78][3:0], loc_input[D*sub_bat+79][3:0], loc_input[D*sub_bat+80][3:0], loc_input[D*sub_bat+81][3:0], loc_input[D*sub_bat+82][3:0], loc_input[D*sub_bat+83][3:0], loc_input[D*sub_bat+84][3:0], loc_input[D*sub_bat+85][3:0], loc_input[D*sub_bat+86][3:0], loc_input[D*sub_bat+87][3:0], loc_input[D*sub_bat+88][3:0], loc_input[D*sub_bat+89][3:0], loc_input[D*sub_bat+90][3:0], loc_input[D*sub_bat+91][3:0], loc_input[D*sub_bat+92][3:0], loc_input[D*sub_bat+93][3:0], loc_input[D*sub_bat+94][3:0], loc_input[D*sub_bat+95][3:0], loc_input[D*sub_bat+96][3:0], loc_input[D*sub_bat+97][3:0], loc_input[D*sub_bat+98][3:0], loc_input[D*sub_bat+99][3:0], loc_input[D*sub_bat+100][3:0], loc_input[D*sub_bat+101][3:0], loc_input[D*sub_bat+102][3:0], loc_input[D*sub_bat+103][3:0], loc_input[D*sub_bat+104][3:0], loc_input[D*sub_bat+105][3:0], loc_input[D*sub_bat+106][3:0], loc_input[D*sub_bat+107][3:0], loc_input[D*sub_bat+108][3:0], loc_input[D*sub_bat+109][3:0], loc_input[D*sub_bat+110][3:0], loc_input[D*sub_bat+111][3:0], loc_input[D*sub_bat+112][3:0], loc_input[D*sub_bat+113][3:0], loc_input[D*sub_bat+114][3:0], loc_input[D*sub_bat+115][3:0], loc_input[D*sub_bat+116][3:0], loc_input[D*sub_bat+117][3:0], loc_input[D*sub_bat+118][3:0], loc_input[D*sub_bat+119][3:0], loc_input[D*sub_bat+120][3:0], loc_input[D*sub_bat+121][3:0], loc_input[D*sub_bat+122][3:0], loc_input[D*sub_bat+123][3:0], loc_input[D*sub_bat+124][3:0], loc_input[D*sub_bat+125][3:0], loc_input[D*sub_bat+126][3:0], loc_input[D*sub_bat+127][3:0], loc_input[D*sub_bat+128][3:0], loc_input[D*sub_bat+129][3:0], loc_input[D*sub_bat+130][3:0], loc_input[D*sub_bat+131][3:0], loc_input[D*sub_bat+132][3:0], loc_input[D*sub_bat+133][3:0], loc_input[D*sub_bat+134][3:0], loc_input[D*sub_bat+135][3:0], loc_input[D*sub_bat+136][3:0], loc_input[D*sub_bat+137][3:0], loc_input[D*sub_bat+138][3:0], loc_input[D*sub_bat+139][3:0], loc_input[D*sub_bat+140][3:0], loc_input[D*sub_bat+141][3:0], loc_input[D*sub_bat+142][3:0], loc_input[D*sub_bat+143][3:0], loc_input[D*sub_bat+144][3:0], loc_input[D*sub_bat+145][3:0], loc_input[D*sub_bat+146][3:0], loc_input[D*sub_bat+147][3:0], loc_input[D*sub_bat+148][3:0], loc_input[D*sub_bat+149][3:0], loc_input[D*sub_bat+150][3:0], loc_input[D*sub_bat+151][3:0], loc_input[D*sub_bat+152][3:0], loc_input[D*sub_bat+153][3:0], loc_input[D*sub_bat+154][3:0], loc_input[D*sub_bat+155][3:0], loc_input[D*sub_bat+156][3:0], loc_input[D*sub_bat+157][3:0], loc_input[D*sub_bat+158][3:0], loc_input[D*sub_bat+159][3:0], loc_input[D*sub_bat+160][3:0], loc_input[D*sub_bat+161][3:0], loc_input[D*sub_bat+162][3:0], loc_input[D*sub_bat+163][3:0], loc_input[D*sub_bat+164][3:0], loc_input[D*sub_bat+165][3:0], loc_input[D*sub_bat+166][3:0], loc_input[D*sub_bat+167][3:0], loc_input[D*sub_bat+168][3:0], loc_input[D*sub_bat+169][3:0], loc_input[D*sub_bat+170][3:0], loc_input[D*sub_bat+171][3:0], loc_input[D*sub_bat+172][3:0], loc_input[D*sub_bat+173][3:0], loc_input[D*sub_bat+174][3:0], loc_input[D*sub_bat+175][3:0], loc_input[D*sub_bat+176][3:0], loc_input[D*sub_bat+177][3:0], loc_input[D*sub_bat+178][3:0], loc_input[D*sub_bat+179][3:0], loc_input[D*sub_bat+180][3:0], loc_input[D*sub_bat+181][3:0], loc_input[D*sub_bat+182][3:0], loc_input[D*sub_bat+183][3:0], loc_input[D*sub_bat+184][3:0], loc_input[D*sub_bat+185][3:0], loc_input[D*sub_bat+186][3:0], loc_input[D*sub_bat+187][3:0], loc_input[D*sub_bat+188][3:0], loc_input[D*sub_bat+189][3:0], loc_input[D*sub_bat+190][3:0], loc_input[D*sub_bat+191][3:0], loc_input[D*sub_bat+192][3:0], loc_input[D*sub_bat+193][3:0], loc_input[D*sub_bat+194][3:0], loc_input[D*sub_bat+195][3:0], loc_input[D*sub_bat+196][3:0], loc_input[D*sub_bat+197][3:0], loc_input[D*sub_bat+198][3:0], loc_input[D*sub_bat+199][3:0], loc_input[D*sub_bat+200][3:0], loc_input[D*sub_bat+201][3:0], loc_input[D*sub_bat+202][3:0], loc_input[D*sub_bat+203][3:0], loc_input[D*sub_bat+204][3:0], loc_input[D*sub_bat+205][3:0], loc_input[D*sub_bat+206][3:0], loc_input[D*sub_bat+207][3:0], loc_input[D*sub_bat+208][3:0], loc_input[D*sub_bat+209][3:0], loc_input[D*sub_bat+210][3:0], loc_input[D*sub_bat+211][3:0], loc_input[D*sub_bat+212][3:0], loc_input[D*sub_bat+213][3:0], loc_input[D*sub_bat+214][3:0], loc_input[D*sub_bat+215][3:0], loc_input[D*sub_bat+216][3:0], loc_input[D*sub_bat+217][3:0], loc_input[D*sub_bat+218][3:0], loc_input[D*sub_bat+219][3:0], loc_input[D*sub_bat+220][3:0], loc_input[D*sub_bat+221][3:0], loc_input[D*sub_bat+222][3:0], loc_input[D*sub_bat+223][3:0], loc_input[D*sub_bat+224][3:0], loc_input[D*sub_bat+225][3:0], loc_input[D*sub_bat+226][3:0], loc_input[D*sub_bat+227][3:0], loc_input[D*sub_bat+228][3:0], loc_input[D*sub_bat+229][3:0], loc_input[D*sub_bat+230][3:0], loc_input[D*sub_bat+231][3:0], loc_input[D*sub_bat+232][3:0], loc_input[D*sub_bat+233][3:0], loc_input[D*sub_bat+234][3:0], loc_input[D*sub_bat+235][3:0], loc_input[D*sub_bat+236][3:0], loc_input[D*sub_bat+237][3:0], loc_input[D*sub_bat+238][3:0], loc_input[D*sub_bat+239][3:0], loc_input[D*sub_bat+240][3:0], loc_input[D*sub_bat+241][3:0], loc_input[D*sub_bat+242][3:0], loc_input[D*sub_bat+243][3:0], loc_input[D*sub_bat+244][3:0], loc_input[D*sub_bat+245][3:0], loc_input[D*sub_bat+246][3:0], loc_input[D*sub_bat+247][3:0], loc_input[D*sub_bat+248][3:0], loc_input[D*sub_bat+249][3:0], loc_input[D*sub_bat+250][3:0], loc_input[D*sub_bat+251][3:0], loc_input[D*sub_bat+252][3:0], loc_input[D*sub_bat+253][3:0], loc_input[D*sub_bat+254][3:0], loc_input[D*sub_bat+255][3:0]};
end 
integer loadidx;
initial begin  
    wait(enable == 1);
    while(idxr < 65536) begin 
        @(negedge clk);
        for(loadidx = 0; loadidx < 16; loadidx = loadidx + 1) begin 
            w0_dist_sram_NxNb.load_param(idxr, dist_input[idxr]);
            idxr = idxr + 1;
        end 
    end 
end 
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
        loc_rdata = {loc_input[D*sub_bat+0][3:0], loc_input[D*sub_bat+1][3:0], loc_input[D*sub_bat+2][3:0], loc_input[D*sub_bat+3][3:0], loc_input[D*sub_bat+4][3:0], loc_input[D*sub_bat+5][3:0], loc_input[D*sub_bat+6][3:0], loc_input[D*sub_bat+7][3:0], loc_input[D*sub_bat+8][3:0], loc_input[D*sub_bat+9][3:0], loc_input[D*sub_bat+10][3:0], loc_input[D*sub_bat+11][3:0], loc_input[D*sub_bat+12][3:0], loc_input[D*sub_bat+13][3:0], loc_input[D*sub_bat+14][3:0], loc_input[D*sub_bat+15][3:0], loc_input[D*sub_bat+16][3:0], loc_input[D*sub_bat+17][3:0], loc_input[D*sub_bat+18][3:0], loc_input[D*sub_bat+19][3:0], loc_input[D*sub_bat+20][3:0], loc_input[D*sub_bat+21][3:0], loc_input[D*sub_bat+22][3:0], loc_input[D*sub_bat+23][3:0], loc_input[D*sub_bat+24][3:0], loc_input[D*sub_bat+25][3:0], loc_input[D*sub_bat+26][3:0], loc_input[D*sub_bat+27][3:0], loc_input[D*sub_bat+28][3:0], loc_input[D*sub_bat+29][3:0], loc_input[D*sub_bat+30][3:0], loc_input[D*sub_bat+31][3:0], loc_input[D*sub_bat+32][3:0], loc_input[D*sub_bat+33][3:0], loc_input[D*sub_bat+34][3:0], loc_input[D*sub_bat+35][3:0], loc_input[D*sub_bat+36][3:0], loc_input[D*sub_bat+37][3:0], loc_input[D*sub_bat+38][3:0], loc_input[D*sub_bat+39][3:0], loc_input[D*sub_bat+40][3:0], loc_input[D*sub_bat+41][3:0], loc_input[D*sub_bat+42][3:0], loc_input[D*sub_bat+43][3:0], loc_input[D*sub_bat+44][3:0], loc_input[D*sub_bat+45][3:0], loc_input[D*sub_bat+46][3:0], loc_input[D*sub_bat+47][3:0], loc_input[D*sub_bat+48][3:0], loc_input[D*sub_bat+49][3:0], loc_input[D*sub_bat+50][3:0], loc_input[D*sub_bat+51][3:0], loc_input[D*sub_bat+52][3:0], loc_input[D*sub_bat+53][3:0], loc_input[D*sub_bat+54][3:0], loc_input[D*sub_bat+55][3:0], loc_input[D*sub_bat+56][3:0], loc_input[D*sub_bat+57][3:0], loc_input[D*sub_bat+58][3:0], loc_input[D*sub_bat+59][3:0], loc_input[D*sub_bat+60][3:0], loc_input[D*sub_bat+61][3:0], loc_input[D*sub_bat+62][3:0], loc_input[D*sub_bat+63][3:0], loc_input[D*sub_bat+64][3:0], loc_input[D*sub_bat+65][3:0], loc_input[D*sub_bat+66][3:0], loc_input[D*sub_bat+67][3:0], loc_input[D*sub_bat+68][3:0], loc_input[D*sub_bat+69][3:0], loc_input[D*sub_bat+70][3:0], loc_input[D*sub_bat+71][3:0], loc_input[D*sub_bat+72][3:0], loc_input[D*sub_bat+73][3:0], loc_input[D*sub_bat+74][3:0], loc_input[D*sub_bat+75][3:0], loc_input[D*sub_bat+76][3:0], loc_input[D*sub_bat+77][3:0], loc_input[D*sub_bat+78][3:0], loc_input[D*sub_bat+79][3:0], loc_input[D*sub_bat+80][3:0], loc_input[D*sub_bat+81][3:0], loc_input[D*sub_bat+82][3:0], loc_input[D*sub_bat+83][3:0], loc_input[D*sub_bat+84][3:0], loc_input[D*sub_bat+85][3:0], loc_input[D*sub_bat+86][3:0], loc_input[D*sub_bat+87][3:0], loc_input[D*sub_bat+88][3:0], loc_input[D*sub_bat+89][3:0], loc_input[D*sub_bat+90][3:0], loc_input[D*sub_bat+91][3:0], loc_input[D*sub_bat+92][3:0], loc_input[D*sub_bat+93][3:0], loc_input[D*sub_bat+94][3:0], loc_input[D*sub_bat+95][3:0], loc_input[D*sub_bat+96][3:0], loc_input[D*sub_bat+97][3:0], loc_input[D*sub_bat+98][3:0], loc_input[D*sub_bat+99][3:0], loc_input[D*sub_bat+100][3:0], loc_input[D*sub_bat+101][3:0], loc_input[D*sub_bat+102][3:0], loc_input[D*sub_bat+103][3:0], loc_input[D*sub_bat+104][3:0], loc_input[D*sub_bat+105][3:0], loc_input[D*sub_bat+106][3:0], loc_input[D*sub_bat+107][3:0], loc_input[D*sub_bat+108][3:0], loc_input[D*sub_bat+109][3:0], loc_input[D*sub_bat+110][3:0], loc_input[D*sub_bat+111][3:0], loc_input[D*sub_bat+112][3:0], loc_input[D*sub_bat+113][3:0], loc_input[D*sub_bat+114][3:0], loc_input[D*sub_bat+115][3:0], loc_input[D*sub_bat+116][3:0], loc_input[D*sub_bat+117][3:0], loc_input[D*sub_bat+118][3:0], loc_input[D*sub_bat+119][3:0], loc_input[D*sub_bat+120][3:0], loc_input[D*sub_bat+121][3:0], loc_input[D*sub_bat+122][3:0], loc_input[D*sub_bat+123][3:0], loc_input[D*sub_bat+124][3:0], loc_input[D*sub_bat+125][3:0], loc_input[D*sub_bat+126][3:0], loc_input[D*sub_bat+127][3:0], loc_input[D*sub_bat+128][3:0], loc_input[D*sub_bat+129][3:0], loc_input[D*sub_bat+130][3:0], loc_input[D*sub_bat+131][3:0], loc_input[D*sub_bat+132][3:0], loc_input[D*sub_bat+133][3:0], loc_input[D*sub_bat+134][3:0], loc_input[D*sub_bat+135][3:0], loc_input[D*sub_bat+136][3:0], loc_input[D*sub_bat+137][3:0], loc_input[D*sub_bat+138][3:0], loc_input[D*sub_bat+139][3:0], loc_input[D*sub_bat+140][3:0], loc_input[D*sub_bat+141][3:0], loc_input[D*sub_bat+142][3:0], loc_input[D*sub_bat+143][3:0], loc_input[D*sub_bat+144][3:0], loc_input[D*sub_bat+145][3:0], loc_input[D*sub_bat+146][3:0], loc_input[D*sub_bat+147][3:0], loc_input[D*sub_bat+148][3:0], loc_input[D*sub_bat+149][3:0], loc_input[D*sub_bat+150][3:0], loc_input[D*sub_bat+151][3:0], loc_input[D*sub_bat+152][3:0], loc_input[D*sub_bat+153][3:0], loc_input[D*sub_bat+154][3:0], loc_input[D*sub_bat+155][3:0], loc_input[D*sub_bat+156][3:0], loc_input[D*sub_bat+157][3:0], loc_input[D*sub_bat+158][3:0], loc_input[D*sub_bat+159][3:0], loc_input[D*sub_bat+160][3:0], loc_input[D*sub_bat+161][3:0], loc_input[D*sub_bat+162][3:0], loc_input[D*sub_bat+163][3:0], loc_input[D*sub_bat+164][3:0], loc_input[D*sub_bat+165][3:0], loc_input[D*sub_bat+166][3:0], loc_input[D*sub_bat+167][3:0], loc_input[D*sub_bat+168][3:0], loc_input[D*sub_bat+169][3:0], loc_input[D*sub_bat+170][3:0], loc_input[D*sub_bat+171][3:0], loc_input[D*sub_bat+172][3:0], loc_input[D*sub_bat+173][3:0], loc_input[D*sub_bat+174][3:0], loc_input[D*sub_bat+175][3:0], loc_input[D*sub_bat+176][3:0], loc_input[D*sub_bat+177][3:0], loc_input[D*sub_bat+178][3:0], loc_input[D*sub_bat+179][3:0], loc_input[D*sub_bat+180][3:0], loc_input[D*sub_bat+181][3:0], loc_input[D*sub_bat+182][3:0], loc_input[D*sub_bat+183][3:0], loc_input[D*sub_bat+184][3:0], loc_input[D*sub_bat+185][3:0], loc_input[D*sub_bat+186][3:0], loc_input[D*sub_bat+187][3:0], loc_input[D*sub_bat+188][3:0], loc_input[D*sub_bat+189][3:0], loc_input[D*sub_bat+190][3:0], loc_input[D*sub_bat+191][3:0], loc_input[D*sub_bat+192][3:0], loc_input[D*sub_bat+193][3:0], loc_input[D*sub_bat+194][3:0], loc_input[D*sub_bat+195][3:0], loc_input[D*sub_bat+196][3:0], loc_input[D*sub_bat+197][3:0], loc_input[D*sub_bat+198][3:0], loc_input[D*sub_bat+199][3:0], loc_input[D*sub_bat+200][3:0], loc_input[D*sub_bat+201][3:0], loc_input[D*sub_bat+202][3:0], loc_input[D*sub_bat+203][3:0], loc_input[D*sub_bat+204][3:0], loc_input[D*sub_bat+205][3:0], loc_input[D*sub_bat+206][3:0], loc_input[D*sub_bat+207][3:0], loc_input[D*sub_bat+208][3:0], loc_input[D*sub_bat+209][3:0], loc_input[D*sub_bat+210][3:0], loc_input[D*sub_bat+211][3:0], loc_input[D*sub_bat+212][3:0], loc_input[D*sub_bat+213][3:0], loc_input[D*sub_bat+214][3:0], loc_input[D*sub_bat+215][3:0], loc_input[D*sub_bat+216][3:0], loc_input[D*sub_bat+217][3:0], loc_input[D*sub_bat+218][3:0], loc_input[D*sub_bat+219][3:0], loc_input[D*sub_bat+220][3:0], loc_input[D*sub_bat+221][3:0], loc_input[D*sub_bat+222][3:0], loc_input[D*sub_bat+223][3:0], loc_input[D*sub_bat+224][3:0], loc_input[D*sub_bat+225][3:0], loc_input[D*sub_bat+226][3:0], loc_input[D*sub_bat+227][3:0], loc_input[D*sub_bat+228][3:0], loc_input[D*sub_bat+229][3:0], loc_input[D*sub_bat+230][3:0], loc_input[D*sub_bat+231][3:0], loc_input[D*sub_bat+232][3:0], loc_input[D*sub_bat+233][3:0], loc_input[D*sub_bat+234][3:0], loc_input[D*sub_bat+235][3:0], loc_input[D*sub_bat+236][3:0], loc_input[D*sub_bat+237][3:0], loc_input[D*sub_bat+238][3:0], loc_input[D*sub_bat+239][3:0], loc_input[D*sub_bat+240][3:0], loc_input[D*sub_bat+241][3:0], loc_input[D*sub_bat+242][3:0], loc_input[D*sub_bat+243][3:0], loc_input[D*sub_bat+244][3:0], loc_input[D*sub_bat+245][3:0], loc_input[D*sub_bat+246][3:0], loc_input[D*sub_bat+247][3:0], loc_input[D*sub_bat+248][3:0], loc_input[D*sub_bat+249][3:0], loc_input[D*sub_bat+250][3:0], loc_input[D*sub_bat+251][3:0], loc_input[D*sub_bat+252][3:0], loc_input[D*sub_bat+253][3:0], loc_input[D*sub_bat+254][3:0], loc_input[D*sub_bat+255][3:0]};
        if(ready == 1 && batch > 0) begin    
            // part[k] for a sub-batch finish
            $write("batch %d sub-batch %d :", batch, sub_bat);
            for(i = 0; i < K; i = i + 1) begin 
                $write("%h ", worker_instn.part_reg[i]);
            end 
            
            if(part_gold[batch - 1] !== {
                worker_instn.part_reg[0],worker_instn.part_reg[1],worker_instn.part_reg[2],worker_instn.part_reg[3],worker_instn.part_reg[4],worker_instn.part_reg[5],worker_instn.part_reg[6],worker_instn.part_reg[7],worker_instn.part_reg[8],worker_instn.part_reg[9],worker_instn.part_reg[10],worker_instn.part_reg[11],worker_instn.part_reg[12],worker_instn.part_reg[13],worker_instn.part_reg[14],worker_instn.part_reg[15]
            }) begin 
                $write("gold :: %h\n", part_gold[batch - 1]);
            // TODO 
            $finish;
            end 
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
            $finish;
        end 
        if(w0_proposal_sram_16x128b.mem[sram_i] !== pro_gold[sram_i]) begin 
            $write("FAIL proposal sram[%d]: %h vs gold: %h\n", sram_i, w0_proposal_sram_16x128b.mem[sram_i], pro_gold[sram_i]);
            $finish;
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
