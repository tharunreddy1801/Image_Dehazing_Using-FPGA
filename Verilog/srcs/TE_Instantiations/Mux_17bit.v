//stage 7 multiplexer
module mux_17bit(
    input [15:0] m1, m2, m3,
    input [1:0]  sel,
        
    output [15:0] p
);
    
    assign p = (sel == 2'b00) ? m1 : 
               (sel == 2'b01) ? m2 : 
               (sel == 2'b10) ? m3 :
               0;
    
endmodule
