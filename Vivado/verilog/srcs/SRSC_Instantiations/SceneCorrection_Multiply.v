// Compute Ac^β * Jc^(1-β)
module Saturation_Correction_Multiplier (
    input  [15:0] x1,       // Q3.13 format
    input  [15:0] x2,       // Q6.10 format
    output  [7:0] result    // Unsigned 8-bit output
);
    
    // Q3.13 * Q6.10 = Q9.23
    wire [31:0] mult_result = x1 * x2;
    
    // Trim off fractional bits
    wire [8:0] int_val = mult_result[31:23];
    
    // Scale down to 8 bit value
    assign result = (int_val > 9'd255) ? 8'd255 : int_val[7:0];
    
endmodule
