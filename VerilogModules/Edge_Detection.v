module ED(
    input  wire [7:0] in0,
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    input  wire [7:0] in3,
    input  wire [7:0] in4,
    input  wire [7:0] in5,
    input  wire [7:0] in6,
    input  wire [7:0] in7,
    input  wire [7:0] in8,
    
    output wire [1:0] ED_out
);
    //Threshold D = 80
    parameter D = 8'b01010000;
    
    wire signed [8:0] v1 = $signed(in0) - $signed(in8);
    wire signed [8:0] v2 = $signed(in2) - $signed(in6);
    wire signed [8:0] v3 = $signed(in1) - $signed(in7);
    wire signed [8:0] v4 = $signed(in3) - $signed(in5);
    
    wire [7:0] abs_v1 = (v1[8]) ? -v1[7:0] : v1[7:0];
    wire [7:0] abs_v2 = (v2[8]) ? -v2[7:0] : v2[7:0];
    wire [7:0] abs_v3 = (v3[8]) ? -v3[7:0] : v3[7:0];
    wire [7:0] abs_v4 = (v4[8]) ? -v4[7:0] : v4[7:0];
    
    wire cond1 = (abs_v1 >= D) || (abs_v2 >= D);
    wire cond2 = (abs_v3 >= D) || (abs_v4 >= D);
    

    assign ED_out = cond1 ? 2'b10 : 
                   cond2 ? 2'b01 : 
                           2'b00;
                           
endmodule