`timescale 1ns / 1ps
//change all 16 -> 
module ILM_AE(
  	input [7:0] x,
  	input [7:0] y,
  output [15:0] p
    );

			 
	// LOD x
  	wire [8:0] kx;
	wire zero_x;
  	wire [3:0] code_x;


	NOD8 NODx (
		.data_i(x),
		.zero_o(zero_x),
		.data_o(kx)
	 ); 
	 

	PriorityEncoder_8 PEx (
		.data_i(kx),
		.code_o(code_x)
	 ); 
	 
	// LOD y

  	wire [8:0] ky;
	wire zero_y;
 	wire [3:0] code_y;

	NOD8 NODy (
		.data_i(y),
		.zero_o(zero_y),
		.data_o(ky)
	 ); 

	PriorityEncoder_8 PEy (
			.data_i(ky),
			.code_o(code_y)
		 ); 

  
	// Subtractor 
	wire signed [8:0] sub_x;
	wire signed [8:0] tmp_x;
	assign tmp_x = {1'b0,x};
	assign sub_x = tmp_x - kx;	
	
 
	wire signed [8:0] sub_y;
	wire signed [8:0] tmp_y;
	assign tmp_y = {1'b0,y};
	assign sub_y = tmp_y - ky;	
	
	// Add k_x and k_y
	wire [5:0] code_sum;
	assign code_sum = code_x + code_y;

	// decoder 
	wire [15:0] dec_out;
	Decoder16 dec(code_sum,dec_out);

	// shifter sub_x and ky
	wire signed [15:0] pp_x;
	assign pp_x = sub_x << code_y;

	// shifter sub_x and ky
	wire signed [15:0] pp_y;
	assign pp_y = sub_y << code_x;
	 
	// shigfter
	wire signed [15:0] tmp_pp;
	assign tmp_pp = pp_x + pp_y + dec_out;

	// is zero 
	wire not_zero;
	assign not_zero = (~zero_x | x[7] | x[0]) & (~zero_y | y[7] | y[0]);
	
	assign p = not_zero ? tmp_pp : 16'b0;
	
endmodule



module PriorityEncoder_8(
  	input [8:0] data_i,
  	output [3:0] code_o
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
    
  assign code_o[3] = data_i[8];
endmodule


module OR_tree(
  input [3:0] data_i,
    output data_o
    );
    
  wire [1:0] tmp1;
  assign tmp1 = data_i[1:0] | data_i[3:2];
  assign data_o = tmp1[0] | tmp1[1];
endmodule

module NOD8(
    input [7:0] data_i,
    output zero_o,
    output [8:0] data_o
    );

	wire [8:0] z;
  	wire zdet[1:0];
	wire zselect;
  	wire muxselect;
	wire [1:0] select;

  	assign zselect = (~data_i[3] & ~data_i[2]) | (~data_i[3] & (data_i[2] & ~data_i[1] & ~data_i[0]));
  	assign zdet[1] = (data_i[7] | data_i[6] | data_i[5] | data_i[4]);
  	assign zdet[0] = (data_i[3] | data_i[2] | data_i[1] | data_i[0]);
  	assign muxselect = zdet[1] | (data_i[3] & data_i[2]);
	assign zero_o = ~(zdet[1] | zdet[0]);

	
	NOD_carry_unit NOD1 (
		.data_i(data_i[7:2]),
		.data_o(z[8:4])
	);

	ApproxSelect aSelect(
		.data_i(zselect),
		.data_o(z[3:0])
	);

	Mux2Out9bit muxOut(
		.data_i1(z[8:4]),
		.data_i2(z[3:0]),
      	.select_i(muxselect),
		.data_o(data_o)
	);

endmodule

module Mux2Out9bit (
	input [4:0] data_i1,
	input [3:0] data_i2,
	input select_i,
	output [8:0] data_o
);
	assign data_o[8:4] = select_i ? data_i1[4:0] : 5'b00000;
	assign data_o[3:0] = select_i ? 4'b0000 : data_i2[3:0];
endmodule

module NOD_carry_unit(
	input [5:0] data_i,
	output [4:0] data_o
);

//multiplexer result
wire mux0;
wire mux1;
wire mux2;
wire mux3;

//ctrl signal
wire ctrl0;
wire ctrl1;
wire ctrl2;
wire ctrl3;
wire ctrl4;

//ctrl bit allocation
assign ctrl4 = data_i[5] & data_i[4];
assign ctrl3 = data_i[5] | (data_i[4] & data_i[3]);
assign ctrl2 = data_i[4] | (data_i[3] & data_i[2]);
assign ctrl1 = data_i[3] | (data_i[2] & data_i[1]);
assign ctrl0 = data_i[2] | (data_i[1] & data_i[0]);

//multiplexer
assign mux3 = (ctrl4==1) ? 1'b0 : 1'b1;
  assign mux2 = (ctrl3==1) ? 1'b0 : mux3;
  assign mux1 = (ctrl2==1) ? 1'b0 : mux2;
  assign mux0 = (ctrl1==1) ? 1'b0 : mux1;

//gates and IO assignments
assign data_o[4] = ctrl4;
assign data_o[3] = (mux3 & ctrl3);
assign data_o[2] = (mux2 & ctrl2);
assign data_o[1] = (mux1 & ctrl1);
assign data_o[0] = (mux0 & ctrl0);

endmodule

module ApproxSelect(
	input data_i,
	output [3:0] data_o
);

  assign data_o[3:0] = (data_i==1) ? 4'b0010 : 4'b1000;
endmodule

module Decoder16(
    input [5:0] code_i,
    output [15:0] data_o
    );
	 
	assign data_o = (1 << code_i);
endmodule





