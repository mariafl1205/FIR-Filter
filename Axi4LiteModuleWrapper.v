////////////////////////////////////////////////////////////////
// Axi4LiteModule Verilog Wrapper
//   Use this to add a module to block diagram in Vivado
////////////////////////////////////////////////////////////////
module Axi4LiteModuleWrapper# (parameter C_S_AXI_ADDR_WIDTH = 4, C_S_AXI_DATA_WIDTH = 32) ( 
        // Axi4Lite Bus
        input   S_AXI_ACLK,
        input   S_AXI_ARESETN,
        input   [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input   S_AXI_AWVALID,
        output  S_AXI_AWREADY,
        input   [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input   [3:0] S_AXI_WSTRB,
        input   S_AXI_WVALID,
        output  S_AXI_WREADY,
        input   [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input   S_AXI_ARVALID,
        output  S_AXI_ARREADY,
        output  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output  [1:0] S_AXI_RRESP,
        output  S_AXI_RVALID,
        input   S_AXI_RREADY,
        output  [1:0] S_AXI_BRESP,
        output  S_AXI_BVALID,
        input   S_AXI_BREADY,
        output regs0_0,
        output regs1_0
        
    );
    
    Axi4LiteRegs #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteRegs1 (
    .S_AXI_ACLK(S_AXI_ACLK),
    .S_AXI_ARESETN(S_AXI_ARESETN),
    .S_AXI_AWADDR(S_AXI_AWADDR),
    .S_AXI_AWVALID(S_AXI_AWVALID),
    .S_AXI_AWREADY(S_AXI_AWREADY),
    .S_AXI_WDATA(S_AXI_WDATA),
    .S_AXI_WSTRB(S_AXI_WSTRB),
    .S_AXI_WVALID(S_AXI_WVALID),
    .S_AXI_WREADY(S_AXI_WREADY),
    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),
    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY),
    .S_AXI_BRESP(S_AXI_BRESP),
    .S_AXI_BVALID(S_AXI_BVALID),
    .S_AXI_BREADY(S_AXI_BREADY),
    .regs0(regs0_0),
    .regs1(regs1_0)
    );
    
    
    
	
endmodule