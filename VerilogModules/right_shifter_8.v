module right_shifter_8(
    input [31:0] in,
    output wire [23:0] out
);
    
    assign out = in >> 8;
    
endmodule