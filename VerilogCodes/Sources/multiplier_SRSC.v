module Multiplier_SRSC(
    input [7:0]p,
    input[15:0]q,
    
    output [15:0]result
    );
    
    wire [23:0] product = p*q;
    
    assign result = product >>14;
endmodule