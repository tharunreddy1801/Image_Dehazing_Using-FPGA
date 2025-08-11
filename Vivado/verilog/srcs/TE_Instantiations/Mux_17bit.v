// Stage 7 multiplexer to choose the pre-transmission value based on edge detected
module Stage_7_Mux (
    input  [15:0] a, b, c,
    input  [1:0]  sel,
        
    output [15:0] out
);
    
    assign out = (sel == 2'b00) ? a : 
                 (sel == 2'b01) ? b : 
                 (sel == 2'b10) ? c :
                 'b0;
    
endmodule
