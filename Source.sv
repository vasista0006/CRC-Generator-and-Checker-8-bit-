// 8-bit CRC Generator and Checker using polynomial x^8 + x^2 + x + 1 (0x07)
module crc8 #(
    parameter POLY = 8'h07
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        data_valid,
    input  logic [7:0]  data_in,
    input  logic        mode,       // 0 = generate, 1 = check
    input  logic [7:0]  rx_crc,     // received CRC (for check mode)
    output logic [7:0]  crc_out,
    output logic        crc_ok
);

    logic [7:0] crc_reg, next_crc;

    // Sequential CRC update
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            crc_reg <= 8'h00;
        else if (data_valid)
            crc_reg <= next_crc;
    end

    // Combinational CRC calculation
    integer i;
    always_comb begin
        next_crc = crc_reg;
        for (i = 0; i < 8; i++) begin
            if ((next_crc[7] ^ data_in[i]) == 1'b1)
                next_crc = (next_crc << 1) ^ POLY;
            else
                next_crc = (next_crc << 1);
        end
    end

    assign crc_out = crc_reg;

    // Checker mode: compare computed and received CRCs
    assign crc_ok = (mode && data_valid) ? (crc_reg == rx_crc) : 1'b0;

endmodule
