module Adder_SRSC(
    input [7:0]  Ac,
    input [7:0]  Multiplier_out,
    
    input        add_or_sub,

    output [7:0] out
);
    
    assign out = add_or_sub ? ((Ac+ Multiplier_out > 8'd255) ? 8'd255 : (Ac + Multiplier_out)) :
                              ((Ac > Multiplier_out) ? (Ac - Multiplier_out) : 8'd0);
    
endmodule
