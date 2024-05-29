`timescale 1ns / 1ps

module tb_ILM_AE;

   // Inputs
   reg [7:0] x;
   reg [7:0] y;
   
   // Outputs
   wire [15:0] p;

   // Replace name with Multiplier name
   ILM_AE UUT (
      .x(x),
      .y(y),
      .p(p)
   );

   // Clock generation
   reg clk;
   always #5 clk = ~clk;

   // Reset generation
   initial begin
      $dumpfile("waveform.vcd");
      $dumpvars(0, tb_ILM_AE);
      clk = 0;
      x = 8'b00000001;
      y = 8'b00000010;
      #20;  // Wait for a few cycles
      x = 8'b00000100;
      y = 8'b00000101;
      #100; // Wait for a longer time
      $finish;
   end
   
endmodule

