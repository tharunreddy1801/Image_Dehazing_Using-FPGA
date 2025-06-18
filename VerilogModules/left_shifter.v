module left_shifter(
    input [7:0] in,
    output wire [15:0] out
);
    
    assign out = in << 8;
    
endmodule