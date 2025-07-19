module Multiplier(
    input  [15:0] Ac_Inv, // Inverted Atmospheric Light value in Q0.16 format
    input  [7:0]  Pc,     // Edge Detection Filter result
    output [15:0] product // OMEGA * min(Pc / Ac) ; c ∈ {R, G, B} in Q0.16 format
);

    // Constants in Q0.16 format
    parameter [15:0] OMEGA      = 16'd61440;   // 0.9375 in Q0.16
    parameter [15:0] MAX_OUTPUT = 16'd47415;   // (1 - 0.275) = 0.725 in Q0.16

    // Unscaled result is in Q8.16 format
    wire [23:0] unscaled_product = Ac_Inv * Pc;

    // Scale the result with OMEGA (Q0.16)
    // Scaled result is in Q8.32 format
    wire [39:0] scaled_product = unscaled_product * OMEGA;

    // Trim the product down to Q0.16 format
    wire [15:0] result = scaled_product[31:16];

    // Check if the unscaled product is greater than 1 to prevent roll around due to negative result in the Subtractor circuit
    wire is_gt_one = (unscaled_product[23:16] != 0);

    // Clamp output to 0.75 if overflow occurred
    assign product = is_gt_one ? MAX_OUTPUT : result;

endmodule
