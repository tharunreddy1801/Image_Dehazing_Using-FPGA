module or_gate(
    input wire [7:0]a,b,c,
    output wire [7:0] out
);

    assign out = a | b | c;
    
endmodule