for i in range(16):
   print("next_sram_256x4b #(.ADDR_SPACE(NEXT_ADDR_SPACE),.Q(Q),.BW(NEXT_BW)) \nw%d_next_sram_256x4b(" % i, end='')
   print(".clk(clk), .wsb(), .wdata(), .waddr(), .raddr(next_sram_raddr), .rdata(next_sram_rdata%d));" % (i))