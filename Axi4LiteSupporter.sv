`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2026 01:57:19 PM
// Design Name: 
// Module Name: Axi4LiteSupporter
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


module Axi4LiteSupporter #
       (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
    (
        // Simple Bus
        output logic  [C_S_AXI_ADDR_WIDTH-1:0] wrAddr,
        output logic  [C_S_AXI_DATA_WIDTH-1:0] wrData,
        output logic  wr,
        output logic  [C_S_AXI_ADDR_WIDTH-1:0] rdAddr,
        input  logic  [C_S_AXI_DATA_WIDTH-1:0] rdData,
        output logic  rd,
        // Axi4Lite Bus
        input  logic  S_AXI_ACLK,
        input  logic  S_AXI_ARESETN,
        input  logic  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input  logic  S_AXI_AWVALID,
        output logic  S_AXI_AWREADY,
        input  logic  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input  logic  [3:0] S_AXI_WSTRB,
        input  logic  S_AXI_WVALID,
        output logic  S_AXI_WREADY,
        input  logic  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input  logic  S_AXI_ARVALID,
        output logic  S_AXI_ARREADY,
        output logic  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output logic  [1:0] S_AXI_RRESP,
        output logic  S_AXI_RVALID,
        input  logic  S_AXI_RREADY,
        output logic  [1:0] S_AXI_BRESP,
        output logic  S_AXI_BVALID,
        input  logic  S_AXI_BREADY
    );
    
    typedef enum logic [3:0]{
        IDLE, WR1, WR2, RD1, RD2
    }statetype; 
    
    statetype nextState, currState;  
    
    logic [C_S_AXI_ADDR_WIDTH-1:0] wrAddrD, wrAddrQ;
    logic [C_S_AXI_DATA_WIDTH-1:0] wrDataD, wrDataQ;
    
    logic [C_S_AXI_ADDR_WIDTH-1:0] rdAddrD, rdAddrQ;
    
    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            currState <= IDLE;
            wrAddrQ <= 0;
            wrDataQ <= 0;
            rdAddrQ <= 0;
        end 
        else begin
            currState <= nextState;
            wrAddrQ <= wrAddrD;
            wrDataQ <= wrDataD;
            rdAddrQ <= rdAddrD;
        end
    end
    
    always_comb begin 
        nextState = currState;
        wrAddr = 0;
        wrData = 0;
        wr = 0;
        rdAddr = 0;
        rd = 0;
        S_AXI_AWREADY=0;
        S_AXI_WREADY =0;
        S_AXI_ARREADY =0;
        S_AXI_RDATA =0;
        S_AXI_RRESP =0;
        S_AXI_RVALID =0;
        S_AXI_BRESP =0;
        S_AXI_BVALID = 0;
        wrDataD = wrDataQ;
        wrAddrD = wrAddrQ;
        rdAddrD = rdAddrQ;

        case(currState)
            IDLE: begin
            
                if (S_AXI_WVALID && S_AXI_AWVALID) begin
                    S_AXI_AWREADY = 1'b1;
                    S_AXI_WREADY = 1'b1;
                    wrDataD = S_AXI_WDATA;
                    wrAddrD = S_AXI_AWADDR;
                    nextState = WR1;
                end
                else if (S_AXI_ARVALID) begin
                    S_AXI_ARREADY = 1'b1;
                    rdAddrD = S_AXI_ARADDR;
                    nextState = RD1;
                end
            end
            
            WR1: begin
                wrAddr = wrAddrQ;
                wrData = wrDataQ;
                wr = 1'b1;
                nextState = WR2;
            end
            
            WR2: begin
                S_AXI_BVALID = 1;
                if (S_AXI_BREADY) begin            
                    nextState = IDLE;
                end 
            end
            
            RD1: begin
                rdAddr = rdAddrQ;
                rd = 1'b1;
                nextState = RD2;
            end
            
            RD2: begin
                rdAddr = rdAddrQ;
                rd = 1'b1;
                
                S_AXI_RDATA = rdData;
                S_AXI_RVALID = 1'b1;
                
                if (S_AXI_RREADY) begin
                    nextState = IDLE;
            
                end
            
            
            end
            
            default: begin
            nextState = IDLE;
            end
            
        endcase
        
    end
endmodule
