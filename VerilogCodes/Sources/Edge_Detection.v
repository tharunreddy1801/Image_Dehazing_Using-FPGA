module ED(
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    input  wire [7:0] in3,
    input  wire [7:0] in4,
    input  wire [7:0] in5,
    input  wire [7:0] in6,
    input  wire [7:0] in7,
    input  wire [7:0] in8,
    input  wire [7:0] in9,
    
    output wire [1:0] ED_out
);
    parameter D = 8'b01010000;
    
    wire  [7:0] diag1_diff = (in1 > in9) ? (in1 - in9) : (in9 - in1);
    wire  [7:0] diag2_diff = (in3 > in7) ? (in3 - in7) : (in7 - in3);
    wire  [7:0] horizontal_diff = (in4 > in6) ? (in4 - in6) : (in6 - in4);
    wire  [7:0] vert_diff = (in2 > in8) ? (in2 - in8) : (in8 - in2);
    
    wire cond1 = (diag1_diff >= D) || (diag2_diff >= D);
    wire cond2 = (horizontal_diff >= D) || (vert_diff >= D);
    

    assign ED_out = cond1 ? 2'b10 : 
                                 cond2 ? 2'b01 : 
                                 2'b00;
                           
endmodule