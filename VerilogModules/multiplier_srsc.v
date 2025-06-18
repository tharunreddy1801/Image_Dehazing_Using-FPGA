module multiplier_srsc(
    input [7:0] a,
    input [15:0] b,
    output wire [31:0] product
);
    
    assign product = a * b;
    
endmodule