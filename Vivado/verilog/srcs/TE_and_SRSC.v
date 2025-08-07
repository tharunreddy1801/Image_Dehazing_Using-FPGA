// Transmission Estimation, Scene Recovery and Saturation Correction Module
`define Image_Size (512 * 512)
module TE_and_SRSC (
    input        clk,
    input        rst,
    
    input        input_is_valid,
    input [23:0] input_pixel_1,
    input [23:0] input_pixel_2,
    input [23:0] input_pixel_3,
    input [23:0] input_pixel_4,
    input [23:0] input_pixel_5,
    input [23:0] input_pixel_6,
    input [23:0] input_pixel_7,
    input [23:0] input_pixel_8,
    input [23:0] input_pixel_9,
    
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
    
    // Pipeline the Center Pixel for SRSC
    reg [23:0] I_0, I_1, I_2;
    
    // Pipeline Atmospheric Light for SRSC
    reg [7:0] A_R0, A_G0, A_B0;
    reg [7:0] A_R1, A_G1, A_B1;
    reg [7:0] A_R2, A_G2, A_B2;
    
    //==========================================================================
    // STAGE 4 LOGIC
    //==========================================================================
    
    // Detect the type of edge in the windows
    wire [1:0] ed1, ed2, ed3;
    
    // Pipeline Registers
    reg [1:0]  ed1_P, ed2_P, ed3_P;
    reg [15:0] inv_ar1_P, inv_ag1_P, inv_ab1_P,
               inv_ar2_P, inv_ag2_P, inv_ab2_P,
               inv_ar3_P, inv_ag3_P, inv_ab3_P;  
    reg        stage_4_valid;
    
    //===========================================
    // Detect the type of edges
    ED_Top EdgeDetection (
        .output_pixel_1(input_pixel_1), .output_pixel_2(input_pixel_2), .output_pixel_3(input_pixel_3),
        .output_pixel_4(input_pixel_4),                                 .output_pixel_6(input_pixel_6), 
        .output_pixel_7(input_pixel_7), .output_pixel_8(input_pixel_8), .output_pixel_9(input_pixel_9),
        
        .ED1_out(ed1), .ED2_out(ed2), .ED3_out(ed3)
    );
    //===========================================
  
    // Update Stage 4 Pipeline Registers
    always @(posedge clk) begin
        if (rst) begin
            ed1_P <= 0; 
            ed2_P <= 0; 
            ed3_P <= 0;
                
            inv_ar1_P <= 0; inv_ag1_P <= 0; inv_ab1_P <= 0;
            inv_ar2_P <= 0; inv_ag2_P <= 0; inv_ab2_P <= 0;
            inv_ar3_P <= 0; inv_ag3_P <= 0; inv_ab3_P <= 0;
                    
            I_0 <= 0;
            A_R0 <= 0; A_G0 <= 0; A_B0 <= 0;
                    
            stage_4_valid <= 0;
        end
        else begin
            ed1_P <= ed1; 
            ed2_P <= ed2; 
            ed3_P <= ed3; 
                    
            inv_ar1_P <= Inv_AR; inv_ag1_P <= Inv_AG; inv_ab1_P <= Inv_AB;
            inv_ar2_P <= Inv_AR; inv_ag2_P <= Inv_AG; inv_ab2_P <= Inv_AB;
            inv_ar3_P <= Inv_AR; inv_ag3_P <= Inv_AG; inv_ab3_P <= Inv_AB;
                    
            I_0 <= input_pixel_5;
            A_R0 <= A_R; A_G0 <= A_G; A_B0 <= A_B;
                    
            stage_4_valid <= input_is_valid;
        end
    end
        
    //==========================================================================
    // STAGE 5 LOGIC
    //==========================================================================
        
    wire [1:0] window_edge = (ed1_P | ed2_P | ed3_P);
    
    // Filter Results
    wire [7:0] p0_red_out, p0_green_out, p0_blue_out;
    wire [7:0] p1_red_out, p1_green_out, p1_blue_out;
    wire [7:0] p2_red_out, p2_green_out, p2_blue_out;
            
    // Pipeline Registers for stage 5
    reg [1:0]  window_edge_P;
    reg [15:0] inv_ar1_P1, inv_ag1_P1, inv_ab1_P1,
               inv_ar2_P1, inv_ag2_P1, inv_ab2_P1,
               inv_ar3_P1, inv_ag3_P1, inv_ab3_P1;
    reg [7:0]  p0_red_P, p0_green_P, p0_blue_P,
               p1_red_P, p1_green_P, p1_blue_P,
               p2_red_P, p2_green_P, p2_blue_P;
    reg        stage_5_valid;
  
    //===========================================
    // P0 BLOCKS FOR MEAN FILTERING
    Block_P0 MeanFilter_Red (
        .in1(input_pixel_1[23:16]), .in2(input_pixel_2[23:16]), .in3(input_pixel_3[23:16]),
        .in4(input_pixel_4[23:16]), .in5(input_pixel_5[23:16]), .in6(input_pixel_6[23:16]),
        .in7(input_pixel_7[23:16]), .in8(input_pixel_8[23:16]), .in9(input_pixel_9[23:16]),
                       
        .p0_result(p0_red_out)
    );
                   
    Block_P0 MeanFilter_Green (
        .in1(input_pixel_1[15:8]), .in2(input_pixel_2[15:8]), .in3(input_pixel_3[15:8]),
        .in4(input_pixel_4[15:8]), .in5(input_pixel_5[15:8]), .in6(input_pixel_6[15:8]),
        .in7(input_pixel_7[15:8]), .in8(input_pixel_8[15:8]), .in9(input_pixel_9[15:8]),
                       
        .p0_result(p0_green_out)
    );
                   
    Block_P0 MeanFilter_Blue (
        .in1(input_pixel_1[7:0]), .in2(input_pixel_2[7:0]), .in3(input_pixel_3[7:0]),
        .in4(input_pixel_4[7:0]), .in5(input_pixel_5[7:0]), .in6(input_pixel_6[7:0]),
        .in7(input_pixel_7[7:0]), .in8(input_pixel_8[7:0]), .in9(input_pixel_9[7:0]),
                       
        .p0_result(p0_blue_out)
    );
                   
    // P1 BLOCKS FOR EDGE PRESERVING (VERTICAL AND HORIZONTAL EDGES)
    Block_P1 EdgePreservingFilter_VH_Red (
        .in1(input_pixel_1[23:16]), .in2(input_pixel_2[23:16]), .in3(input_pixel_3[23:16]),
        .in4(input_pixel_4[23:16]), .in5(input_pixel_5[23:16]), .in6(input_pixel_6[23:16]),
        .in7(input_pixel_7[23:16]), .in8(input_pixel_8[23:16]), .in9(input_pixel_9[23:16]),
                       
        .p1_result(p1_red_out)
    );
                   
    Block_P1 EdgePreservingFilter_VH_Green (
        .in1(input_pixel_1[15:8]), .in2(input_pixel_2[15:8]), .in3(input_pixel_3[15:8]),
        .in4(input_pixel_4[15:8]), .in5(input_pixel_5[15:8]), .in6(input_pixel_6[15:8]),
        .in7(input_pixel_7[15:8]), .in8(input_pixel_8[15:8]), .in9(input_pixel_9[15:8]),
                       
        .p1_result(p1_green_out)
    );
                   
    Block_P1 EdgePreservingFilter_VH_Blue (
        .in1(input_pixel_1[7:0]), .in2(input_pixel_2[7:0]), .in3(input_pixel_3[7:0]),
        .in4(input_pixel_4[7:0]), .in5(input_pixel_5[7:0]), .in6(input_pixel_6[7:0]),
        .in7(input_pixel_7[7:0]), .in8(input_pixel_8[7:0]), .in9(input_pixel_9[7:0]),
        
        .p1_result(p1_blue_out)
    );
                   
    // P2 BLOCKS FOR EDGE PRESERVING (DIAGONAL EDGES)
    Block_P2 EdgePreservingFilter_D_Red (
        .in1(input_pixel_1[23:16]), .in2(input_pixel_2[23:16]), .in3(input_pixel_3[23:16]),
        .in4(input_pixel_4[23:16]), .in5(input_pixel_5[23:16]), .in6(input_pixel_6[23:16]),
        .in7(input_pixel_7[23:16]), .in8(input_pixel_8[23:16]), .in9(input_pixel_9[23:16]),
        
        .p2_result(p2_red_out)
    );
                   
    Block_P2 EdgePreservingFilter_D_Green (
        .in1(input_pixel_1[15:8]), .in2(input_pixel_2[15:8]), .in3(input_pixel_3[15:8]),
        .in4(input_pixel_4[15:8]), .in5(input_pixel_5[15:8]), .in6(input_pixel_6[15:8]),
        .in7(input_pixel_7[15:8]), .in8(input_pixel_8[15:8]), .in9(input_pixel_9[15:8]),
        
        .p2_result(p2_green_out)
    );
                   
    Block_P2 EdgePreservingFilter_D_Blue (
        .in1(input_pixel_1[7:0]), .in2(input_pixel_2[7:0]), .in3(input_pixel_3[7:0]),
        .in4(input_pixel_4[7:0]), .in5(input_pixel_5[7:0]), .in6(input_pixel_6[7:0]),
        .in7(input_pixel_7[7:0]), .in8(input_pixel_8[7:0]), .in9(input_pixel_9[7:0]),
                       
        .p2_result(p2_blue_out)
    );
    //===========================================
  
    // Update Stage 5 Pipeline Registers 
    always @(posedge clk) begin
        if (rst) begin
            window_edge_P <= 0;
                           
            inv_ar1_P1 <= 0; inv_ag1_P1 <= 0; inv_ab1_P1 <= 0;
            inv_ar2_P1 <= 0; inv_ag2_P1 <= 0; inv_ab2_P1 <= 0;
            inv_ar3_P1 <= 0; inv_ag3_P1 <= 0; inv_ab3_P1 <= 0;
            
            p0_red_P <= 0; p0_green_P <= 0; p0_blue_P <= 0;
            p1_red_P <= 0; p1_green_P <= 0; p1_blue_P <= 0;
            p2_red_P <= 0; p2_green_P <= 0; p2_blue_P <= 0;
            
            I_1 <= 0;
            A_R1 <= 0; A_G1 <= 0; A_B1 <= 0;
            
            stage_5_valid <= 0;
        end
        else begin
            window_edge_P <= window_edge;
                   
            inv_ar1_P1 <= inv_ar1_P; inv_ag1_P1 <= inv_ag1_P; inv_ab1_P1 <= inv_ab1_P;
            inv_ar2_P1 <= inv_ar2_P; inv_ag2_P1 <= inv_ag2_P; inv_ab2_P1 <= inv_ab2_P;
            inv_ar3_P1 <= inv_ar3_P; inv_ag3_P1 <= inv_ag3_P; inv_ab3_P1 <= inv_ab3_P;
            
            p0_red_P <= p0_red_out; p0_green_P <= p0_green_out; p0_blue_P <= p0_blue_out;
            p1_red_P <= p1_red_out; p1_green_P <= p1_green_out; p1_blue_P <= p1_blue_out;
            p2_red_P <= p2_red_out; p2_green_P <= p2_green_out; p2_blue_P <= p2_blue_out;
                                
            I_1 <= I_0;
                                
            A_R1 <= A_R0; A_G1 <= A_G0; A_B1 <= A_B0;
                                
            stage_5_valid <= stage_4_valid;
        end
    end
   
    //==========================================================================
    // STAGE 6 LOGIC
    //==========================================================================

    // Select signals for minimum in each of the filter results
    wire [1:0]  cmp_p0, cmp_p1, cmp_p2;
    
    wire [15:0] min_inv_atm0, min_inv_atm1, min_inv_atm2;
    wire [7:0]  minimum_p0, minimum_p1, minimum_p2;
        
    wire [23:0] prod0, prod1, prod2;

    // Pipeline Registers for stage 6
    reg [1:0]   window_edge_P1;
    reg [23:0]  prod0_P, prod1_P, prod2_P;
    reg         stage_6_valid;

    //===========================================
    // Comparators to choose the minimum value in each filter
    Comparator_Minimum Min_P0_CMP (
        .red(p0_red_P),
        .green(p0_green_P),
        .blue(p0_blue_P),
        
        .min_val(cmp_p0)
    );
    
    Comparator_Minimum Min_P1_CMP (
        .red(p1_red_P),
        .green(p1_green_P),
        .blue(p1_blue_P),
        
        .min_val(cmp_p1)
    );
    
    Comparator_Minimum Min_P2_CMP (
        .red(p2_red_P),
        .green(p2_green_P),
        .blue(p2_blue_P),
          
        .min_val(cmp_p2)
    );
    
    // Multiplexers to choose minimum in each of P0, P1, P2
    Mux_1 P0_Mux (
        .a(p0_red_P),
        .b(p0_green_P) ,
        .c(p0_blue_P),
        
        .sel(cmp_p0),
        
        .out(minimum_p0)
    );
    
    Mux_1 P1_Mux (
        .a(p1_red_P),
        .b(p1_green_P),
        .c(p1_blue_P),
        
        .sel(cmp_p1),
        
        .out(minimum_p1)
    );
    
    Mux_1 P2_Mux (
        .a(p2_red_P),
        .b(p2_green_P),
        .c(p2_blue_P),
        
        .sel(cmp_p2),
        
        .out(minimum_p2)
    );
    
    // Multiplexers to choose minimum of atmospheric light values
    Mux_2 InvA_0_Mux (
        .a(inv_ar1_P1),
        .b(inv_ag1_P1),
        .c(inv_ab1_P1),
        
        .sel(cmp_p0),
        
        .out(min_inv_atm0)
    );
    
    Mux_2 InvA_1_Mux (
        .a(inv_ar2_P1),
        .b(inv_ag2_P1),
        .c(inv_ab2_P1),
        
        .sel(cmp_p1),
        
        .out(min_inv_atm1)
    );
    
    Mux_2 InvA_2_Mux (
        .a(inv_ar3_P1),
        .b(inv_ag3_P1),
        .c(inv_ab3_P1),
        
        .sel(cmp_p2),
        
        .out(min_inv_atm2)
    );
    
    // Multiplier modules to compute Pc * 1/Ac
    Multiplier Multiply_P0 (
        .clk(clk),
        .rst(rst),
        .Ac_Inv(min_inv_atm0),
        .Pc(minimum_p0),
        
        .product(prod0)
    );
    
    Multiplier Multiply_P1 (
        .clk(clk),
        .rst(rst),
        .Ac_Inv(min_inv_atm1),
        .Pc(minimum_p1),
        
        .product(prod1)
    );
    
    Multiplier multiply_P2 (
        .clk(clk),
        .rst(rst),
        .Ac_Inv(min_inv_atm2),
        .Pc(minimum_p2),
        
        .product(prod2)
    );
    //===========================================
    
    // Update Stage 6 Pipeline Registers
    always @(posedge clk) begin
        if (rst) begin
            window_edge_P1 <= 0;
            
            I_2 <= 0;
            A_R2 <= 0; A_G2 <= 0; A_B2 <= 0;
            
            stage_6_valid <= 0;
        end
        else begin
            window_edge_P1 <= window_edge_P;
            
            I_2 <= I_1;
            A_R2 <= A_R1; A_G2 <= A_G1; A_B2 <= A_B1;
            
            stage_6_valid <= stage_5_valid;
        end
    end
    
    //==========================================================================
    // STAGE 7
    //==========================================================================
    
    // Transmission before subtracting it from 1
    wire [15:0] pre_transmission;
    // Transmission value in Q0.16
    wire [15:0] transmission;
    
    // Compute (Ic - Ac)
    wire [7:0]  IR_minus_AR, IG_minus_AG, IB_minus_AB;
    wire        add_or_sub_R, add_or_sub_G, add_or_sub_B;
    
    // Pipeline Registers for stage 7
    reg [15:0]  transmission_P;
    reg [7:0]   A_R_P, A_G_P, A_B_P;
    reg [7:0]   IR_minus_AR_P, IG_minus_AG_P, IB_minus_AB_P;
    reg         add_or_sub_R_P, add_or_sub_G_P, add_or_sub_B_P;
    reg         stage_7_valid;
    
    // Extract RGB components from pipelined center pixel
    wire [7:0]  I_R, I_G, I_B;
    assign I_R = I_2[23:16];
    assign I_G = I_2[15:8];
    assign I_B = I_2[7:0];
            
    // Further pipeline Center Pixel for the Adder module
    reg [7:0]   I_R1, I_G1, I_B1,
                I_R2, I_G2, I_B2,
                I_R3, I_G3, I_B3;

    //===========================================
    // Stage 7 16-bit multiplexer
    Stage_7_Mux Stage_7_Mux (
        .a(prod0), .b(prod1), .c(prod2),
        
        .sel(window_edge_P1),
        
        .out(pre_transmission)
    );
            
    // Subtractor to compute 1 - pre_transmission
    Subtractor Subtractor_TE (
        .in(pre_transmission),
        .diff(transmission)
    );
    
    // SUBTRACTOR MODULES TO COMPUTE (|Ic - Ac|)
    Subtractor_SRSC Sub_Red (
        .Ic(I_R),
        .Ac(A_R2),
        
        .diff(IR_minus_AR),
        
        .add_or_sub(add_or_sub_R)
    );
                
    Subtractor_SRSC Sub_Green (
        .Ic(I_G),
        .Ac(A_G2),
        
        .diff(IG_minus_AG),
        
        .add_or_sub(add_or_sub_G)
    );
            
    Subtractor_SRSC Sub_Blue (
        .Ic(I_B),
        .Ac(A_B2),
        
        .diff(IB_minus_AB),
        
        .add_or_sub(add_or_sub_B)
    );
    //===========================================
    
    // Update Stage 7 Pipeline Registers
    always @(posedge clk) begin
        if (rst) begin
            transmission_P <= 0;
            
            A_R_P <= 0;
            A_G_P <= 0;
            A_B_P <= 0;
            
            I_R1 <= 0;
            I_G1 <= 0;
            I_B1 <= 0;
            
            IR_minus_AR_P <= 0;
            IG_minus_AG_P <= 0;
            IB_minus_AB_P <= 0;
            
            add_or_sub_R_P <= 0;
            add_or_sub_G_P <= 0;
            add_or_sub_B_P <= 0;
            
            stage_7_valid <= 0;
        end
        else begin
            transmission_P <= transmission;
            
            A_R_P <= A_R2;
            A_G_P <= A_G2;
            A_B_P <= A_B2;
            
            I_R1 <= I_R;
            I_G1 <= I_G;
            I_B1 <= I_B;
            
            IR_minus_AR_P <= IR_minus_AR;
            IG_minus_AG_P <= IG_minus_AG;
            IB_minus_AB_P <= IB_minus_AB;
            
            add_or_sub_R_P <= add_or_sub_R;
            add_or_sub_G_P <= add_or_sub_G;
            add_or_sub_B_P <= add_or_sub_B;
            
            stage_7_valid <= stage_6_valid;
        end
    end
                
    //==========================================================================
    // STAGE 8 LOGIC
    //==========================================================================
                
    wire [15:0] inverse_transmission;
    reg [15:0]  inverse_transmission_P;

    // Compute (Ic-Ac)*(1/T)
    wire [7:0]  Diff_R_times_T, Diff_G_times_T, Diff_B_times_T;

    // Pipeline Registers for stage 7
    reg [7:0]   A_R_P1, A_G_P1, A_B_P1;
    reg         add_or_sub_R_P1, add_or_sub_G_P1, add_or_sub_B_P1;
    reg         stage_8_valid;
    
    //===========================================
    // TRANSMISSION RECIPROCAL LOOKUP TABLE
    Trans_LUT Transmission_Reciprocal_LUT (
        .x(transmission_P),
                        
        .y(inverse_transmission)
    );
                
    // MULTIPLIER MODULES TO COMPUTE (Ic-Ac)*(1/t)
    Multiplier_SRSC Mult_Red (
        .Inv_Trans(inverse_transmission_P),
        .Ic_minus_Ac(IR_minus_AR_P),
        
        .result(Diff_R_times_T)
    );
                        
    Multiplier_SRSC Mult_Green (
        .Inv_Trans(inverse_transmission_P),
        .Ic_minus_Ac(IG_minus_AG_P),
        
        .result(Diff_G_times_T)
    );
                    
    Multiplier_SRSC Mult_Blue (
        .Inv_Trans(inverse_transmission_P),
        .Ic_minus_Ac(IB_minus_AB_P),
        
        .result(Diff_B_times_T)
    );
    //===========================================
    
    // Update stage 8 pipeline registers
    always @(posedge clk) begin
        if (rst) begin
            A_R_P1 <= 0;
            A_G_P1 <= 0;
            A_B_P1 <= 0;
            
            I_R2 <= 0;
            I_G2 <= 0;
            I_B2 <= 0;
            
            add_or_sub_R_P1 <= 0;
            add_or_sub_G_P1 <= 0;
            add_or_sub_B_P1 <= 0;
            
            inverse_transmission_P <= 0;
            
            stage_8_valid <= 0;
        end
        else begin
            A_R_P1 <= A_R_P;
            A_G_P1 <= A_G_P;
            A_B_P1 <= A_B_P;
            
            I_R2 <= I_R1;
            I_G2 <= I_G1;
            I_B2 <= I_B1;
            
            add_or_sub_R_P1 <= add_or_sub_R_P;
            add_or_sub_G_P1 <= add_or_sub_G_P;
            add_or_sub_B_P1 <= add_or_sub_B_P;
            
            inverse_transmission_P <= inverse_transmission;
            
            stage_8_valid <= stage_7_valid;
        end
    end
    
    //==========================================================================
    // STAGE 9 LOGIC
    //==========================================================================
    
    reg [7:0] A_R_P2, A_G_P2, A_B_P2;
    reg       add_or_sub_R_P2, add_or_sub_G_P2, add_or_sub_B_P2;
    reg [7:0] Mult_Red_P, Mult_Green_P, Mult_Blue_P;
    reg       stage_9_valid;
    
    // Compute Ac +/- (|I-A|/t)
    wire [7:0] Sum_Red, Sum_Green, Sum_Blue;

    //===========================================
    // ADDER BLOCKS TO COMPUTE Ac +/- (|I-A|/t)
    Adder_SRSC Add_Red (
        .Ac(A_R_P2),
        .Ic(I_R3),
        .Multiplier_out(Mult_Red_P),
        
        .add_or_sub(add_or_sub_R_P2),
        
        .out(Sum_Red)
    );
                        
    Adder_SRSC Add_Green (
        .Ac(A_G_P2),
        .Ic(I_G3),
        .Multiplier_out(Mult_Green_P),
        
        .add_or_sub(add_or_sub_G_P2),
        
        .out(Sum_Green)
    );
                        
    Adder_SRSC Add_Blue (
        .Ac(A_B_P2),
        .Ic(I_B3),
        .Multiplier_out(Mult_Blue_P),
        
        .add_or_sub(add_or_sub_B_P2),
        
        .out(Sum_Blue)
    );
    //===========================================
    
    // Update stage 9 pipeline registers
    always @(posedge clk) begin
        if (rst) begin
            A_R_P2 <= 0;
            A_G_P2 <= 0;
            A_B_P2 <= 0;
            
            I_R3 <= 0;
            I_G3 <= 0;
            I_B3 <= 0;
            
            add_or_sub_R_P2 <= 0;
            add_or_sub_G_P2 <= 0;
            add_or_sub_B_P2 <= 0;
            
            Mult_Red_P <= 0;
            Mult_Green_P <= 0;
            Mult_Blue_P <= 0;
            
            stage_9_valid <= 0;
        end
        else begin
            A_R_P2 <= A_R_P1;
            A_G_P2 <= A_G_P1;
            A_B_P2 <= A_B_P1;
            
            I_R3 <= I_R2;
            I_G3 <= I_G2;
            I_B3 <= I_B2;
            
            add_or_sub_R_P2 <= add_or_sub_R_P1;
            add_or_sub_G_P2 <= add_or_sub_G_P1;
            add_or_sub_B_P2 <= add_or_sub_B_P1;
            
            Mult_Red_P <= Diff_R_times_T;
            Mult_Green_P <= Diff_G_times_T;
            Mult_Blue_P <= Diff_B_times_T;
            
            stage_9_valid <= stage_8_valid;
        end
    end
    
    //==========================================================================
    // STAGE 10 LOGIC
    //==========================================================================
    reg [7:0]   J_R_P, J_G_P, J_B_P;
    reg         stage_10_valid;
    
    // Outputs of Look-Up Tables for Saturation Corection
    wire [15:0] J_R_Corrected, J_G_Corrected, J_B_Corrected;
    wire [15:0] A_R_Corrected, A_G_Corrected, A_B_Corrected;
    
    // Product of corrected Ac and Jc
    wire [7:0]  SC_R, SC_G, SC_B;
    
    //===========================================
    // LOOK-UP TABLES TO COMPUTE Ac ^ β AND J ^ (1 - β) (β = 0.2/0.3)
    LUT_03 A_R_Correction (
        .x(A_R_P2),
        .y_q8_8(A_R_Corrected)
    );
    
    LUT_03 A_G_Correction (
        .x(A_G_P2),
        .y_q8_8(A_G_Corrected)
    );
    
    LUT_03 A_B_Correction (
        .x(A_B_P2),
        .y_q8_8(A_B_Corrected)
    );
    
    LUT_07 J_R_Correction (
        .x(Sum_Red),
        .y_q8_8(J_R_Corrected)
    );
    
    LUT_07 J_G_Correction (
        .x(Sum_Green),
        .y_q8_8(J_G_Corrected)
    );
    
    LUT_07 J_B_Correction (
        .x(Sum_Blue),
        .y_q8_8(J_B_Corrected)
    );
                    
    // MULTIPLIER MODULES TO COMPUTE Ac^β × Jc^(1-β)
    Saturation_Correction_Multiplier Saturation_Correction_Red (
        .x1(A_R_Corrected), .x2(J_R_Corrected),
        .result(SC_R)
    );
    
    Saturation_Correction_Multiplier Saturation_Correction_Green (
        .x1(A_G_Corrected), .x2(J_G_Corrected),
        .result(SC_G)
    );
    
    Saturation_Correction_Multiplier Saturation_Correction_Blue (
        .x1(A_B_Corrected), .x2(J_B_Corrected),
        .result(SC_B)
    );
    //===========================================
    
    // Update stage 10 pipeline registers
    always @(posedge clk) begin
        if (rst) begin
            J_R_P <= 0;
            J_G_P <= 0;
            J_B_P <= 0;
            
            stage_10_valid <= 0;
        end
        else begin
            J_R_P <= SC_R;
            J_G_P <= SC_G;
            J_B_P <= SC_B;
            
            stage_10_valid <= stage_9_valid;
        end
    end
    
    // Output assignments
    assign J_R = J_R_P;
    assign J_G = J_G_P;
    assign J_B = J_B_P;
    
    assign output_valid = stage_10_valid;

endmodule
