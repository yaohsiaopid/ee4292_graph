// `timescale 1ns/100ps
module test_master;
localparam N = 4096;
localparam K = 16;
localparam NEXT_BW = 4;
localparam PRO_BW = 8;
localparam VID_BW = 16;
localparam Q = 16; 
localparam MAX_EPOCH = 256; // 4096 / 16
localparam VID_ADDR_SPACE = 4;
real CYCLE = 10;
integer fptr;
//====== module I/O =====
reg clk;
reg rst_n;
reg enable;

// input, assign from gold 
reg [NEXT_BW*Q-1:0] in_next_arr;
reg [PRO_BW*K-1:0] in_mi_j; 
reg [PRO_BW*K-1:0] in_mj_i; 
reg [VID_BW*Q-1:0] in_v_gidx; 
reg [PRO_BW*Q-1:0] in_proposal_nums;

// output 
wire master_finish;
wire [7:0] epoch;
wire [K-1:0] vidsram_wen; // 0 at MSB  
wire ready; // TODO: if ready == 1 , check at negedge clk     
// =================== instance sram ================================
// graph.py to gen
wire [VID_BW*Q-1:0] vid_sram_wdata0,vid_sram_wdata1,vid_sram_wdata2,vid_sram_wdata3,vid_sram_wdata4,vid_sram_wdata5,vid_sram_wdata6,vid_sram_wdata7,vid_sram_wdata8,vid_sram_wdata9,vid_sram_wdata10,vid_sram_wdata11,vid_sram_wdata12,vid_sram_wdata13,vid_sram_wdata14,vid_sram_wdata15;
wire [VID_ADDR_SPACE-1:0] vid_sram_raddr, vid_sram_waddr0,vid_sram_waddr1,vid_sram_waddr2,vid_sram_waddr3,vid_sram_waddr4,vid_sram_waddr5,vid_sram_waddr6,vid_sram_waddr7,vid_sram_waddr8,vid_sram_waddr9,vid_sram_waddr10,vid_sram_waddr11,vid_sram_waddr12,vid_sram_waddr13,vid_sram_waddr14,vid_sram_waddr15;
wire [VID_BW*Q-1:0] vid_sram_rdata0,vid_sram_rdata1,vid_sram_rdata2,vid_sram_rdata3,vid_sram_rdata4,vid_sram_rdata5,vid_sram_rdata6,vid_sram_rdata7,vid_sram_rdata8,vid_sram_rdata9,vid_sram_rdata10,vid_sram_rdata11,vid_sram_rdata12,vid_sram_rdata13,vid_sram_rdata14,vid_sram_rdata15;
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w0_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[0]), .wdata(vid_sram_wdata0), .waddr(vid_sram_waddr0), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata0));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w1_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[1]), .wdata(vid_sram_wdata1), .waddr(vid_sram_waddr1), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata1));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w2_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[2]), .wdata(vid_sram_wdata2), .waddr(vid_sram_waddr2), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata2));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w3_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[3]), .wdata(vid_sram_wdata3), .waddr(vid_sram_waddr3), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata3));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w4_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[4]), .wdata(vid_sram_wdata4), .waddr(vid_sram_waddr4), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata4));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w5_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[5]), .wdata(vid_sram_wdata5), .waddr(vid_sram_waddr5), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata5));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w6_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[6]), .wdata(vid_sram_wdata6), .waddr(vid_sram_waddr6), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata6));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w7_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[7]), .wdata(vid_sram_wdata7), .waddr(vid_sram_waddr7), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata7));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w8_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[8]), .wdata(vid_sram_wdata8), .waddr(vid_sram_waddr8), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata8));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w9_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[9]), .wdata(vid_sram_wdata9), .waddr(vid_sram_waddr9), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata9));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w10_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[10]), .wdata(vid_sram_wdata10), .waddr(vid_sram_waddr10), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata10));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w11_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[11]), .wdata(vid_sram_wdata11), .waddr(vid_sram_waddr11), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata11));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w12_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[12]), .wdata(vid_sram_wdata12), .waddr(vid_sram_waddr12), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata12));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w13_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[13]), .wdata(vid_sram_wdata13), .waddr(vid_sram_waddr13), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata13));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w14_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[14]), .wdata(vid_sram_wdata14), .waddr(vid_sram_waddr14), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata14));
vid_sram_16x256b #(.ADDR_SPACE(VID_ADDR_SPACE),.Q(Q),.VID_BW(VID_BW)) 
w15_vid_sram_16x256b(.clk(clk), .wsb(vidsram_wen[15]), .wdata(vid_sram_wdata15), .waddr(vid_sram_waddr15), .raddr(vid_sram_raddr), .rdata(vid_sram_rdata15));
// ===================================================================================
// master_top #(
//  // 
// )
master_top master_instn (
    .clk(clk),
    .enable(enable),
    .rst_n_in(rst_n),
    .in_next_arr(in_next_arr),
    .in_mi_j(in_mi_j),
    .in_mj_i(in_mj_i),
    .in_v_gidx(in_v_gidx),
    .in_proposal_nums(in_proposal_nums),
    // output 
    .epoch(epoch),
    .vidsram_wen(vidsram_wen),
    .ready(ready),
    .finish(master_finish)
);
reg [NEXT_BW*Q-1:0] file_next_arr[0:MAX_EPOCH-1];
reg [PRO_BW*K-1:0] file_mi_j[0:MAX_EPOCH-1]; 
reg [PRO_BW*K-1:0] file_mj_i[0:MAX_EPOCH-1]; 
reg [VID_BW*Q-1:0] file_v_gidx[0:MAX_EPOCH-1]; 
reg [PRO_BW*Q-1:0] file_proposal_nums[0:MAX_EPOCH-1];

