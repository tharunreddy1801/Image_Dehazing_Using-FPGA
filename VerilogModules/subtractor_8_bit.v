module subtractor_8_bit(
    input wire [7:0]a,b,
    output wire [7:0]sub
    );
    
    assign sub = a - b;

endmodule