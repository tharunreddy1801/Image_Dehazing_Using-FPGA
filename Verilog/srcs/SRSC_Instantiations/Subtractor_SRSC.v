module Subtractor_SRSC(
    input [7:0]  Ic,
    input [7:0]  Ac, 
    
    output [7:0] diff,
    output       add_or_sub
);

    assign diff = (Ic > Ac) ? (Ic - Ac) : (Ac - Ic);
    assign add_or_sub = (Ic > Ac) ? 1 : 0;
    
endmodule
