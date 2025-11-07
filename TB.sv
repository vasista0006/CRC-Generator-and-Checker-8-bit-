`timescale 1ns/1ps

module tb_crc8;

    logic clk, rst, data_valid, mode;
    logic [7:0] data_in, rx_crc, crc_out;
    logic crc_ok;

    // Instantiate DUT
    crc8 dut (
        .clk(clk),
        .rst(rst),
        .data_valid(data_valid),
        .data_in(data_in),
        .mode(mode),
        .rx_crc(rx_crc),
        .crc_out(crc_out),
        .crc_ok(crc_ok)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Stimulus
    initial begin
        $dumpfile("crc8.vcd");
        $dumpvars(0, tb_crc8);
        rst = 1; data_valid = 0; mode = 0; data_in = 8'h00; rx_crc = 8'h00;
        #15 rst = 0;

        // --- CRC Generation Mode ---
        mode = 0;
        data_valid = 1;
        data_in = 8'hA5; #10;  // input data = 0xA5
        data_in = 8'h5A; #10;  // input data = 0x5A
        data_valid = 0;

        #20;
        $display("Generated CRC = %h", crc_out);
        rx_crc = crc_out;

        // --- CRC Check Mode ---
        mode = 1;
        data_valid = 1;
        data_in = 8'hA5; #10;
        data_in = 8'h5A; #10;
        data_valid = 0;
        #10;
        $display("CRC_OK = %b (1 = Pass, 0 = Fail)", crc_ok);

        // Introduce error
        rx_crc = crc_out ^ 8'h01; // flip 1 bit
        data_valid = 1;
        data_in = 8'hA5; #10;
        data_in = 8'h5A; #10;
        data_valid = 0;
        #10;
        $display("After error injection CRC_OK = %b (should be 0)", crc_ok);

        #20;
        $finish;
    end

endmodule
