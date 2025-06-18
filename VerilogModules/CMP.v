`timescale 1ns/1ps
module cmp_8bit(
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire gt  
);
    assign gt = (a > b);
endmodule
