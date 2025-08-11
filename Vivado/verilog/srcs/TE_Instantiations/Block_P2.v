
// Edge Preserving Filter applied when Diagonal Edges are detected
module Block_P2 (
    input clk, rst,
    
    input  [7:0] in1,
    input  [7:0] in2,
    input  [7:0] in3,
    input  [7:0] in4,
    input  [7:0] in5,
    input  [7:0] in6,
    input  [7:0] in7,
    input  [7:0] in8,
    input  [7:0] in9,
    
    output [7:0] p2_result
);
    
    // Pipeline Registers
    reg [7:0]   in1_P, in2_P, in3_P, 
                in4_P, in5_P, in6_P, 
                in7_P, in8_P, in9_P;
    
    wire [10:0] sum1, sum2, sum3;
    wire [11:0] sum;
    
    always @(posedge clk) begin
        if(rst) begin
            in1_P <= 0; in2_P <= 0; in3_P <= 0;
            in4_P <= 0; in5_P <= 0; in6_P <= 0;
            in7_P <= 0; in8_P <= 0; in9_P <= 0;
        end
        else begin
            in1_P <= in1; in2_P <= in2; in3_P <= in3;
            in4_P <= in4; in5_P <= in5; in6_P <= in6;
            in7_P <= in7; in8_P <= in8; in9_P <= in9;
        end
    end

    assign sum1 = (in1_P << 1) + in2_P + (in3_P << 1);
    assign sum2 = in4_P + (in5_P << 2) + in6_P;
    assign sum3 = (in7_P << 1) + in8_P + (in9_P << 1);

    assign sum = sum1 + sum2 + sum3;

    assign p2_result = sum >> 4;

endmodule
