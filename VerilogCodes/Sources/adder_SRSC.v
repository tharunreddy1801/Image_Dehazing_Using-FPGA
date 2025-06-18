module Adder_SRSC(
    input [7:0] a,
    input [15:0] b,
    
    input add_or_sub,

    output [7:0] out
    );
    
    wire [7:0] sum;
    
    assign sum = add_or_sub ? (a + b) : (a - b);
    assign out = sum >> 8;
    
endmodule
