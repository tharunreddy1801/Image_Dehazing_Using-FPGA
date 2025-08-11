module Multiplier_SRSC (
    input  [7:0]  Ic_minus_Ac, // Q8.0
    input  [15:0] Inv_Trans,   // Q2.14
    output [7:0]  result       // Q8.0
);

    // Q8.0 * Q2.14 = Q10.14
    wire [23:0] mult_result = Ic_minus_Ac * Inv_Trans;

    // Trim off fractional bits
    wire [9:0] scaled_result = mult_result >> 14;

    // Saturate to 8-bit range
    assign result = (scaled_result > 255) ? 8'd255 : scaled_result[7:0];

endmodule
