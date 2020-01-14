for i in range(16):
   print("proposal_sram_16x128b #(.ADDR_SPACE(PRO_ADDR_SPACE),.Q(Q),.BW(PRO_BW))\nw%d_proposal_sram_16x128b(" % i, end='')
   print(".clk(clk), .wsb(), .wdata(), .waddr(), .raddr(pronum_sram_raddr), .rdata(proposal_sram_rdata%d));" % (i))
