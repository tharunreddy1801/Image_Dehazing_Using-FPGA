module final_multiplier_srsc(
    input [15:0] a,
    input [15:0] b,
    output wire [7:0] product
);
    
    assign product = a * b;
    
endmodule