module Multiplier_SRSC(
    input  [7:0]  Ic_minus_Ac,             // Q8.0
    input  [15:0] Inv_Trans,               // Q2.14
    output [7:0]  result
);

    wire [23:0] product_full;
    assign product_full = Ic_minus_Ac * Inv_Trans; // Q10.14

    // Add half (2^13) for rounding before right shift
    wire [23:0] rounded_product = product_full + 24'd8192;

    wire [15:0] product_scaled;
    assign product_scaled = rounded_product >> 14; // Q8.0

    assign result = (product_scaled > 255) ? 8'd255 : product_scaled[7:0];

endmodule
