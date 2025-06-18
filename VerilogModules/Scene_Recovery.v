module SRSC (
    input wire                 clk,
    input wire                 rst,
    input wire [7:0]           A_R, A_G, A_B,
    input wire [7:0]           Reg_R4, Reg_G4, Reg_B4,
    input wire [11:0]          transmission,
    
    output wire [7:0]          J_R, J_G, J_B
);

    // Internal signals and registers for stage 7 (subtractors)
    // the shared pipeline registers act as timing buffers that hold both pieces of data together,
    // ensuring that the subsequent processing uses coherent and correctly aligned inputs.
    wire [7:0] subtract_r_out, subtract_g_out, subtract_b_out;
    
    reg [15:0] shared1_P_R, shared1_P_G, shared1_P_B;
    
    // Stage 7: Subtractor
    subtractor_8_bit s_red(
        .a(A_R), .b(Reg_R4), .sub(subtract_r_out)
    );
        
    subtractor_8_bit s_green(
        .a(A_G), .b(Reg_G4), .sub(subtract_g_out)
    );
        
    subtractor_8_bit s_blue(
        .a(A_B), .b(Reg_B4), .sub(subtract_b_out)
    );
        
    always @(posedge clk or posedge rst) begin
            if (rst) begin
                shared1_P_R <= 16'b0;
                shared1_P_G <= 16'b0;
                shared1_P_B <= 16'b0;
            end else begin
                shared1_P_R <= {A_R, subtract_r_out};
                shared1_P_G <= {A_G, subtract_g_out};
                shared1_P_B <= {A_B, subtract_b_out};
            end
        end
    
    // Internal signals and registers for stage 8
    wire [15:0] shift_r_out, shift_g_out, shift_b_out;
    
    reg [23:0] shared2_P_R, shared2_P_G, shared2_P_B;
    
    left_shifter shift_red(
        .in(shared1_P_R[15:8]), .out(shift_r_out)
    );
        
    left_shifter shift_green(
        .in(shared1_P_G[15:8]), .out(shift_g_out)
    );
        
    left_shifter shift_blue(
        .in(shared1_P_B[15:8]), .out(shift_b_out)
    );
    
    
    //LUT to perform 1/t
    wire [15:0] lut_out;
    
    reciprocal_lut_12 LUT(
        .t(transmission), .inv_t(lut_out)
    );
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shared2_P_R <= 24'b0;
            shared2_P_G <= 24'b0;
            shared2_P_B <= 24'b0;
        end else begin
            shared2_P_R <= {shared1_P_R[15:8], shift_r_out};
            shared2_P_G <= {shared1_P_G[15:8], shift_g_out};
            shared2_P_B <= {shared1_P_B[15:8], shift_b_out};
        end
    end
    
    //multipliers and shared pipeline registers 3rd set
    wire [31:0] mul_red_out,mul_green_out,mul_blue_out;
    reg [31:0] mul_red,mul_green,mul_blue;
    
    reg [23:0] shared3_P_R, shared3_P_G, shared3_P_B;
    
    multiplier_srsc MUL_red(.a(subtract_r_out), .b(lut_out), .product(mul_red_out));
    multiplier_srsc MUL_green(.a(subtract_g_out), .b(lut_out), .product(mul_green_out));
    multiplier_srsc MUL_blue(.a(subtract_b_out), .b(lut_out), .product(mul_blue_out));
    
    always @(posedge clk or posedge rst) begin
                if (rst) begin
                    mul_red <= 32'b0;
                    mul_green <= 32'b0;
                    mul_blue <= 32'b0;
                    
                    shared3_P_R <= 24'b0;
                    shared3_P_G <= 24'b0;
                    shared3_P_B <= 24'b0;
                end else begin
                    mul_red <= mul_red_out;
                    mul_green <= mul_green_out;
                    mul_blue <= mul_blue_out;
                    
                    shared3_P_R <= shared2_P_R;
                    shared3_P_G <= shared2_P_G;
                    shared3_P_B <= shared2_P_B;
                end
            end
           
    //adders        
    wire [31:0] sum_red, sum_green, sum_blue;
    
    ADD add_red(.a(shared3_P_R[15:0]), .b(mul_red), .sum(sum_red));
    ADD add_green(.a(shared3_P_G[15:0]), .b(mul_green), .sum(sum_green));
    ADD add_blue(.a(shared3_P_B[15:0]), .b(mul_blue), .sum(sum_blue));
   
    //LUT blocks to perform Ac^Beta
    wire [15:0]lut_10_red_out, lut_10_green_out, lut_10_blue_out;
    
    exponent_lut_beta_0p3 lut_stage_10_red(
        .in(shared3_P_R[23:16]), .out(lut_10_red_out)
    );
    
    exponent_lut_beta_0p3 lut_stage_10_green(
        .in(shared3_P_G[23:16]), .out(lut_10_green_out)
    );
        
    exponent_lut_beta_0p3 lut_stage_10_blue(
        .in(shared3_P_B[23:16]), .out(lut_10_blue_out)
    );
    
    //right shifters
    wire [23:0]right_shifter_red_out, right_shifter_green_out, right_shifter_blue_out;
    
    right_shifter_8 RS_red(
        .in(sum_red), .out(right_shifter_red_out)
    );
    
    right_shifter_8 RS_green(
        .in(sum_green), .out(right_shifter_green_out)
    );
    
    right_shifter_8 RS_blue(
        .in(sum_blue), .out(right_shifter_blue_out)
    );

    wire [15:0]lut_final_red_out, lut_final_green_out, lut_final_blue_out;
    
    
    //last set of LUTS to perform J^(1-Beta)
    exponent_lut_beta_0p7 L1(
        .in(right_shifter_red_out), .out(lut_final_red_out)
    );
    
    exponent_lut_beta_0p7 L2(
        .in(right_shifter_green_out), .out(lut_final_green_out)
    );
    
    exponent_lut_beta_0p7 L3(
        .in(right_shifter_blue_out), .out(lut_final_blue_out)
    );
    
    //final multipliers to give output pixels J
    final_multiplier_srsc M1(
        .a(lut_10_red_out), .b(lut_final_red_out), .product(J_R)
    );
    
    final_multiplier_srsc M2(
        .a(lut_10_green_out), .b(lut_final_green_out), .product(J_G)
    );
    
    final_multiplier_srsc M3(
        .a(lut_10_blue_out), .b(lut_final_blue_out), .product(J_B)
    );
    
    
endmodule