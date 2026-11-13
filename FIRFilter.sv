`timescale 1ns / 1ps

module FIRFilter #(

    parameter C_S_AXI_ADDR_WIDTH = 8, C_S_AXI_DATA_WIDTH = 32,
    RAM_WIDTH = 16, //16 bit width=
    RAM_ADDR_BITS = 6, //six bit addressing allows for 64 coefficients to be stored
    NUM_ADDRESSES = 1 << RAM_ADDR_BITS,
    SAMPLE_ADDR_BITS = 6
    )(
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
    input  logic  S_AXI_BREADY,
    output logic  regs0,
    output logic  regs1
//    input logic   [C_S_AXI_ADDR_WIDTH-1:0] wrAddr,
//    input logic   [C_S_AXI_DATA_WIDTH-1:0] wrData,
//    input logic   wr,
//    input logic   [C_S_AXI_ADDR_WIDTH-1:0] rdAddr ,
//    output logic   [C_S_AXI_DATA_WIDTH-1:0] rdData ,
//    input logic   rd ,
//    input logic     wrDone,
//    input logic     rdDone    
    );
    
    
    //Coefficients from AXI register
    logic coeff_wr;
    logic [RAM_ADDR_BITS- 1:0] coeff_addr;
    logic [RAM_WIDTH - 1:0] coeff_data;
    logic [RAM_WIDTH - 1:0] coeff_output;
    
    //Samples from AXI
    logic sample_wr;
    logic [RAM_ADDR_BITS- 1:0] sample_addr;
    logic [RAM_WIDTH - 1:0] sample_data;
    logic [RAM_WIDTH - 1:0] sample_output;
    

    //OUTPUT the result
    logic result_ready;
    logic result_data[RAM_WIDTH];
   
    
    logic [C_S_AXI_ADDR_WIDTH-1:0] wrAddrD, wrAddrQ;
    logic [C_S_AXI_DATA_WIDTH-1:0] wrDataD, wrDataQ;
    
    logic [RAM_ADDR_BITS-1:0] ramAddrD, ramAddrQ;
    logic [RAM_ADDR_BITS-1:0] mostRecentIndexD, mostRecentIndexQ;
    
    logic [C_S_AXI_ADDR_WIDTH-1:0] rdAddrD, rdAddrQ;
    
    logic [RAM_WIDTH-1:0] sampleInputD, sampleInputQ;
    logic [RAM_ADDR_BITS-1:0] sampleWriteAddrD, sampleWriteAddrQ;
    
    logic [C_S_AXI_ADDR_WIDTH-1:0] wrAddr, rdAddr;
    logic [C_S_AXI_DATA_WIDTH-1:0] wrData, rdData;
    logic wr, rd;
    
    logic resultRead;
    assign resultRead = S_AXI_RVALID && S_AXI_RREADY && S_AXI_RDATA[16];
    
    //FSM for handling convolution
    typedef enum logic [3:0] {
        IDLE,
        COEFF_WR,
        SAMPLE_UPDATE,
        CONV,
        CONV_FETCH,
        SENDRES
    } statetype;
    statetype nextState, currState;
    
    
    
    ram #(.RAM_WIDTH(RAM_WIDTH), .RAM_ADDR_BITS(RAM_ADDR_BITS), .NUM_ADDRESSES(NUM_ADDRESSES)) coeff( 
     .clk(S_AXI_ACLK),
     .wr(coeff_wr),
     .ram_addr(coeff_addr),
     .ram_input(coeff_data),
     .ram_output(coeff_output)
    );
    
    ram #(.RAM_WIDTH(RAM_WIDTH), .RAM_ADDR_BITS(RAM_ADDR_BITS), .NUM_ADDRESSES(NUM_ADDRESSES)) sample( 
     .clk(S_AXI_ACLK),
     .wr(sample_wr),
     .ram_addr(sample_addr),
     .ram_input(sample_data),
     .ram_output(sample_output)
    );

    
    Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (
    // Simple Bus
    .wrAddr(wrAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .wrData(wrData),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
    .wr(wr),                            // output
    .rdAddr(rdAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .rdData(rdData),                    // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .rd(rd),                            // output   
    // Axi4Lite Bus
    .S_AXI_ACLK(S_AXI_ACLK),            // input
    .S_AXI_ARESETN(S_AXI_ARESETN),      // input
    .S_AXI_AWADDR(S_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_AWVALID(S_AXI_AWVALID),      // input
    .S_AXI_AWREADY(S_AXI_AWREADY),      // output
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
    .S_AXI_BREADY(S_AXI_BREADY)         // input
    ) ;
   
    logic [7:0] sampleWriteOverIndex = 0;
    logic signed [31:0] runningSumD, runningSumQ;
    logic [7:0] sampleIndex = 0;
    logic [7:0] coefficientsIndex = 0;
    logic [15:0] currSample = 0;
    logic [15:0] coefficients = 0;
    logic doneWritingCoefficients = 0;
    logic signed [31:0] convResult = 0;
    logic signed[31:0] coefficient = 0;
    
    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            currState <= IDLE;
            wrAddrQ <= 0;
            wrDataQ <= 0;
            runningSumQ <= 0;
            coefficientsIndex <= 0;
            ramAddrQ <= 0;
            mostRecentIndexQ <= 0;
            sampleInputQ     <= 0;
            sampleWriteAddrQ <= 0;
            doneWritingCoefficients <= 0;
            rdData <= 32'b0;
            regs0 <= 0;
            regs1 <= 1'b0;
        end 
        else begin
            currState <= nextState;
            wrAddrQ <= wrAddrD;
            wrDataQ <= wrDataD;
            ramAddrQ <= ramAddrD;
            mostRecentIndexQ <= mostRecentIndexD;
            runningSumQ <= runningSumD;
            sampleInputQ     <= sampleInputD;
            sampleWriteAddrQ <= sampleWriteAddrD;
            
            regs0 <= (nextState != IDLE); //detect if busy processing

            if(currState == IDLE && ramAddrQ ==61) begin
                doneWritingCoefficients <= 1;
            end
            
            if(currState == COEFF_WR) begin
                rdData <= 32'h00010000; //set the valid bit high
                regs1 <= 1'b1;
            end
            
            else if(currState == CONV && ramAddrQ ==60) begin
                rdData <= {15'b0, 1'b1, runningSumD[15:0]}; //set the 17th bit to 1, result is VALID
                regs1 <= 1; //DONE!
                
                //reset the valid bit?
                
                
            end
            else if(currState == SENDRES && resultRead) begin
                rdData[16] <= 1'b0; //valid bit low after we know result is read
                regs1 <= 1'b0;
            end
            
        end
    end
    
    
    always_comb begin 
        nextState = currState;
        //3 below are unnecessary, already driven by the supporter
        //wrData = 0;
        // wr = 0;
       // S_AXI_WREADY =0;
        wrDataD = wrDataQ;
        wrAddrD = wrAddrQ;
        ramAddrD = ramAddrQ;
        mostRecentIndexD = mostRecentIndexQ;
        sampleInputD     = sampleInputQ;
        sampleWriteAddrD = sampleWriteAddrQ;
        runningSumD = runningSumQ;
        coeff_wr = 0;
        sample_wr   = 0;
        sample_addr = 0;
        sample_data = 0;
        coeff_addr = 0;
        coeff_data = 0;
        convResult = 0;
        
        case(currState)
            IDLE: begin
                if(wr) begin
                
                    if(!doneWritingCoefficients) begin
                        wrDataD = wrData;
                        nextState = COEFF_WR;
                    end

                    else begin //done filling up coefficients, wait for sample_wr
                    //receive the new sample from the supporter
                        sampleInputD = wrData[RAM_WIDTH-1:0];
                        nextState = SAMPLE_UPDATE;
                    end
              end
            end
          
          
          COEFF_WR: begin
                 coeff_addr = ramAddrQ;
                 coeff_data = wrDataQ[RAM_WIDTH-1:0];
                 coeff_wr = S_AXI_ARESETN;
                 sample_addr = ramAddrQ;
                 sample_data = 0;
                 sample_wr = S_AXI_ARESETN;
                 ramAddrD = ramAddrQ + 1;
                 if(ramAddrQ < 60) begin 
                    nextState = IDLE;
                 end else begin 
                    nextState = SENDRES;
                 end             
          end 
          
          SAMPLE_UPDATE: begin
                
                //*********************
                // WRITE THE NEW SAMPLE //
                // *********************
                sample_addr = sampleWriteAddrQ;
                sample_data = sampleInputQ;
                sample_wr = 1;
                mostRecentIndexD = sampleWriteAddrQ;
                //*********************
                if(sampleWriteAddrQ == 60) begin //loop back to the beginning of the buffer
                    sampleWriteAddrD = 0;
                end
                else begin
                    sampleWriteAddrD = sampleWriteAddrQ + 1;
                end
                ramAddrD = 0;
                runningSumD = 0;
                nextState = CONV_FETCH;
          end
          CONV_FETCH: begin
                sample_addr = mostRecentIndexQ;
                coeff_addr = ramAddrQ;
                
                coeff_wr = 0;
                sample_wr = 0;
                
                nextState = CONV;
          end
          
          CONV: begin
            //READ FROM THE BUFFER
            sample_addr = mostRecentIndexQ;
            coeff_addr = ramAddrQ;
            
            sample_wr = 0;
            coeff_wr = 0;
            
            convResult = $signed(coeff_output) * $signed(sample_output);
            runningSumD = runningSumQ + convResult;
            
            if(mostRecentIndexQ == 0) begin
                mostRecentIndexD = 60;
            end
            else begin
                mostRecentIndexD = mostRecentIndexQ - 1;
            end
            
            ramAddrD = ramAddrQ + 1;
            if(ramAddrQ == 60) begin //either be done or get another sample after doing the convolution
                runningSumD = (runningSumD + (1<<14)) >>> 15; //switch to signed shift
                nextState = SENDRES;
            end
         end
         
         SENDRES: begin
            if(resultRead) begin
                nextState = IDLE;
            end
          end
            
          
     endcase                
     
     end 
                   
endmodule
