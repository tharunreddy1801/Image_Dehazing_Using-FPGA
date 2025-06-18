module mux3to1_8bit(
    input [7:0] in0, in1, in2,
    input [1:0] sel,
    output wire [7:0] out
);
    
    assign out = (sel == 2'b00) ? in0 :
                (sel == 2'b01) ? in1 :
                (sel == 2'b10) ? in2 :
                8'b00000000;
endmodule
