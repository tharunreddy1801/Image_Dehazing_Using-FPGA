module multiplier(
    input [8:0] a,
    input [7:0] b,
    output wire [16:0] product
);
    
    assign product = a * b;
    
endmodule