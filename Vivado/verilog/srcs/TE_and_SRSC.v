// Transmission Estimation, Scene Recovery and Saturation Correction Module
`define Image_Size (512 * 512)
module TE_and_SRSC(
    input        clk,
    input        rst,
    
    input        input_is_valid,
    input [23:0] in1,
    input [23:0] in2,
    input [23:0] in3,
    input [23:0] in4,
    input [23:0] in5,
    input [23:0] in6,
    input [23:0] in7,
    input [23:0] in8,
    input [23:0] in9,
    
    input [7:0]  A_R, A_G, A_B,
    input [15:0] Inv_AR, Inv_AG, Inv_AB,

    output [7:0] J_R, J_G, J_B,
    output       output_valid,
    
    output       done
);

    reg [17:0] pixel_counter;
    reg        done_reg;
    
    // Keep track of the number of pixels processed through the module
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_counter <= 0;
            done_reg <= 0;
        end
        else if (input_is_valid && !done_reg) begin
            pixel_counter <= pixel_counter + 1;
            if (pixel_counter == (`Image_Size - 1)) begin
                done_reg <= 1; // All pixels have been processed through the TE_SRSC module
            end
        end
    end
    
    assign done = done_reg;
    
    //==========================================================================
    // INTERNAL REGISTERS AND WIRES
    //==========================================================================
    
    reg [15:0] transmission;
    
    // Edge detection internal wires
    wire [1:0] ed1, ed2, ed3;
    
    // Edge Filtering internal wires
    wire [7:0] p0_red_out, p0_green_out, p0_blue_out;
    wire [7:0] p1_red_out, p1_green_out, p1_blue_out;
    wire [7:0] p2_red_out, p2_green_out, p2_blue_out;
    
    // Inverse atmospheric light multiplexer(min) outputs
    wire [15:0] min_atm0, min_atm1, min_atm2;
    
    // Edge Filtering Multiplexer outputs
    wire [7:0] minimum_p0, minimum_p1, minimum_p2;
    
    // Multiplier outputs
    wire [15:0] prod0, prod1, prod2;
    
    // Transmission before subtracting it from 1
    wire [15:0] pre_transmission;
    
    //==========================================================================
    // WIRES AND PIPELINE REGISTERS - STAGE 4
    //==========================================================================
    
    reg [1:0]   ed1_reg, ed2_reg, ed3_reg;
    reg [15:0]  inv_ar1, inv_ag1, inv_ab1,
                inv_ar2, inv_ag2, inv_ab2,
                inv_ar3, inv_ag3, inv_ab3;  
    reg         stage_4_valid;
    
    //==========================================================================
    // WIRES AND PIPELINE REGISTERS - STAGE 5
    //==========================================================================
    
    wire [1:0]  final_edge = (ed1_reg | ed2_reg | ed3_reg);
    
    // Pipeline Registers for stage 5
    reg [1:0]   final_edge_reg_1;
    reg [15:0]  inv_ar1_1, inv_ag1_1, inv_ab1_1,
                inv_ar2_2, inv_ag2_2, inv_ab2_2,
                inv_ar3_3, inv_ag3_3, inv_ab3_3; 
    reg         stage_5_valid;
    
    //==========================================================================
    // WIRES AND PIPELINE REGISTERS - STAGE 6
    //==========================================================================
    
    reg [1:0]   final_edge_reg_2;
    reg [15:0]  inv_mux0_reg, inv_mux1_reg, inv_mux2_reg;
    reg [7:0]   P0_reg, P1_reg, P2_reg;
    reg         stage_6_valid;
    
    //==========================================================================
    // WIRES AND PIPELINE REGISTERS - STAGE 7
    //==========================================================================
    
    wire [15:0] subtract_out;
    
    // Compute (Ic - Ac)
    wire [7:0]  IR_minus_AR, IG_minus_AG, IB_minus_AB;
    wire        add_or_sub_R, add_or_sub_G, add_or_sub_B;
        
    // Inverted transmission value
    wire [15:0] inverse_transmission;
    
    // Pipeline the Center Pixel for SRSC
    reg [23:0]  I_0, I_1, I_2;
    
    // Pipeline Atmospheric Light for SRSC
    reg [7:0]   A_R0, A_G0, A_B0;
    reg [7:0]   A_R1, A_G1, A_B1;
    reg [7:0]   A_R2, A_G2, A_B2;
    
    // Pipeline Registers for stage 7
    reg [7:0]   A_R_reg, A_G_reg, A_B_reg;
    reg [7:0]   IR_minus_AR_reg, IG_minus_AG_reg, IB_minus_AB_reg;
    reg         add_or_sub_R_reg, add_or_sub_G_reg, add_or_sub_B_reg;
    reg [15:0]  inverse_transmission_reg;
    reg         stage_7_valid;
    
    //==========================================================================
    // WIRES AND PIPELINE REGISTERS - STAGE 8
    //==========================================================================
    
    reg [7:0]   A_R_reg1, A_G_reg1, A_B_reg1;
    reg         add_or_sub_R_reg1, add_or_sub_G_reg1, add_or_sub_B_reg1;
    reg         stage_8_valid;

    // Compute (Ic-Ac)*(1/T)
    wire [7:0]  Diff_R_times_T, Diff_G_times_T, Diff_B_times_T;
    
    //==========================================================================
    // WIRES AND PIPELINE REGISTERS - STAGE 9
    //==========================================================================
    
    reg [7:0]   A_R_reg2, A_G_reg2, A_B_reg2;
    reg         add_or_sub_R_reg2, add_or_sub_G_reg2, add_or_sub_B_reg2;
    reg [7:0]   Mult_Red_Reg, Mult_Green_Reg, Mult_Blue_Reg;
    reg         stage_9_valid;
    
    // Compute Ac +/- (|I-A|/t)
    wire [7:0]  Sum_Red, Sum_Green, Sum_Blue;
    
    //==========================================================================
    // WIRES AND PIPELINE REGISTERS - STAGE 10
    //==========================================================================
    
    reg [7:0]   J_R_reg, J_G_reg, J_B_reg;
    reg         stage_10_valid;

    // Outputs of Look-Up Tables for Saturation Corection
    wire [15:0] J_R_Corrected, J_G_Corrected, J_B_Corrected;
    wire [15:0] A_R_Corrected, A_G_Corrected, A_B_Corrected;

    // Product of corrected Ac and Jc
    wire [7:0]  SC_R, SC_G, SC_B;
    
    //==========================================================================
    // UPDATING PIPELINE REGISTERS
    //==========================================================================

    // Update Stage 4 Pipeline Registers
    always @(posedge clk) begin
        if (rst) begin
            ed1_reg <= 0; 
            ed2_reg <= 0; 
            ed3_reg <= 0;
        
            inv_ar1 <= 0; inv_ag1 <= 0; inv_ab1 <= 0;
            inv_ar2 <= 0; inv_ag2 <= 0; inv_ab2 <= 0;
            inv_ar3 <= 0; inv_ag3 <= 0; inv_ab3 <= 0;
            
            I_0 <= 0;
            
            A_R0 <= 0; A_G0 <= 0; A_B0 <= 0;
            
            stage_4_valid <= 0;
        end
        else begin
            ed1_reg <= ed1; 
            ed2_reg <= ed2; 
            ed3_reg <= ed3; 
            
            inv_ar1 <= Inv_AR; inv_ag1 <= Inv_AG; inv_ab1 <= Inv_AB;
            inv_ar2 <= Inv_AR; inv_ag2 <= Inv_AG; inv_ab2 <= Inv_AB;
            inv_ar3 <= Inv_AR; inv_ag3 <= Inv_AG; inv_ab3 <= Inv_AB;
            
            I_0 <= in5;
            
            A_R0 <= A_R; A_G0 <= A_G; A_B0 <= A_B;
            
            stage_4_valid <= input_is_valid;
        end
    end
    
    // Update Stage 5 Pipeline Registers
    always @(posedge clk) begin
        if (rst) begin
            final_edge_reg_1 <= 0;
        
            inv_ar1_1 <= 0; inv_ag1_1 <= 0; inv_ab1_1 <= 0;
            inv_ar2_2 <= 0; inv_ag2_2 <= 0; inv_ab2_2 <= 0;
            inv_ar3_3 <= 0; inv_ag3_3 <= 0; inv_ab3_3 <= 0;
            
            I_1 <= 0;
            
            A_R1 <= 0; A_G1 <= 0; A_B1 <= 0;
            
            stage_5_valid <= 0;
        end
        else begin
            final_edge_reg_1 <= final_edge;

            inv_ar1_1 <= inv_ar1; inv_ag1_1 <= inv_ag1; inv_ab1_1 <= inv_ab1;
            inv_ar2_2 <= inv_ar2; inv_ag2_2 <= inv_ag2; inv_ab2_2 <= inv_ab2;
            inv_ar3_3 <= inv_ar3; inv_ag3_3 <= inv_ag3; inv_ab3_3 <= inv_ab3;
             
            I_1 <= I_0;
             
            A_R1 <= A_R0; A_G1 <= A_G0; A_B1 <= A_B0;
             
            stage_5_valid <= stage_4_valid;
        end
    end
    
    // Update Stage 6 Pipeline Registers
    always @(posedge clk) begin
        if (rst) begin
            final_edge_reg_2 <= 0;
            
            inv_mux0_reg <= 0; inv_mux1_reg <= 0; inv_mux2_reg <= 0;
            
            P0_reg <= 0; P1_reg <= 0; P2_reg <= 0;
            
            I_2 <= 0;
            
            A_R2 <= 0; A_G2 <= 0; A_B2 <= 0;
            
            stage_6_valid <= 0;
        end
        else begin
            final_edge_reg_2 <= final_edge_reg_1;
            
            inv_mux0_reg <= min_atm0; inv_mux1_reg <= min_atm1; inv_mux2_reg <= min_atm2;
            
            P0_reg <= minimum_p0; P1_reg <= minimum_p1; P2_reg <= minimum_p2;
                
            I_2 <= I_1;
                
            A_R2 <= A_R1; A_G2 <= A_G1; A_B2 <= A_B1;
                
            stage_6_valid <= stage_5_valid;
        end
    end
    
    // Extract RGB components from pipelined center pixel
    wire [7:0] I_R, I_G, I_B;
    assign I_R = I_2[23:16];
    assign I_G = I_2[15:8];
    assign I_B = I_2[7:0];

    // Further pipeline Center Pixel for the Adder module
    reg [7:0] I_R1, I_G1, I_B1, I_R2, I_G2, I_B2, I_R3, I_G3, I_B3;
    
    // Update Stage 7 Pipeline Registers
    always @(posedge clk) begin
        if (rst) begin
            transmission <= 0;
                
            A_R_reg <= 0;
            A_G_reg <= 0;
            A_B_reg <= 0;
            
            I_R1 <= 0;
            I_G1 <= 0;
            I_B1 <= 0;
            
            add_or_sub_R_reg <= 0;
            add_or_sub_G_reg <= 0;
            add_or_sub_B_reg <= 0;
            
            IR_minus_AR_reg <= 0;
            IG_minus_AG_reg <= 0;
            IB_minus_AB_reg <= 0;
            
            
            stage_7_valid <= 0;
        end
        else begin
            transmission <= subtract_out;
                
            A_R_reg <= A_R2;
            A_G_reg <= A_G2;
            A_B_reg <= A_B2;
            
            I_R1 <= I_R;
            I_G1 <= I_G;
            I_B1 <= I_B;
            
            add_or_sub_R_reg <= add_or_sub_R;
            add_or_sub_G_reg <= add_or_sub_G;
            add_or_sub_B_reg <= add_or_sub_B;
            
            IR_minus_AR_reg <= IR_minus_AR;
            IG_minus_AG_reg <= IG_minus_AG;
            IB_minus_AB_reg <= IB_minus_AB;
            

                
            stage_7_valid <= stage_6_valid;
        end
    end
    
    // Update stage 8 pipeline registers
    always @(posedge clk) begin
        if (rst) begin
            A_R_reg1 <= 0;
            A_G_reg1 <= 0;
            A_B_reg1 <= 0;
            
            I_R2 <= 0;
            I_G2 <= 0;
            I_B2 <= 0;

            add_or_sub_R_reg1 <= 0;
            add_or_sub_G_reg1 <= 0;
            add_or_sub_B_reg1 <= 0;
            
            inverse_transmission_reg <= 0;
            
            stage_8_valid <= 0;
        end
        else begin
            A_R_reg1 <= A_R_reg;
            A_G_reg1 <= A_G_reg;
            A_B_reg1 <= A_B_reg;
            
            I_R2 <= I_R1;
            I_G2 <= I_G1;
            I_B2 <= I_B1;

            add_or_sub_R_reg1 <= add_or_sub_R_reg;
            add_or_sub_G_reg1 <= add_or_sub_G_reg;
            add_or_sub_B_reg1 <= add_or_sub_B_reg;
            
            inverse_transmission_reg <= inverse_transmission;

            stage_8_valid <= stage_7_valid;
        end
    end
    
    // Update stage 9 pipeline registers
    always @(posedge clk) begin
        if (rst) begin
            A_R_reg2 <= 0;
            A_G_reg2 <= 0;
            A_B_reg2 <= 0;
            
            I_R3 <= 0;
            I_G3 <= 0;
            I_B3 <= 0;
            
            add_or_sub_R_reg2 <= 0;
            add_or_sub_G_reg2 <= 0;
            add_or_sub_B_reg2 <= 0;
            
            Mult_Red_Reg <= 0;
            Mult_Green_Reg <= 0;
            Mult_Blue_Reg <= 0;
            
            stage_9_valid <= 0;
        end
        else begin
            A_R_reg2 <= A_R_reg1;
            A_G_reg2 <= A_G_reg1;
            A_B_reg2 <= A_B_reg1;
            
            I_R3 <= I_R2;
            I_G3 <= I_G2;
            I_B3 <= I_B2;
            
            add_or_sub_R_reg2 <= add_or_sub_R_reg1;
            add_or_sub_G_reg2 <= add_or_sub_G_reg1;
            add_or_sub_B_reg2 <= add_or_sub_B_reg1;
            
            Mult_Red_Reg <= Diff_R_times_T;
            Mult_Green_Reg <= Diff_G_times_T;
            Mult_Blue_Reg <= Diff_B_times_T;

            stage_9_valid <= stage_8_valid;
        end
    end
    
    // Update stage 10 pipeline registers
    always @(posedge clk) begin
        if (rst) begin
            J_R_reg <= 0;
            J_G_reg <= 0;
            J_B_reg <= 0;
            
            stage_10_valid <= 0;
        end
        else begin
            J_R_reg <= SC_R;
            J_G_reg <= SC_G;
            J_B_reg <= SC_B;
            
            stage_10_valid <= stage_9_valid;
        end
    end
    
    // Output assignments
    assign J_R = J_R_reg;
    assign J_G = J_G_reg;
    assign J_B = J_B_reg;
    
    assign output_valid = stage_10_valid;
    
    //==========================================================================
    // BLOCK INSTANTIATIONS
    //==========================================================================

    // Detect the type of edges
    ED_Top Edge_detection(
        .output_pixel_1(in1), .output_pixel_2(in2), .output_pixel_3(in3),
        .output_pixel_4(in4),                       .output_pixel_6(in6), 
        .output_pixel_7(in7), .output_pixel_8(in8), .output_pixel_9(in9),
        
        .ED1_out(ed1), .ED2_out(ed2), .ED3_out(ed3)
    );
    
    //==========================================================================
    // P0 BLOCKS FOR MEAN FILTERING
    //==========================================================================
    
    Block_P0 P0_Red(
        .in1(in1[23:16]), .in2(in2[23:16]), .in3(in3[23:16]),
        .in4(in4[23:16]), .in5(in5[23:16]), .in6(in6[23:16]),
        .in7(in7[23:16]), .in8(in8[23:16]), .in9(in9[23:16]),
        
        .p0_result(p0_red_out)
    );
    
    Block_P0 P0_Green(
        .in1(in1[15:8]), .in2(in2[15:8]), .in3(in3[15:8]),
        .in4(in4[15:8]), .in5(in5[15:8]), .in6(in6[15:8]),
        .in7(in7[15:8]), .in8(in8[15:8]), .in9(in9[15:8]),
        
        .p0_result(p0_green_out)
    );
    
    Block_P0 P0_Blue(
        .in1(in1[7:0]), .in2(in2[7:0]), .in3(in3[7:0]),
        .in4(in4[7:0]), .in5(in5[7:0]), .in6(in6[7:0]),
        .in7(in7[7:0]), .in8(in8[7:0]), .in9(in9[7:0]),
        
        .p0_result(p0_blue_out)
    );
    
    //==========================================================================
    // P1 BLOCKS FOR EDGE PRESERVING
    //==========================================================================
    
    Block_P1 P1_Red(
        .in1(in1[23:16]), .in2(in2[23:16]), .in3(in3[23:16]),
        .in4(in4[23:16]), .in5(in5[23:16]), .in6(in6[23:16]),
        .in7(in7[23:16]), .in8(in8[23:16]), .in9(in9[23:16]),
        
        .p1_result(p1_red_out)
    );
    
    Block_P1 P1_Green(
        .in1(in1[15:8]), .in2(in2[15:8]), .in3(in3[15:8]),
        .in4(in4[15:8]), .in5(in5[15:8]), .in6(in6[15:8]),
        .in7(in7[15:8]), .in8(in8[15:8]), .in9(in9[15:8]),
        
        .p1_result(p1_green_out)
    );
    
    Block_P1 P1_Blue(
        .in1(in1[7:0]), .in2(in2[7:0]), .in3(in3[7:0]),
        .in4(in4[7:0]), .in5(in5[7:0]), .in6(in6[7:0]),
        .in7(in7[7:0]), .in8(in8[7:0]), .in9(in9[7:0]),
        
        .p1_result(p1_blue_out)
    );
    
    //==========================================================================
    // P2 BLOCKS FOR EDGE PRESERVING
    //==========================================================================
    
    Block_P2 P2_Red(
        .in1(in1[23:16]), .in2(in2[23:16]), .in3(in3[23:16]),
        .in4(in4[23:16]), .in5(in5[23:16]), .in6(in6[23:16]),
        .in7(in7[23:16]), .in8(in8[23:16]), .in9(in9[23:16]),
        
        .p2_result(p2_red_out)
    );
    
    Block_P2 P2_Green(
        .in1(in1[15:8]), .in2(in2[15:8]), .in3(in3[15:8]),
        .in4(in4[15:8]), .in5(in5[15:8]), .in6(in6[15:8]),
        .in7(in7[15:8]), .in8(in8[15:8]), .in9(in9[15:8]),
        
        .p2_result(p2_green_out)
    );
    
    Block_P2 P2_Blue(
        .in1(in1[7:0]), .in2(in2[7:0]), .in3(in3[7:0]),
        .in4(in4[7:0]), .in5(in5[7:0]), .in6(in6[7:0]),
        .in7(in7[7:0]), .in8(in8[7:0]), .in9(in9[7:0]),
        
        .p2_result(p2_blue_out)
    );
    
    //==========================================================================
    // COMPARATOR BLOCKS TO FIND MINIMUM AMONG R,G,B
    //==========================================================================
    
    // Compare p0, p1, p2
    wire [1:0] cmp_out_0, cmp_out_1, cmp_out_2;
    
    Comparator_Minimum compare_P0(
        .red(p0_red_out),
        .green(p0_green_out),
        .blue(p0_blue_out),
        
        .min_val(cmp_out_0)
    );
        
    Comparator_Minimum compare_P1(
        .red(p1_red_out),
        .green(p1_green_out),
        .blue(p1_blue_out),
        
        .min_val(cmp_out_1)
    );
        
    Comparator_Minimum compare_P2(
        .red(p2_red_out),
        .green(p2_green_out),
        .blue(p2_blue_out),
        
        .min_val(cmp_out_2)
    );
    
    //==========================================================================
    // MULTIPLEXER INSTANTIATIONS
    //==========================================================================
    
    // P0, P1, P2 blocks
    Mux_1 P0_Mux(
        .a(p0_red_out),
        .b(p0_green_out),
        .c(p0_blue_out),
        
        .sel(cmp_out_0),
        
        .out(minimum_p0)
    );
    
    Mux_1 P1_Mux(
        .a(p1_red_out),
        .b(p1_green_out),
        .c(p1_blue_out),
        
        .sel(cmp_out_1),
        
        .out(minimum_p1)
    );
    
    Mux_1 P2_Mux(
        .a(p2_red_out),
        .b(p2_green_out),
        .c(p2_blue_out),
        
        .sel(cmp_out_2),
        
        .out(minimum_p2)
    );
    
    // Minimum atmospheric light muxes
    Mux_2 InvA_0_Mux(
        .a(inv_ar1_1),
        .b(inv_ag1_1),
        .c(inv_ab1_1),
        
        .sel(cmp_out_0),
        
        .out(min_atm0)
    );
    
    Mux_2 InvA_1_Mux(
        .a(inv_ar2_2),
        .b(inv_ag2_2),
        .c(inv_ab2_2),
        
        .sel(cmp_out_1),
        
        .out(min_atm1)
    );
    
    Mux_2 InvA_2_Mux(
        .a(inv_ar3_3),
        .b(inv_ag3_3),
        .c(inv_ab3_3),
        
        .sel(cmp_out_2),
        
        .out(min_atm2)
    );
    
    //==========================================================================
    // STAGE 7 MULTIPLIER BLOCK INSTANTIATIONS
    //==========================================================================
    
    Multiplier multiply_P0(
        .Ac_Inv(inv_mux0_reg),
        .Pc(P0_reg),
        
        .product(prod0)
    );
    
    Multiplier multiply_P1(
        .Ac_Inv(inv_mux1_reg),
        .Pc(P1_reg),
        
        .product(prod1)
    );
    
    Multiplier multiply_P2(
        .Ac_Inv(inv_mux2_reg),
        .Pc(P2_reg),
        
        .product(prod2)
    );
    
    // Stage 7 16-bit multiplexer
    Stage_7_Mux Stage_7_Mux(
        .a(prod0), .b(prod1), .c(prod2),
        
        .sel(final_edge_reg_2),
        
        .out(pre_transmission)
    );

    // Subtractor to compute 1 - pre_transmission
    Subtractor Sub(
        .in(pre_transmission),
        .diff(subtract_out)
    );
    
    //==========================================================================
    // SUBTRACTOR MODULES TO COMPUTE (|Ic - Ac|)
    //==========================================================================
    
    Subtractor_SRSC Sub_Red(
        .Ic(I_R),
        .Ac(A_R2),
    
        .diff(IR_minus_AR),
        
        .add_or_sub(add_or_sub_R)
    );
    
    Subtractor_SRSC Sub_Green(
        .Ic(I_G),
        .Ac(A_G2),
    
        .diff(IG_minus_AG),
        
        .add_or_sub(add_or_sub_G)
    );

    Subtractor_SRSC Sub_Blue(
        .Ic(I_B),
        .Ac(A_B2),
    
        .diff(IB_minus_AB),
        
        .add_or_sub(add_or_sub_B)
    );
    
    //==========================================================================
    // TRANSMISSION RECIPROCAL LOOKUP TABLE
    //==========================================================================
    
    // LUT to output the reciprocal of transmission values (Q0.16) in Q2.14 format
    Trans_LUT Transmission_Reciprocal_LUT(
        .x(transmission),
        
        .y(inverse_transmission)
    );

    //==========================================================================
    // MULTIPLIER MODULES TO COMPUTE (Ic-Ac)*(1/t)
    //==========================================================================
    
    Multiplier_SRSC Mult_Red(
        .Inv_Trans(inverse_transmission_reg),
        .Ic_minus_Ac(IR_minus_AR_reg),

        .result(Diff_R_times_T)
    );
        
    Multiplier_SRSC Mult_Green(
        .Inv_Trans(inverse_transmission_reg),
        .Ic_minus_Ac(IG_minus_AG_reg),

        .result(Diff_G_times_T)
    );
    
    Multiplier_SRSC Mult_Blue(
        .Inv_Trans(inverse_transmission_reg),
        .Ic_minus_Ac(IB_minus_AB_reg),
        
        .result(Diff_B_times_T)
    );
    
    //==========================================================================
    // ADDER BLOCKS TO COMPUTE Ac +/- (|I-A|/t)
    //==========================================================================
    
    Adder_SRSC Add_Red(
        .Ac(A_R_reg2),
        .Ic(I_R3),
        .Multiplier_out(Mult_Red_Reg),
        
        .add_or_sub(add_or_sub_R_reg2),
        
        .out(Sum_Red)
    );
        
    Adder_SRSC Add_Green(
        .Ac(A_G_reg2),
        .Ic(I_G3),
        .Multiplier_out(Mult_Green_Reg),
        
        .add_or_sub(add_or_sub_G_reg2),
        
        .out(Sum_Green)
    );
        
    Adder_SRSC Add_Blue(
        .Ac(A_B_reg2),
        .Ic(I_B3),
        .Multiplier_out(Mult_Blue_Reg),
        
        .add_or_sub(add_or_sub_B_reg2),
        
        .out(Sum_Blue)
    );
    
    //==========================================================================
    // LOOK-UP TABLES TO COMPUTE Ac ^ β AND J ^ (1 - β) (β = 0.2/0.3)
    //==========================================================================
    
    LUT_03 A_R_Correction(
        .x(A_R_reg2),
        .y_q8_8(A_R_Corrected)
    );
    
    LUT_03 A_G_Correction(
        .x(A_G_reg2),
        .y_q8_8(A_G_Corrected)
    );
    
    LUT_03 A_B_Correction(
        .x(A_B_reg2),
        .y_q8_8(A_B_Corrected)
    );
    
    LUT_07 J_R_Correction(
        .x(Sum_Red),
        .y_q8_8(J_R_Corrected)
    );
    
    LUT_07 J_G_Correction(
        .x(Sum_Green),
        .y_q8_8(J_G_Corrected)
    );
    
    LUT_07 J_B_Correction(
        .x(Sum_Blue),
        .y_q8_8(J_B_Corrected)
    );
    
    //==========================================================================
    // MULTIPLIER MODULES TO COMPUTE Ac^β × Jc^(1-β)
    //==========================================================================
    Saturation_Correction_Multiplier Saturation_Correction_Red(
        .x1(A_R_Corrected), .x2(J_R_Corrected),
        .result(SC_R)
    );
    
    Saturation_Correction_Multiplier Saturation_Correction_Green(
        .x1(A_G_Corrected), .x2(J_G_Corrected),
        .result(SC_G)
    );
    
    Saturation_Correction_Multiplier Saturation_Correction_Blue(
        .x1(A_B_Corrected), .x2(J_B_Corrected),
        .result(SC_B)
    );
    
endmodule
