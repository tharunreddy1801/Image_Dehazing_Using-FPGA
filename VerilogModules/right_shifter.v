module right_shifter(
    input [16:0] in,
    output wire [11:0] out
);
    
    assign out = in >> 5;
    
endmodule