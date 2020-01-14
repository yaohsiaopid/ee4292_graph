module worker_sram
#(
    parameter K = 16,
    parameter D = 256,
    parameter DIST_BW = 1,
    parameter DIST_ADDR_SPACE = 16,
    parameter LOC_BW = 5,
    parameter LOC_ADDR_SPACE = 4,
    parameter NEXT_BW = 4,
    parameter NEXT_ADDR_SPACE = 4,
    parameter PRO_BW = 8,
    parameter PRO_ADDR_SPACE = 4,
    parameter VID_BW = 16,  // 12???
    parameter VID_ADDR_SPACE = 5,
    parameter Q = 16,
	parameter WORK_IDX = 15
)
(
    input clk,
    input en,
    input rst_n,
    input [7:0] batch_num,
    input [Q*VID_BW-1:0] vid_sram_rdata,			// 256
    input [D*DIST_BW-1:0] dist_sram_rdata,			// 256
    	input [D*(LOC_BW-1)-1:0] loc_rdata,             // input 256 X 4bit valid locations selected from top module

	output [3:0] sub_bat,						// 4
	output [VID_ADDR_SPACE-1:0] vid_sram_raddr,				// 5 BITS!!!!!
	output reg [DIST_ADDR_SPACE-1:0] dist_sram_raddr,					// 16
	output [LOC_ADDR_SPACE-1:0] loc_sram_raddr,
		output [Q-1:0] next_bytemask,				// 16
    	output [Q*NEXT_BW-1:0] next_wdata,			// 64
    	output [NEXT_ADDR_SPACE-1:0] next_waddr,	// 4
		output [Q-1:0] pro_bytemask,				// 16
    	output [Q*PRO_BW-1:0] pro_wdata,			// 128
		output [PRO_ADDR_SPACE-1:0] pro_waddr,		//4
    	output ready,       // for part_reg[0:K-1]	// 1
    	output batch_finish, // for next / proposal number	// 1
		output wen									// 1
);

wire en_worker, rst_n_worker;
wire [Q*VID_BW-1:0] vid_sram_rdata0;
wire [D*DIST_BW-1:0] dist_sram_rdata0;
wire [D*(LOC_BW-1)-1:0] loc_sram_rdata0;
wire [VID_BW-1:0] vid0;
wire [Q-1:0] next_bytemask0;
wire [Q*NEXT_BW-1:0] next_sram_wdata0;
wire [NEXT_ADDR_SPACE-1:0] next_sram_waddr0;
wire [Q-1:0] pro_bytemask0;
wire [Q*PRO_BW-1:0] pro_sram_wdata0;
wire [PRO_ADDR_SPACE-1:0] pro_sram_waddr0;
wire ready0, batch_finish0, wen0;
wire [3:0] sub_bat0;
wire [7:0] batch_num0;

worker #(.WORK_IDX(15)) worker_0
(
	.clk(clk),
	.en(en),
	.rst_n(rst_n_worker),
	.batch_num(batch_num0),
	.vid_rdata(vid_sram_rdata0),
	.dist_rdata(dist_sram_rdata0),
	.loc_rdata(loc_sram_rdata0),

	.sub_bat(sub_bat0),
	.vid(vid0),
		.next_bytemask(next_bytemask0),
		.next_wdata(next_sram_wdata0),
		.next_waddr(next_sram_waddr0),
		.pro_bytemask(pro_bytemask0),
		.pro_wdata(pro_sram_wdata0),
		.pro_waddr(pro_sram_waddr0),
		.ready(ready0),
		.batch_finish(batch_finish0),
		.wen_delay(wen0),
		.proposal_num0(),
		.proposal_num1(),
		.proposal_num2(),
		.proposal_num3(),
		.proposal_num4(),
		.proposal_num5(),
		.proposal_num6(),
		.proposal_num7(),
		.proposal_num8(),
		.proposal_num9(),
		.proposal_num10(),
		.proposal_num11(),
		.proposal_num12(),
		.proposal_num13(),
		.proposal_num14(),
		.proposal_num15()
);

parameter IDLE = 2'd0, WORKER = 2'd1, FIN = 2'd2;

reg [1:0] state, n_state;
reg [3:0] iter, n_iter;
reg reset_worker;

always@ (posedge clk) begin
	if (~rst_n) begin
		iter <= 4'd0;
		state <= IDLE;
	end else begin
		iter <= n_iter;
		state <= n_state;
	end
end	

assign batch_num0 = batch_num;
assign sub_bat = sub_bat0;
assign next_bytemask = next_bytemask0;
assign next_wdata = next_sram_wdata0;
assign next_waddr = next_sram_waddr0;
assign pro_bytemask = pro_bytemask0;
assign pro_wdata = pro_sram_wdata0;
assign pro_waddr = pro_sram_waddr0;
assign loc_sram_raddr = sub_bat0;
// assign dist_sram_raddr = {vid0, sub_bat0};
assign vid_sram_raddr = {iter[0], batch_num[7:4]};
assign dist_sram_rdata0 = dist_sram_rdata;
assign loc_sram_rdata0 = loc_rdata;
assign vid_sram_rdata0 = vid_sram_rdata;	
assign rst_n_worker = reset_worker & rst_n;
assign wen = wen0;
assign batch_finish = batch_finish0;
assign ready = ready0;

always@* begin
	if(~rst_n) begin
		dist_sram_raddr = 16'd0;
	end else begin
		dist_sram_raddr = {vid0, sub_bat0};
	end
end

always@* begin
	if(batch_finish0) begin
		n_iter = iter + 1;
		reset_worker = 0;
	end else begin
		n_iter = iter;
		reset_worker = 1;
	end
end

// FSM
always@* begin
    case(state)
        IDLE: begin
            if(en) begin
                n_state = WORKER;
            end else begin
                n_state = IDLE;
            end
        end
        WORKER: begin
            if(batch_finish0) begin
				n_state = FIN;
            end else begin
                n_state = WORKER;
            end
        end
        FIN: begin
            n_state = FIN;
        end
    endcase    
end

endmodule