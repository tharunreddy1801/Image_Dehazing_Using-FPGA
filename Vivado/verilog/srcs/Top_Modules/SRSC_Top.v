module SRSC_Top(
    input            clk,
    input            rst,
    
    input [23:0]     input_pixel,
    input            input_is_valid,
    
    output [7:0]     J_R, J_G, J_B,
    output           output_valid
);

    wire [23:0] output_pixel_1, output_pixel_2, output_pixel_3, 
                output_pixel_4, output_pixel_5, output_pixel_6, 
                output_pixel_7, output_pixel_8, output_pixel_9;
    wire        valid;

    wire [15:0] transmission;
    wire        te_output_valid;
    wire        atmospheric_data_ready;

    // 3x3 Window Generator
    WindowGeneratorTop W1(
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

    // Transmission Estimation Module
    TE TE (
        .clk(clk),
        .rst(rst),
        .input_is_valid(valid),
        .in1(output_pixel_1), .in2(output_pixel_2), .in3(output_pixel_3),
        .in4(output_pixel_4), .in5(output_pixel_5), .in6(output_pixel_6),
        .in7(output_pixel_7), .in8(output_pixel_8), .in9(output_pixel_9),
        .inv_ar('d320),
        .inv_ag('d317),
        .inv_ab('d323),
        .atm_valid(atmospheric_data_ready),
        .transmission(transmission),
        .output_is_valid(te_output_valid)
    );

    wire [7:0] I_R = output_pixel_5[23:16];
    wire [7:0] I_G = output_pixel_5[15:8];
    wire [7:0] I_B = output_pixel_5[7:0];

    // Scene Radiance Recovery
    SRSC SRSC (
        .clk(clk),
        .rst(rst),
        .I_R(I_R),
        .I_G(I_G),
        .I_B(I_B),
        .input_is_valid(te_output_valid),
        .A_R('d205),
        .A_G('d207),
        .A_B('d203),
        .transmission(transmission),
        .J_R(J_R),
        .J_G(J_G),
        .J_B(J_B),
        .o_valid(output_valid)
    );

endmodule


module SRSC (
    input          clk,
    input          rst,

    input [7:0]    I_R,
    input [7:0]    I_G, 
    input [7:0]    I_B,
    input          input_is_valid,

    input [7:0]    A_R,
    input [7:0]    A_G,
    input [7:0]    A_B,

    input [15:0]   transmission,

    output [7:0]   J_R,
    output [7:0]   J_G,
    output [7:0]   J_B,
    output         o_valid
);

    wire [7:0] diff_r, diff_g, diff_b;
    wire       c1, c2, c3;

    reg [7:0] red, green, blue;
    reg       c1_reg, c2_reg, c3_reg;
    reg       stage_1_valid;

    reg [15:0] inv_trans;

    reg [7:0] x, y, z;
    reg       c1_reg1, c2_reg1, c3_reg1;
    reg       stage_2_valid;

    // Absolute difference
    assign diff_r = (I_R > A_R) ? (I_R - A_R) : (A_R - I_R);
    assign diff_g = (I_G > A_G) ? (I_G - A_G) : (A_G - I_G);
    assign diff_b = (I_B > A_B) ? (I_B - A_B) : (A_B - I_B);
    assign c1 = (I_R > A_R) ? 1 : 0;
    assign c2 = (I_G > A_G) ? 1 : 0;
    assign c3 = (I_B > A_B) ? 1 : 0;

    wire [15:0] inv_trans_wire;
    Trans_LUT LUT (.x(transmission), .y(inv_trans_wire));

    // Stage 1: compute abs diff, register inv_trans
    always @(posedge clk) begin
        if (rst) begin
            red <= 8'd0;
            green <= 8'd0;
            blue <= 8'd0;
            
            c1_reg <= 0;
            c2_reg <= 0;
            c3_reg <= 0;
            
            inv_trans <= 16'd0;
            
            stage_1_valid <= 1'b0;
        end else begin
            red <= diff_r;
            green <= diff_g;
            blue <= diff_b;
            
            c1_reg <= c1;
            c2_reg <= c2;
            c3_reg <= c3;
            
            inv_trans <= inv_trans_wire;
            
            stage_1_valid <= input_is_valid;
        end
    end

    wire [7:0] xm, ym, zm;
    LUT_Multiplier m1 (.in_q2_14(inv_trans), .in_uint8(red),   .out_uint8(xm));
    LUT_Multiplier m2 (.in_q2_14(inv_trans), .in_uint8(green), .out_uint8(ym));
    LUT_Multiplier m3 (.in_q2_14(inv_trans), .in_uint8(blue),  .out_uint8(zm));

    // Stage 2: register LUT results
    always @(posedge clk) begin
        if (rst) begin
            x <= 8'd0;
            y <= 8'd0;
            z <= 8'd0;
            
            c1_reg1 <= 0;
            c2_reg1 <= 0;
            c3_reg1 <= 0;
            
            stage_2_valid <= 1'b0;
        end else begin
            x <= xm;
            y <= ym;
            z <= zm;
            
            c1_reg1 <= c1_reg;
            c2_reg1 <= c2_reg;
            c3_reg1 <= c3_reg;
            
            stage_2_valid <= stage_1_valid;
        end
    end

    // Final output
    assign J_R = c1_reg1 ? ((x + A_R > 8'd255) ? 8'd255 : (x + A_R)) :
                         ((A_R > x) ? (A_R - x) : 8'd0);
    assign J_G = c2_reg1 ? ((y + A_G > 8'd255) ? 8'd255 : (y + A_G)) :
                         ((A_G > y) ? (A_G - y) : 8'd0);
    assign J_B = c3_reg1 ? ((z + A_B > 8'd255) ? 8'd255 : (z + A_B)) :
                         ((A_B > z) ? (A_B - z) : 8'd0);

    assign o_valid = stage_2_valid;

endmodule


