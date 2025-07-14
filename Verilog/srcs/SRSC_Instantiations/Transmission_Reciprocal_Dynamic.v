module Trans_LUT (
    input  [15:0] x, // Q0.16 input (unsigned)
    output [15:0] y  // Q2.14 output (unsigned)
);

    wire [31:0] reciprocal;

    assign reciprocal = (x != 0) ? (32'd1073741824 / x) : 32'd4;
    assign y  = reciprocal[15:0]; // Truncate to 16 bits (Q2.14)

endmodule
