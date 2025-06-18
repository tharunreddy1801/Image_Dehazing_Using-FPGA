//`timescale 1ns/1ps
//module ale_top(
//input clk,
//input rst,
//input [23:0]input_pixel,
//input input_is_valid,

//output wire [7:0] a_r,
//output wire [7:0] a_g,
//output wire [7:0] a_b,
//output wire [15:0] inv_a_r,
//output wire [15:0] inv_a_g,
//output wire [15:0] inv_a_b,
//output wire ale_valid
//);

// wire [23:0] output_pixel_1, output_pixel_2, output_pixel_3, output_pixel_4,
//            output_pixel_5, output_pixel_6, output_pixel_7,output_pixel_8,output_pixel_9;
// wire valid;
//WindowGeneratorTop W1(
//        .clk(clk),
//        .rst(rst),
        
//        .input_pixel(input_pixel),
//        .input_is_valid(input_is_valid),
    
//        .output_pixel_1(output_pixel_1),
//        .output_pixel_2(output_pixel_2),
//        .output_pixel_3(output_pixel_3),
//        .output_pixel_4(output_pixel_4),
//        .output_pixel_5(output_pixel_5),
//        .output_pixel_6(output_pixel_6),
//        .output_pixel_7(output_pixel_7),
//        .output_pixel_8(output_pixel_8),
//        .output_pixel_9(output_pixel_9),
//        .output_is_valid(valid)
//    );
//    ALE A1(
//        .clk(clk),
//        .rst(rst),
//        .input_valid(valid),
//        .output_pixel_1(output_pixel_1),
//        .output_pixel_2(output_pixel_2),
//        .output_pixel_3(output_pixel_3),
//        .output_pixel_4(output_pixel_4),
//        .output_pixel_5(output_pixel_5),
//        .output_pixel_6(output_pixel_6),
//        .output_pixel_7(output_pixel_7),
//        .output_pixel_8(output_pixel_8),
//        .output_pixel_9(output_pixel_9),
//        .o_a_r(a_r),
//        .o_a_g(a_g),
//        .o_a_b(a_b),
//        .o_inv_a_r(inv_a_r),
//        .o_inv_a_g(inv_a_g),
//        .o_inv_a_b(inv_a_b),
//        .o_valid(ale_valid)
        
//    );
//    endmodule