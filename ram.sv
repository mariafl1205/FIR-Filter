`timescale 1ns / 1ps

module ram#(//WILL NEED 2 of THESE modules (1 for coefficients 1 for buffer)
    
   parameter int RAM_WIDTH = 16, //16 bit width=
   parameter  RAM_ADDR_BITS = 6, //six bit addressing allows for 64 coefficients to be stored
   parameter NUM_ADDRESSES = 1 << RAM_ADDR_BITS
   )(
 
   
   input logic clk,
   input logic wr,
   input logic [RAM_ADDR_BITS - 1:0] ram_addr,
   input logic [RAM_WIDTH - 1:0] ram_input,
   output logic [RAM_WIDTH - 1:0] ram_output
   );
   
   (* ram_style="distributed" *)
   logic [RAM_WIDTH - 1:0] ram [0:NUM_ADDRESSES - 1]; //specify RAM layout --> 64 ADDRESSES

   

   always_ff @(posedge clk) begin
      if (wr)
         ram[ram_addr] <= ram_input;
   end

   assign ram_output = ram[ram_addr];
					
endmodule
