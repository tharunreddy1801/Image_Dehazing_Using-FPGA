module ED_Top(
    input        input_is_valid,
    input [23:0] output_pixel_1,
    input [23:0] output_pixel_2,
    input [23:0] output_pixel_3,
    input [23:0] output_pixel_4,
    input [23:0] output_pixel_5,
    input [23:0] output_pixel_6,
    input [23:0] output_pixel_7,
    input [23:0] output_pixel_8,
    input [23:0] output_pixel_9,
    
    output [1:0] ED1_out,ED2_out,ED3_out
);
    
    ED red_edges_detection(
        .in1(output_pixel_1[23:16]),
        .in2(output_pixel_2[23:16]),
        .in3(output_pixel_3[23:16]),
        .in4(output_pixel_4[23:16]),
        .in5(output_pixel_5[23:16]),
        .in6(output_pixel_6[23:16]),
        .in7(output_pixel_7[23:16]),
        .in8(output_pixel_8[23:16]),
        .in9(output_pixel_9[23:16]),
        
        .ED_out(ED1_out)
    );
        
    ED green_edges_detection(
        .in1(output_pixel_1[15:8]),
        .in2(output_pixel_2[15:8]),
        .in3(output_pixel_3[15:8]),
        .in4(output_pixel_4[15:8]),
        .in5(output_pixel_5[15:8]),
        .in6(output_pixel_6[15:8]),
        .in7(output_pixel_7[15:8]),
        .in8(output_pixel_8[15:8]),
        .in9(output_pixel_9[15:8]),
        
        .ED_out(ED2_out)
    );
        
    ED blue_edges_detection(
        .in1(output_pixel_1[7:0]),
        .in2(output_pixel_2[7:0]),
        .in3(output_pixel_3[7:0]),
        .in4(output_pixel_4[7:0]),
        .in5(output_pixel_5[7:0]),
        .in6(output_pixel_6[7:0]),
        .in7(output_pixel_7[7:0]),
        .in8(output_pixel_8[7:0]),
        .in9(output_pixel_9[7:0]),
        
        .ED_out(ED3_out)
    );
    
endmodule
