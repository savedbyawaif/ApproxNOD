`timescale 1ns / 1ps

module tb_NOD8;

    reg [7:0] data_i;
    wire zero_o;
    wire [8:0] data_o;

    NOD8 dut ( //replace with name of NOD
        .data_i(data_i),
        .zero_o(zero_o),
        .data_o(data_o)
    );

    initial begin
        $dumpfile("NOD8_waveform.vcd");
        $dumpvars(0, tb_NOD8);

        // Test case 1
        data_i = 8'b11001100;
        #5000; // Wait for some time
        // Check outputs
        $display("Time=%d data_i=%b zero_o=%b data_o=%b", $time, data_i, zero_o, data_o);

        // Test case 2
        data_i = 8'b10101010;
        #10000; // Wait for some time
        // Check outputs
        $display("Time=%d data_i=%b zero_o=%b data_o=%b", $time, data_i, zero_o, data_o);

        // Add more test cases as needed

        // Finish simulation
        $finish;
    end

endmodule
