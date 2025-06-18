module Subtractor_SRSC(
    input [7:0]a,
    input [7:0] b, 
    
    output [7:0]out,
    output add_or_sub
    );

    assign out = (a > b) ? (a - b) : (b - a);
    assign add_or_sub = (a > b);
endmodule