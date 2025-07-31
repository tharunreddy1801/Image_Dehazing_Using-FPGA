// Multiplexer to choose minimum Filtered Pixel Value
module Mux_1(
    input [7:0]  a, b, c,
    input [1:0]  sel,
    
    output [7:0] out
);
    
    assign out = (sel == 2'b00) ? a : 
                 (sel == 2'b01) ? b : 
                 (sel == 2'b10) ? c : 
                 8'b0;
    
endmodule

// Multiplexer to choose minimum Atmospheric Light Value
module Mux_2(
    input [15:0]  a, b, c,
    input [1:0]   sel,
    
    output [15:0] out
);
    
    assign out = (sel == 2'b00) ? a : 
                 (sel == 2'b01) ? b : 
                 (sel == 2'b10) ? c : 
                 16'b0;
    
endmodule
