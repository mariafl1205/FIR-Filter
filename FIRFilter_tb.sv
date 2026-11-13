`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2026 03:17:12 PM
// Design Name: 
// Module Name: FIRFilter_tb
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


module FIRFilter_tb();
    parameter C_S_AXI_ADDR_WIDTH = 8, C_S_AXI_DATA_WIDTH = 32, CLK_PERIOD = 33.33,
    RAM_WIDTH = 16, //16 bit width=
    RAM_ADDR_BITS = 6, //six bit addressing allows for 64 coefficients to be stored
    NUM_ADDRESSES = 1 << RAM_ADDR_BITS,
    SAMPLE_ADDR_BITS = 6 ;
    
    localparam CLK_PERIOD_2 = CLK_PERIOD/2;
    logic  S_AXI_ACLK;
    logic  S_AXI_ARESETN;
    logic  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR;
    logic  S_AXI_AWVALID;
    logic  S_AXI_AWREADY;
    logic  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA;
    logic  [3:0] S_AXI_WSTRB;
    logic  S_AXI_WVALID;
    logic  S_AXI_WREADY;
    logic  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR;
    logic  S_AXI_ARVALID;
    logic  S_AXI_ARREADY;
    logic  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;
    logic  [1:0] S_AXI_RRESP;
    logic  S_AXI_RVALID;
    logic  S_AXI_RREADY;
    logic  [1:0] S_AXI_BRESP;
    logic  S_AXI_BVALID;
    logic  S_AXI_BREADY;
    logic  regs0;
    logic  regs1;
    
    
    //Coefficients from AXI register
    logic coeff_wr;
    logic [RAM_ADDR_BITS - 1 : 0] coeff_addr;
    logic [RAM_WIDTH - 1 : 0] coeff_data;
    
    //Samples from AXI
    logic sample_wr;
    logic [SAMPLE_ADDR_BITS - 1 : 0] sample_addr;
    logic [RAM_WIDTH -1 : 0] sample_data;
    

    //OUTPUT the result
    logic result_ready;
    logic [RAM_WIDTH - 1: 0] result_data;
    
    
    logic   [C_S_AXI_ADDR_WIDTH-1:0] wrAddr ;
    logic   [C_S_AXI_DATA_WIDTH-1:0] wrData ;
    logic   wr ;
    logic   [C_S_AXI_ADDR_WIDTH-1:0] rdAddr ;
    logic   [C_S_AXI_DATA_WIDTH-1:0] rdData ;
    logic   rd ;
    logic   wrDone;
    logic   rdDone;
    logic [RAM_WIDTH-1:0] sine1 [0:999];
    logic [RAM_WIDTH-1:0] coeff1 [0:60];
    
    
    logic [31:0] reg0;
    logic [31:0] reg1;
    
    bit isDone = 1'b0; //default 0
    int samplesRemaining = 1000; 
    int samplesIndex = 0;
    int funnyIndex = 0;
    
    Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteManager1
        (
            // Simple Bus
            .wrAddr(wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .wrData(wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
            .wr(wr),                            // input    
            .wrDone(wrDone),                    // output
            .rdAddr(rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .rdData(rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
            .rd(rd),                            // input
            .rdDone(rdDone),                    // output
            // Axi4Lite Bus
            .M_AXI_ACLK(S_AXI_ACLK),            // input
            .M_AXI_ARESETN(S_AXI_ARESETN),      // input
            .M_AXI_AWADDR(S_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
            .M_AXI_AWVALID(S_AXI_AWVALID),      // output
            .M_AXI_AWREADY(S_AXI_AWREADY),      // input
            .M_AXI_WDATA(S_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_WSTRB(S_AXI_WSTRB),          // output   [3:0]
            .M_AXI_WVALID(S_AXI_WVALID),        // output
            .M_AXI_WREADY(S_AXI_WREADY),        // input
            .M_AXI_ARADDR(S_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
            .M_AXI_ARVALID(S_AXI_ARVALID),      // output
            .M_AXI_ARREADY(S_AXI_ARREADY),      // input
            .M_AXI_RDATA(S_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_RRESP(S_AXI_RRESP),          // input    [1:0]
            .M_AXI_RVALID(S_AXI_RVALID),        // input
            .M_AXI_RREADY(S_AXI_RREADY),        // output
            .M_AXI_BRESP(S_AXI_BRESP),          // input    [1:0]
            .M_AXI_BVALID(S_AXI_BVALID),        // input
            .M_AXI_BREADY(S_AXI_BREADY)         // output
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
        .S_AXI_BREADY(S_AXI_BREADY),
        
//        .wrAddr(wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
//        .wrData(wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
//        .wr(wr),                            // input    
//        .wrDone(wrDone),                    // output
//        .rdAddr(rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
//        .rdData(rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
//        .rd(rd),                          
//        .rdDone(rdDone),
        .regs0(regs0),
        .regs1(regs1)
        
    );
    
    always begin
	   #(CLK_PERIOD_2) S_AXI_ACLK = ~S_AXI_ACLK;
    end
    
    logic[31:0] readValue;
    logic signed [15:0] results [0:999];
    
    initial begin
        S_AXI_ACLK = 0;
        S_AXI_ARESETN = 0;
        
        wr = 0; 
        wrAddr = 0;
        wrData = 0;
        rd = 0;
        rdAddr = 0;
        

        $readmemh("coeff1.txt", coeff1);
        $readmemh("sine1.txt", sine1);
        #(CLK_PERIOD_2+2) S_AXI_ARESETN = 1;
        #(CLK_PERIOD*22);
        coeff_wr = 0;
        coeff_addr = 0;
        coeff_data = 0;
        
        sample_wr = 0;
        sample_addr = 0;
        sample_data = 0;
        
        rdAddr = 0;
//        rdData = 0;
        rd = 0;
        wr = 0;
        wrAddr = 0;
        wrData = 0;
        #(CLK_PERIOD*2);
        
        
        for(int i = 0; i < 61; i++) begin 
            @(negedge S_AXI_ACLK);
            coeff_wr = 1;
            coeff_addr = i;
            wrData = {16'b0, coeff1[i]};
            wrAddr = 0;
            wr = 1;
            
            
            @(negedge S_AXI_ACLK);
            coeff_wr = 0;
            wr = 0;
            
            wait(wrDone === 1'b1); //wait for manager to assert done
            @(negedge S_AXI_ACLK); 
            readValue =0;
            
            
            while(readValue[16] !== 1'b1) begin
                @(negedge S_AXI_ACLK);
                rdAddr = 0;
                rd = 1;
                @(negedge S_AXI_ACLK);
                rd = 0;
                
                wait(rdDone === 1'b1);
                @(negedge S_AXI_ACLK);
                readValue = rdData;
             end
        end
        
        wait (FIRFilter1.doneWritingCoefficients === 1'b1); //wait for FIR to assert done w/ coefficients
        
        for(int i = 0; i < 1000; i++) begin
            @(negedge S_AXI_ACLK);
            wrAddr = 0;
            wrData = {16'b0, sine1[i]};
            wr = 1;
            @(negedge S_AXI_ACLK);
            wr =0;
            
            wait(wrDone === 1'b1);
            @(negedge S_AXI_ACLK);
            
            readValue = 32'h0;
            
            while(readValue[16] !== 1'b1) begin
                @(negedge S_AXI_ACLK);
                rdAddr = 0;
                rd = 1;
                @(negedge S_AXI_ACLK);
                rd = 0;
                
                wait(rdDone === 1'b1);
                
                @(negedge S_AXI_ACLK);
                readValue = rdData;
                
             end
             
             #(CLK_PERIOD*2);
             results[i] = readValue[15:0];
             $display("%0d", $signed(results[i]));
          end
        
        $finish;
            

    end

    
endmodule
