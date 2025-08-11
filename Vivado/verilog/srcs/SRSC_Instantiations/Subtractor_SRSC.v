module Subtractor_SRSC (
    input [7:0]  Ic,
    input [7:0]  Ac, 
    
    output [7:0] diff,      // |Ic - Ac|
    output       add_or_sub // Add with or subtract from Atmospheric Light in the Adder module
);
    
    parameter ADD = 1, SUB = 0;
    
    assign diff = (Ic > Ac) ? (Ic - Ac) : (Ac - Ic);
    
    assign add_or_sub = (Ic > Ac) ? ADD : SUB;
    
endmodule
