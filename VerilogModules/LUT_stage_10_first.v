module exponent_lut_beta_0p3 (
    input  wire [7:0]  in,   // 8-bit binary input
    output reg  [15:0] out   // 16-bit output in 1.15 fixed-point format
);

    // Create a LUT with 256 entries (for 8-bit input)
    reg [15:0] lut_mem [0:255];

    // Initialize the LUT at simulation time.
    // For synthesis, you might load this data from an external file.
    initial begin : LUT_INIT
        integer i;
        real x_norm;
        real result;
        for (i = 0; i < 256; i = i + 1) begin
            // Normalize the 8-bit input to [0,1].
            x_norm = i / 255.0;
            
            // Compute the exponentiation: (x_norm)^0.3.
            // Note: 0^0.3 is defined as 0.
            result = x_norm ** 0.3;
            
            // Convert the real result to a fixed-point 1.15 format.
            // Multiply by 2^15 to shift the fractional part.
            lut_mem[i] = $rtoi(result * (1 << 15));
        end
    end

    // Combinational logic: output the LUT value corresponding to in_value.
    always @(*) begin
        out = lut_mem[in];
    end

endmodule
