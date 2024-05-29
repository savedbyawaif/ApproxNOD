`timescale 1ns / 1ps
module NOD8(
    input [7:0] data_i,
    output zero_o,
    output [8:0] data_o
    );

	wire [8:0] z;
	wire [1:0] zdet;
	wire [1:0] select;

	assign zdet[1] = (data_i[7] | data_i[6] | data_i[5] | data_i[4]) | (data_i[3] & data_i[2]);
	assign zdet[0] = data_i[3] | data_i[2] | data_i[1] | data_i[0];
	assign zero_o = ~(zdet[1] | zdet[0]);
	
	NOD_carry_unit NOD1 (
		.data_i(data_i[7:2]),
		.data_o(z[8:4])
	);

	NOD_base_unit NOD0 (
		.data_i(data_i[3:0]),
		.data_o(z[3:0])
	);

	LOD2 LOD(
		.data_i(zdet),
		.data_o(select)
	);

	Mux2Out5bit MUX1(
		.data_i(z[8:4]),
		.select_i(select[1]),
      .data_o(data_o[8:4])
	);

	Mux2Out4bit MUX2(
		.data_i(z[3:0]),
		.select_i(select[0]),
		.data_o(data_o[3:0])
	);

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

module Mux2Out4bit (
	input[3:0] data_i,
	input select_i,
  	output[3:0] data_o
);
	assign data_o[3] = select_i ? data_i[3] : 1'b0;
	assign data_o[2] = select_i ? data_i[2] : 1'b0;
	assign data_o[1] = select_i ? data_i[1] : 1'b0;
	assign data_o[0] = select_i ? data_i[0] : 1'b0;

endmodule

module Mux2Out5bit (
	input[4:0] data_i,
	input select_i,
  	output[4:0] data_o
);
  	assign data_o[4] = select_i ? data_i[4] : 1'b0;
	assign data_o[3] = select_i ? data_i[3] : 1'b0;
	assign data_o[2] = select_i ? data_i[2] : 1'b0;
	assign data_o[1] = select_i ? data_i[1] : 1'b0;
	assign data_o[0] = select_i ? data_i[0] : 1'b0;

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

module NOD_base_unit(
	input [3:0] data_i,
	output [3:0] data_o
);
//multiplexer result
wire mux0;
wire mux1;
wire mux2;

//ctrl signal
wire ctrl1;
wire ctrl2;
wire ctrl3;

//ctrl bit allocation
assign ctrl3 = data_i[3] | (data_i[2] & data_i[1]);
assign ctrl2 = data_i[2] | (data_i[1] & data_i[0]);
assign ctrl1 = data_i[1];

//multiplexer
assign mux2 = (ctrl3==1) ? 1'b0 : 1'b1;
assign mux1 = (ctrl2==1) ? 1'b0 : mux2;
assign mux0 = (ctrl1==1) ? 1'b0 : mux1;

//gates and IO assignments
assign data_o[3] = ctrl3;
assign data_o[2] = (mux2 & ctrl2);
assign data_o[1] = (mux1 & ctrl1);
assign data_o[0] = (mux0 & data_i[0]);

endmodule
