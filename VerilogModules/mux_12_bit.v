module mux3to1_12bit(
    input [11:0] in0, in1, in2,
    input [1:0] sel,
    output wire [11:0] out
);
    
    assign out = (sel == 2'b00) ? in0 :
                 (sel == 2'b01) ? in1 :
                 (sel == 2'b10) ? in2 :
                 8'b000000000000;
endmodule
