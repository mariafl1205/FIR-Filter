`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2026 11:51:21 PM
// Design Name: 
// Module Name: FIRFilterWrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIRFilterWrapper #( parameter C_S_AXI_ADDR_WIDTH = 8, C_S_AXI_DATA_WIDTH = 32, RAM_WIDTH = 16,
    RAM_ADDR_BITS = 6, 
    NUM_ADDRESSES = 1 << RAM_ADDR_BITS,
    SAMPLE_ADDR_BITS = 6) (
    
    input  S_AXI_ACLK,
    input  S_AXI_ARESETN,
    input  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  S_AXI_AWVALID,
    output  S_AXI_AWREADY,
    input  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input  [3:0] S_AXI_WSTRB,
    input  S_AXI_WVALID,
    output  S_AXI_WREADY,
    input  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  S_AXI_ARVALID,
    output  S_AXI_ARREADY,
    output  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output  [1:0] S_AXI_RRESP,
    output  S_AXI_RVALID,
    input  S_AXI_RREADY,
    output  [1:0] S_AXI_BRESP,
    output  S_AXI_BVALID,
    input  S_AXI_BREADY
    
    );
    
    FIRFilter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH), .RAM_WIDTH(RAM_WIDTH), .RAM_ADDR_BITS(RAM_ADDR_BITS), .NUM_ADDRESSES(NUM_ADDRESSES),
    .SAMPLE_ADDR_BITS(SAMPLE_ADDR_BITS)) FIRFilter1 
    (
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_WSTRB(S_AXI_WSTRB),          // input    [3:0]
        .S_AXI_WVALID(S_AXI_WVALID),        // input
        .S_AXI_WREADY(S_AXI_WREADY),        // output        
        .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_ARVALID(S_AXI_ARVALID),      // input
        .S_AXI_ARREADY(S_AXI_ARREADY),      // output
        .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
        .S_AXI_RVALID(S_AXI_RVALID),        // output    
        .S_AXI_RREADY(S_AXI_RREADY),        // input
        .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
        .S_AXI_BVALID(S_AXI_BVALID),        // output
        .S_AXI_BREADY(S_AXI_BREADY)
        
    );
    
    
endmodule
