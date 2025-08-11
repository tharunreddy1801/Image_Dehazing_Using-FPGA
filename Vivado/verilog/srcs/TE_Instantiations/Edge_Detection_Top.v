// Detect the type of edge in a given 3x3 window of RGB Pixels : Diagonal, Horizontal, Vertical or no edge
module ED_Top (
    input [23:0] input_pixel_1,
    input [23:0] input_pixel_2,
    input [23:0] input_pixel_3,
    input [23:0] input_pixel_4,

    input [23:0] input_pixel_6,
    input [23:0] input_pixel_7,
    input [23:0] input_pixel_8,
    input [23:0] input_pixel_9,
    
    output [1:0] ED1_out, ED2_out, ED3_out
);
    
    ED Red_Edges_Detection (
        .input_pixel_1(input_pixel_1[23:16]),
        .input_pixel_2(input_pixel_2[23:16]),
        .input_pixel_3(input_pixel_3[23:16]),
        .input_pixel_4(input_pixel_4[23:16]),

        .input_pixel_6(input_pixel_6[23:16]),
        .input_pixel_7(input_pixel_7[23:16]),
        .input_pixel_8(input_pixel_8[23:16]),
        .input_pixel_9(input_pixel_9[23:16]),
        
        .ED_out(ED1_out)
    );
        
    ED Green_Edges_Detection (
        .input_pixel_1(input_pixel_1[15:8]),
        .input_pixel_2(input_pixel_2[15:8]),
        .input_pixel_3(input_pixel_3[15:8]),
        .input_pixel_4(input_pixel_4[15:8]),

        .input_pixel_6(input_pixel_6[15:8]),
        .input_pixel_7(input_pixel_7[15:8]),
        .input_pixel_8(input_pixel_8[15:8]),
        .input_pixel_9(input_pixel_9[15:8]),
        
        .ED_out(ED2_out)
    );
        
    ED Blue_Edges_Detection (
        .input_pixel_1(input_pixel_1[7:0]),
        .input_pixel_2(input_pixel_2[7:0]),
        .input_pixel_3(input_pixel_3[7:0]),
        .input_pixel_4(input_pixel_4[7:0]),

        .input_pixel_6(input_pixel_6[7:0]),
        .input_pixel_7(input_pixel_7[7:0]),
        .input_pixel_8(input_pixel_8[7:0]),
        .input_pixel_9(input_pixel_9[7:0]),
        
        .ED_out(ED3_out)
    );
    
endmodule