reg [8:0] gold_epoch;
reg [K-1:0] gold_wen;
reg [Q * VID_BW - 1:0] gold_wdata; 
reg [4 - 1:0] gold_waddr;
reg [7:0] chars[0:2];
always #(CYCLE/2) clk = ~clk;
integer ccc;
reg [8:0] check_epoch;
integer feed, feed_v;
initial begin 
    clk = 0;
    rst_n = 1;
    enable = 1'b0;
    
    $readmemh("../software/gold_master/next_arr.dat", file_next_arr);
    $write("file_next_arr 0: %h\n", file_next_arr[0]);
    $write("file_next_arr 1: %h\n", file_next_arr[1]);
    $readmemh("../software/gold_master/v_gidx.dat", file_v_gidx);
    $write("file_v_gidx 0: %h\n", file_v_gidx[0]);
    $write("file_v_gidx 1: %h\n", file_v_gidx[1]);
    $readmemh("../software/gold_master/mi_j.dat", file_mi_j);
    $write("file_mi_j 0: %h\n", file_mi_j[0]);
    $write("file_mi_j 1: %h\n", file_mi_j[1]);
    $readmemh("../software/gold_master/mj_i.dat", file_mj_i);
    $write("file_mj_i 0: %h\n", file_mj_i[0]);
    $write("file_mj_i 1: %h\n", file_mj_i[1]);
    $readmemh("../software/gold_master/proposal_nums.dat", file_proposal_nums);
    $write("file_proposal_nums 0: %h\n", file_proposal_nums[0]);
    $write("file_proposal_nums 1: %h\n", file_proposal_nums[1]);
    #(CYCLE) rst_n = 0; 
    // input test pattern, epoch should = 0 
    in_next_arr = file_next_arr[epoch];
    in_mi_j = file_mi_j[epoch];
    in_mj_i = file_mj_i[epoch];
    in_v_gidx = file_v_gidx[epoch];
    in_proposal_nums = file_proposal_nums[epoch];
    enable = 1'b1;
    #(CYCLE) rst_n = 1;   
    #(CYCLE*2)
    while(epoch < MAX_EPOCH - 1) begin 
        @(negedge clk)
        in_next_arr = file_next_arr[epoch-1 >= 0 ? epoch - 1: 0];
        in_mi_j = file_mi_j[epoch-1 >= 0 ? epoch - 1: 0];
        in_mj_i = file_mj_i[epoch-1 >= 0 ? epoch - 1: 0];
        in_v_gidx = file_v_gidx[epoch-4 >= 0 ? epoch - 4: 0];
        in_proposal_nums = file_proposal_nums[epoch-1 >= 0 ? epoch - 1: 0];
    end 
    feed = 255;
    feed_v = 252;
    while(feed_v < 256) begin
        @(negedge clk)
        // $write("input epoch %d feed %d", epoch, feed);
        in_next_arr = file_next_arr[feed];
        in_mi_j = file_mi_j[feed];
        in_mj_i = file_mj_i[feed];
        in_v_gidx = file_v_gidx[feed_v];
        in_proposal_nums = file_proposal_nums[feed];
        // $write("; vgid in %h;\n",in_v_gidx );
        feed_v = feed_v + 1;
        if(feed == 255) feed = 255;
        else feed = feed + 1;
    end 
    wait(master_finish == 1);
    $write("DONNEE");
    $finish;
end 

reg [K-1:0] checkbit;
integer checki;
reg [NEXT_BW-1:0] banknum; 
initial begin 
    fptr = $fopen("../software/gold_master/wdata.dat", "r");
    check_epoch = 0;
    wait(ready == 1);
    while(check_epoch <= MAX_EPOCH) begin 
        @(negedge clk)
        ccc = $fscanf(fptr, "%h %h", gold_epoch, gold_wen);
        $display("tbepoch: %d %h; %d", gold_epoch, gold_wen, check_epoch);
        if(check_epoch == gold_epoch) begin 
            if(gold_wen !== vidsram_wen) begin 
                $display("FAILL epoch %d tbepoch: %h goldwen %h; check %h", epoch, gold_epoch, gold_wen, check_epoch);
                $write("gold_wen %h vs vidsram_wen %h\n", gold_wen, vidsram_wen);
                $finish;
            end 
            // else begin 
                if(gold_wen > 0) begin 
                    checkbit = 16'h8000;
                    for(checki = 0; checki < K; checki = checki + 1) begin 
                        if((checkbit & gold_wen) > 0) begin 
                            ccc = $fscanf(fptr, "%h", banknum); 
                            // $write("banknum: %d\t\t", banknum);
                            ccc = $fscanf(fptr, "%h", gold_wdata);
                            // $write("wdata: %h\n", gold_wdata);
                            if(master_instn.vidsram_wdata[banknum] !== gold_wdata) begin
                                $write("FAIL check: %h vs %h (gold)", master_instn.vidsram_wdata[banknum], gold_wdata); 
                                $finish;
                            end 
                        end 
                        checkbit = checkbit >>1;
                    end
                    // $write("-------\n"); 
                end 
            // end 
        end
        else begin 
            $display("fscanf fail to sync!");
            $finish;
        end 
        check_epoch = check_epoch + 1;
    end
    if(check_epoch != MAX_EPOCH+1) begin 
        $write("FAILLL only check to %d\n", check_epoch);
    end else begin 
        $write("HOORAY\n");
    end 
    $finish; 
end 
initial begin 
    #(CYCLE*10000000);
    $finish;
end 
initial begin 
    // wait(epoch == 100000);
    // $finish;
end 
// initial begin
// 	$fsdbDumpfile("test_master.fsdb");
// 	$fsdbDumpvars("+mda");
// end
endmodule

