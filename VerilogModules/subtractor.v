module subtractor_12_bit(
    input wire [11:0]a,b,
    output wire [11:0]sub
    );
    
    assign sub = a - b;

endmodule