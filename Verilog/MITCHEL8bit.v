`timescale 1ns / 1ps

module MITCHEL(
    input [7:0] x,
    input [7:0] y,
    output [15:0] p
    );

	// LOD x
	wire [7:0] kx;
	wire zero_x;
	wire [2:0] code_x;

	LOD8 LODx (
		.data_i(x),
		.zero_o(zero_x),
		.data_o(kx)
	 ); 

	PriorityEncoder_8 PEx (
		.data_i(kx),
		.code_o(code_x)
	 ); 
	 
	// LOD y
	wire [7:0] ky;
	wire zero_y;
	wire [2:0] code_y;

	LOD8 LODy (
		.data_i(y),
		.zero_o(zero_y),
		.data_o(ky)
	 ); 

	PriorityEncoder_8 PEy (
			.data_i(ky),
			.code_o(code_y)
		 ); 
		 
	
	// Barell shift X
	
	wire [2:0] code_x_inv;
	wire [7:0] barrel_x;
	
	assign code_x_inv = ~code_x;
	
	Barrel8L BShiftx (
		.data_i(x),
		.shift_i(code_x_inv),
		.data_o(barrel_x)
 	 ); 
	
	
	// Barell shift Y
	wire [2:0] code_y_inv;
	wire [7:0] barrel_y;

	assign code_y_inv = ~code_y;
	
	Barrel8L BShifty (
		.data_i(y),
		.shift_i(code_y_inv),
		.data_o(barrel_y)
 	 );
	
	// Addition of Op1 and Op2
	wire [10:0] op1;
	wire [10:0] op2;
	wire [10:0] L;
	wire c_in;
	
	assign op1 = {1'b0,code_x,barrel_x[6:0]};
	assign op2 = {1'b0,code_y,barrel_y[6:0]};
    
    assign L = op1 + op2;
	 	
	// Anti logarithm 
	
	wire [15:0] tmp_out; 
	AntiLog anti_log(
		.data_i(L),
		.data_o(tmp_out)
	);
	
	// is zero 
	wire not_zero;
	assign not_zero = (~zero_x | x[7] | x[0]) & (~zero_y | y[7] | y[0]);
	
	assign p = not_zero ? tmp_out : 16'b0;
	
endmodule


module AntiLog(
	input [10:0] data_i,
	output [15:0] data_o
	);
	
	// L1 Barell
	wire [15:0] l1_in;
	wire [15:0] l1_out;
	wire [3:0] k_enc;
	wire [3:0] k_enc_inc;
	
	assign l1_in = {8'b0,1'b1,data_i[6:0]};
	assign k_enc = {1'b0,data_i[9:7]};
	
	carry_lookahead_inc inc_inst(
     .i_add1(k_enc),
     .o_result(k_enc_inc)
     );	
	
	Barrel16L L1shift (
		.data_i(l1_in),
		.shift_i(k_enc_inc),
		.data_o(l1_out)
 	 );
	
	// R Barell 
	wire [7:0] r_in;
	wire [7:0] r_out;
	wire [2:0] enc;
	
	assign enc = ~data_i[9:7];
	assign r_in = {1'b1,data_i[6:0]};
	
	Barrel8R Rshift (
		.data_i(r_in),
		.shift_i(enc),
		.data_o(r_out)
 	 );
	
	// And
	wire lr;
	wire [7:0] out_msb;
	
	assign lr = data_i[10];
	assign out_msb = {8{lr}} & l1_out[15:8];
	
	// mux
	wire [7:0] out_lsb;
	assign out_lsb = lr ? l1_out[7:0] : r_out;
	// concanate
	assign data_o = {out_msb,out_lsb};
	
endmodule

module PriorityEncoder_8(
  	input [7:0] data_i,
  	output [2:0] code_o
    );
    
  wire [3:0] tmp0;
  assign tmp0 = {data_i[7],data_i[5],data_i[3],data_i[1]};
    OR_tree code0(tmp0,code_o[0]);
    
  wire [3:0] tmp1;
  assign tmp1 = {data_i[7],data_i[6],data_i[3],data_i[2]};
    OR_tree code1(tmp1,code_o[1]);
    
  wire [3:0] tmp2;
  assign tmp2 = {data_i[7],data_i[6],data_i[5],data_i[4]};
    OR_tree code2(tmp2,code_o[2]);
endmodule


module OR_tree(
  input [3:0] data_i,
    output data_o
    );
    
  wire [1:0] tmp1;
  assign tmp1 = data_i[1:0] | data_i[3:2];
  assign data_o = tmp1[0] | tmp1[1];
endmodule


module LOD4(
    input [3:0] data_i,
    output [3:0] data_o
    );
	 
	 
	 wire mux0;
	 wire mux1;
	 wire mux2;
	 
	 // multiplexers:
	 assign mux2 = (data_i[3]==1) ? 1'b0 : 1'b1;
	 assign mux1 = (data_i[2]==1) ? 1'b0 : mux2;
	 assign mux0 = (data_i[1]==1) ? 1'b0 : mux1;
	 
	 //gates and IO assignments:
	 assign data_o[3] = data_i[3];
	 assign data_o[2] =(mux2 & data_i[2]);
	 assign data_o[1] =(mux1 & data_i[1]);
	 assign data_o[0] =(mux0 & data_i[0]);
	 
endmodule

module LOD2(
	input [1:0] data_i,
	output [1:0] data_o
	);
	wire mux0;
	// multiplexers:
	assign mux0 = (data_i[1]==1) ? 1'b0 : 1'b1;
	 
	//gates and IO assignments:
	assign data_o[1] = data_i[1];
	assign data_o[0] =(mux0 & data_i[0]);
endmodule

module Muxes2in1Array4(
    input [3:0] data_i,
    input select_i,
    output [3:0] data_o
    );


	assign data_o[3] = select_i ? data_i[3] : 1'b0;
	assign data_o[2] = select_i ? data_i[2] : 1'b0;
	assign data_o[1] = select_i ? data_i[1] : 1'b0;
	assign data_o[0] = select_i ? data_i[0] : 1'b0;
	
endmodule

module LOD8(
    input [7:0] data_i,
    output zero_o,
    output [7:0] data_o
    );
	 
	 wire [7:0] z;
	 wire [1:0] select;
	 wire [1:0] zdet;
	 
	 //*****************************************
	 // Zero detection logic:
	 //*****************************************
	 assign zdet[1] = data_i[7] | data_i[6] | data_i[5] | data_i[4];
	 assign zdet[0] = data_i[3] | data_i[2] | data_i[1] | data_i[0];
	 assign zero_o = ~(zdet[1] | zdet[0]);
		 
	 //*****************************************
	 // LODs:
	 //*****************************************
	 LOD4 lod4_1 (
		.data_i(data_i[7:4]), 
		.data_o(z[7:4])
	 );
	 
	 LOD4 lod4_0 (
		.data_i(data_i[3:0]), 
		.data_o(z[3:0])
	 );
	 
	 LOD2 lod2_middle (
		.data_i(zdet), 
		.data_o(select)
	 );
	 
	 //*****************************************
	 // Multiplexers :
	 //*****************************************
	 
	 Muxes2in1Array4 Inst_MUX214_1 (
		.data_i(z[7:4]), 
		.select_i(select[1]), 
		.data_o(data_o[7:4])
    );
	 
	 Muxes2in1Array4 Inst_MUX214_0 (
		.data_i(z[3:0]), 
		.select_i(select[0]), 
		.data_o(data_o[3:0])
    );
endmodule


module Barrel8L(
    input [7:0] data_i,
    input [2:0] shift_i,
    output reg [7:0] data_o
    );
	 
   always @*
      case (shift_i)
         3'b000: data_o = data_i;
         3'b001: data_o = data_i << 1;
         3'b010: data_o = data_i << 2;
         3'b011: data_o = data_i << 3;
         3'b100: data_o = data_i << 4;
         3'b101: data_o = data_i << 5;
         3'b110: data_o = data_i << 6;
         default: data_o = data_i << 7;
      endcase
endmodule

module Barrel8R(
    input [7:0] data_i,
    input [2:0] shift_i,
    output reg [7:0] data_o
    );
   
   always @*
      case (shift_i)
         3'b000: data_o = data_i;
         3'b001: data_o = data_i >> 1;
         3'b010: data_o = data_i >> 2;
         3'b011: data_o = data_i >> 3;
         3'b100: data_o = data_i >> 4;
         3'b101: data_o = data_i >> 5;
         3'b110: data_o = data_i >> 6;
         default: data_o = data_i >> 7;
      endcase
endmodule


module Barrel16L(
    input [15:0] data_i,
    input [3:0] shift_i,
    output reg [15:0] data_o
    );
	 
   always @*
      case (shift_i)
         4'b0000: data_o = data_i;
         4'b0001: data_o = data_i << 1;
         4'b0010: data_o = data_i << 2;
         4'b0011: data_o = data_i << 3;
         4'b0100: data_o = data_i << 4;
         4'b0101: data_o = data_i << 5;
         4'b0110: data_o = data_i << 6;
         4'b0111: data_o = data_i << 7;
         default:  data_o = data_i << 8;
      endcase


endmodule

module FAd(a,b,c,cy,sm);
	input a,b,c;
	output cy,sm;
	wire x,y,z;
	xor x1(x,a,b);
	xor x2(sm,x,c);
	and a1(y,a,b);
	and a2(z,x,c);
	or o1(cy,y,z);
endmodule

module carry_lookahead_adder
  #(parameter WIDTH = 16)
  (
   input [WIDTH-1:0] i_add1,
   input [WIDTH-1:0] i_add2,
	input cin,
   output [WIDTH-1:0]  o_result
   );
     
  wire [WIDTH:0]     w_C;
  wire [WIDTH-1:0]   w_G, w_P, w_SUM;
 

 
  // Create the Full Adders
  genvar  ii;
  generate
    for (ii=0; ii<WIDTH; ii=ii+1) 
      begin: mod_carry
        FA full_adder_inst
            ( 
              .a(i_add1[ii]),
              .b(i_add2[ii]),
              .c(w_C[ii]),
              .sm(w_SUM[ii]),
              .cy()
              );
      end
  endgenerate
 
  // Create the Generate (G) Terms:  Gi=Ai*Bi
  // Create the Propagate Terms: Pi=Ai+Bi
  // Create the Carry Terms:
  genvar jj;
  generate
    for (jj=0; jj<WIDTH; jj=jj+1) 
      begin: mod_sum
        assign w_G[jj]   = i_add1[jj] & i_add2[jj];
        assign w_P[jj]   = i_add1[jj] | i_add2[jj];
        assign w_C[jj+1] = w_G[jj] | (w_P[jj] & w_C[jj]);
      end
  endgenerate
   
  assign w_C[0] = cin; 
  
  assign o_result = {w_SUM};   // Verilog Concatenation
 
endmodule // carry_lookahead_adder

module FA(a,b,c,cy,sm);
	input a,b,c;
	output cy,sm;
	wire x,y,z;
	xor x1(x,a,b);
	xor x2(sm,x,c);
	and a1(y,a,b);
	and a2(z,x,c);
	or o1(cy,y,z);
endmodule


module carry_lookahead_inc
  (
    input [3:0] i_add1,
    output [3:0]  o_result
   );
     
  wire [4:0]     w_C;
  wire [3:0]   w_SUM;
 
  // Create the HA Adders
  genvar  ii;
  generate 
    for (ii=0; ii<4; ii=ii+1) 
      begin: once_told
         assign w_SUM[ii] = i_add1[ii] ^ w_C[ii];
      end
  endgenerate
 
  // Create the Generate (G) Terms:  Gi=Ai*Bi
  // Create the Propagate Terms: Pi=Ai+Bi
  // Create the Carry Terms:
  genvar jj;
  generate
    for (jj=0; jj<4; jj=jj+1) 
      begin : someone
        assign w_C[jj+1] = (i_add1[jj] & w_C[jj]);
      end
  endgenerate
   
  assign w_C[0] = 1'b1; // Input carry is 1
 
  assign o_result = w_SUM;   // Verilog Concatenation
 
endmodule // carry_lookahead_adder