module Multiplier(
    input [15:0]  a,
    input [7:0]   b,
    
    output [15:0] product
);
    
    parameter [15:0] Omega = 16'd61440;
    
    wire [23:0] mult_1 = a * b;
    wire [15:0] mult_1_trimmed = mult_1[15:0];
    
    wire [31:0] mult_2 = mult_1_trimmed * Omega;
    
    assign product = mult_2[31:16];
    
endmodule
