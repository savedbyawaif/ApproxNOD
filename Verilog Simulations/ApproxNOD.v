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