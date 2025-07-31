module TE_Top(
    input        clk,
    input        rst,
            
    input [23:0] input_pixel,
    input        input_is_valid,
            
    output [7:0] transmission,
    output       trans_valid
);
            
    wire [23:0] output_pixel_1, output_pixel_2, output_pixel_3,
                output_pixel_4, output_pixel_5, output_pixel_6,
                output_pixel_7, output_pixel_8, output_pixel_9;
    wire        valid;
    wire        ale_valid;
            
    WindowGeneratorTop WindowGenerator(
        .clk(clk),
        .rst(rst),
        
        .input_pixel(input_pixel),
        .input_is_valid(input_is_valid),
    
        .output_pixel_1(output_pixel_1),
        .output_pixel_2(output_pixel_2),
        .output_pixel_3(output_pixel_3),
        .output_pixel_4(output_pixel_4),
        .output_pixel_5(output_pixel_5),
        .output_pixel_6(output_pixel_6),
        .output_pixel_7(output_pixel_7),
        .output_pixel_8(output_pixel_8),
        .output_pixel_9(output_pixel_9),
        .output_is_valid(valid)
    );
    
    wire [7:0] a_r, a_g, a_b;
    wire [8:0] inv_a_r, inv_a_g, inv_a_b;
    
    ALE ALE(
        .clk(clk),
        .rst(rst),
        
        .input_valid(valid),
        .output_pixel_1(output_pixel_1),
        .output_pixel_2(output_pixel_2),
        .output_pixel_3(output_pixel_3),
        .output_pixel_4(output_pixel_4),
        .output_pixel_5(output_pixel_5),
        .output_pixel_6(output_pixel_6),
        .output_pixel_7(output_pixel_7),
        .output_pixel_8(output_pixel_8),
        .output_pixel_9(output_pixel_9),
        
        .o_a_r(a_r),
        .o_a_g(a_g),
        .o_a_b(a_b),
        
        .o_inv_a_r(inv_a_r),
        .o_inv_a_g(inv_a_g),
        .o_inv_a_b(inv_a_b),
        
        .o_valid(ale_valid)
    );
    
    TE Trans(
        .clk(clk),
        .rst(rst),
    
        .input_is_valid(valid),
        .in1(output_pixel_1),
        .in2(output_pixel_2),
        .in3(output_pixel_3),
        .in4(output_pixel_4),
        .in5(output_pixel_5),
        .in6(output_pixel_6),
        .in7(output_pixel_7),
        .in8(output_pixel_8),
        .in9(output_pixel_9),
   
        .inv_ar(inv_a_r),
        .inv_ag(inv_a_g),
        .inv_ab(inv_a_b),
        .atm_valid(ale_valid),
        .transmission(transmission),
        .output_is_valid(trans_valid) 
   );
            
endmodule
