module TE_and_SRSC(
     input                      clk,
     input                      rst,
    
    input wire              input_is_valid,
    input  wire [23:0]  in1,
    input  wire [23:0]  in2,
    input  wire [23:0]  in3,
    input  wire [23:0]  in4,
    input  wire [23:0]  in5,
    input  wire [23:0]  in6,
    input  wire [23:0]  in7,
    input  wire [23:0]  in8,
    input  wire [23:0]  in9,
    
    input wire [7:0]     A_R,A_G,A_B,
    input wire [15:0]   Inv_AR, Inv_AG, Inv_AB,

    output wire [7:0]   J_R,
    output wire [7:0]   J_G,
    output wire [7:0]   J_B,
    output wire           output_valid
    );
    
    reg [15:0] transmission;
    
    //Edge Filtering internal wires
    wire [7:0] p0_red_out, p0_green_out, p0_blue_out;
    wire [7:0] p1_red_out, p1_green_out, p1_blue_out;
    wire [7:0] p2_red_out, p2_green_out, p2_blue_out;
    
    //Inverse ATM multiplexer(min) outputs
    wire [15:0] min_atm0,min_atm1,min_atm2;
    
    //Edge Filtering Multiplexer outputs
    wire [7:0] minimum_p0, minimum_p1, minimum_p2;
    
    //Multiplier outputs
    wire [15:0] prod0, prod1, prod2;
    
    //Transmission before subtracting from 1
    wire [15:0] pre_transmission;
    
    //Pipeline Registers for stage 4
    reg [1:0]   ed1_reg,ed2_reg,ed3_reg;
    reg [15:0] inv_ar1, inv_ag1, inv_ab1,
                            inv_ar2, inv_ag2, inv_ab2,
                            inv_ar3, inv_ag3, inv_ab3;  
    reg            stage_4_valid;
    
    // Stage 5
    wire[1:0] final_edge=(ed1_reg | ed2_reg | ed3_reg);
    
    //Pipeline Registers for stage 5
    reg [1:0]   final_edge_reg_1;
    reg [15:0] inv_ar1_1,inv_ag1_1,inv_ab1_1,
                            inv_ar2_2,inv_ag2_2,inv_ab2_2,
                            inv_ar3_3,inv_ag3_3,inv_ab3_3; 
    reg            stage_5_valid;
    
    // Pipeline Registers for stage 6
    reg [1:0]   final_edge_reg_2;
    reg [15:0] inv_mux0_reg, inv_mux1_reg, inv_mux2_reg;
    reg [7:0]   P0_reg, P1_reg, P2_reg;
    reg            stage_6_valid;
    
    // Stage 7
    wire [15:0] subtract_out;
    
    //Compute (Ic - Ac)
    wire [7:0] IR_minus_AR, IG_minus_AG, IB_minus_AB;
    wire          add_or_sub_R, add_or_sub_G, add_or_sub_B;
        
    //Inverted transmission value
    wire [15:0] inverse_transmission;
    
    //Pipeline Registers for stage 7
    reg [7:0]   A_R_reg, A_G_reg, A_B_reg;
    reg [7:0]   IR_minus_AR_reg, IG_minus_AG_reg, IB_minus_AB_reg;
    reg            add_or_sub_R_reg, add_or_sub_G_reg, add_or_sub_B_reg;
    reg [15:0] inverse_transmission_reg;
    reg            stage_7_valid;
    
    //Pipeline Registers for stage 8
    reg [7:0] A_R_reg1, A_G_reg1, A_B_reg1;
    reg          add_or_sub_R_reg1, add_or_sub_G_reg1, add_or_sub_B_reg1;
    reg          stage_8_valid;

    //Compute (Ic-Ac)*(1/T)
    wire [15:0] Diff_R_times_T, Diff_G_times_T, Diff_B_times_T;
    
    //Pipeline Registers for stage 9
    reg [7:0]   A_R_reg2, A_G_reg2, A_B_reg2;
    reg            add_or_sub_R_reg2, add_or_sub_G_reg2, add_or_sub_B_reg2;
    reg [15:0] Mult_Red_Reg, Mult_Green_Reg, Mult_Blue_Reg;
    reg            stage_9_valid;
    
    //Compute Ac +/- (|I-A|/t)
    wire [7:0] Sum_Red, Sum_Green, Sum_Blue;
    
/////////////////////////////////////////////////////////////////////////////////////////////
//UPDATING PIPELINE REGISTERS
/////////////////////////////////////////////////////////////////////////////////////////////

    //Update Stage 4 Pipeline Registers
    always @(posedge clk)
    begin
        if(rst)
        begin
            ed1_reg <= 0; ed2_reg <= 0; ed3_reg <= 0;
        
            inv_ar1 <= 0; inv_ag1 <= 0; inv_ab1 <= 0;
            inv_ar2 <= 0; inv_ag2 <= 0; inv_ab2 <= 0;
            inv_ar3 <= 0; inv_ag3 <= 0; inv_ab3 <= 0;
            
            stage_4_valid <= 0;
        end
        else begin
            if(input_is_valid) begin
            ed1_reg <= ed1; ed2_reg <= ed2; ed3_reg <= ed3; 
            
            inv_ar1 <= Inv_AR; inv_ag1 <= Inv_AG; inv_ab1 <= Inv_AB;
            inv_ar2 <= Inv_AR; inv_ag2 <= Inv_AG; inv_ab2 <= Inv_AB;
            inv_ar3 <= Inv_AR; inv_ag3 <= Inv_AG; inv_ab3 <= Inv_AB;
            
            stage_4_valid <= input_is_valid;
            end
        end
    end
    
    //Update Stage 5 Pipeline Registers
    always @(posedge clk)
    begin
        if(rst)
        begin
            final_edge_reg_1 <= 0;
        
            inv_ar1_1 <= 0; inv_ag1_1 <= 0;inv_ab1_1 <= 0;
            inv_ar2_2 <= 0; inv_ag2_2 <= 0;inv_ab2_2 <= 0;
            inv_ar3_3 <= 0; inv_ag3_3 <= 0;inv_ab3_3 <= 0;
            
            stage_5_valid <= 0;
        end
        else begin

             final_edge_reg_1<= final_edge;
             
             stage_5_valid <= stage_4_valid;

             inv_ar1_1 <= inv_ar1; inv_ag1_1 <= inv_ag1; inv_ab1_1 <= inv_ab1;
             inv_ar2_2 <= inv_ar2; inv_ag2_2 <= inv_ag2; inv_ab2_2 <= inv_ab2;
             inv_ar3_3 <= inv_ar3; inv_ag3_3 <= inv_ag3; inv_ab3_3 <= inv_ab3;

        end
    end
    
    //Update Stage 6 Pipeline Registers
    always @(posedge clk)
    begin
        if(rst)
        begin
            final_edge_reg_2 <= 0;
            
            inv_mux0_reg <= 0; inv_mux1_reg <= 0; inv_mux2_reg <= 0;
            
            P0_reg <= 0; P1_reg <= 0; P2_reg <= 0;
            
            stage_6_valid <= 0;
        end
        else begin

                final_edge_reg_2 <= final_edge_reg_1;
            
                inv_mux0_reg <= min_atm0; inv_mux1_reg <= min_atm1; inv_mux2_reg <= min_atm2;
            
                P0_reg <= minimum_p0; P1_reg <= minimum_p1; P2_reg <= minimum_p2;
            
                stage_6_valid <= stage_5_valid;

        end
    end
    
    //Update Stage 7 Pipeline Registers
    always @(posedge clk)
    begin
        if(rst) begin
                transmission <= 0;
                
                A_R_reg <= 0;
                A_G_reg <= 0;
                A_B_reg <= 0;
            
                add_or_sub_R_reg <= 0;
                add_or_sub_G_reg <= 0;
                add_or_sub_B_reg <= 0;
            
                IR_minus_AR_reg <= 0;
                IG_minus_AG_reg <= 0;
                IB_minus_AB_reg <= 0;
            
                inverse_transmission_reg <= 0;
            
                stage_7_valid <= 0;
            end
        else
                transmission <= (subtract_out * 255 + 32767) >> 16;
                
                A_R_reg <= A_R;
                A_G_reg <= A_G;
                A_B_reg <= A_B;
            
                add_or_sub_R_reg <= add_or_sub_R;
                add_or_sub_G_reg <= add_or_sub_G;
                add_or_sub_B_reg <= add_or_sub_B;
            
                IR_minus_AR_reg <= IR_minus_AR;
                IG_minus_AG_reg <= IG_minus_AG;
                IB_minus_AB_reg <= IB_minus_AB;
            
                inverse_transmission_reg <= inverse_transmission;
                
                stage_7_valid <= stage_6_valid;
    end
    
    
    //Update stage 8 pipeline registers
    always @(posedge clk)
    begin
    if(rst)
        begin
            A_R_reg1 <= 0;
            A_G_reg1 <= 0;
            A_B_reg1 <= 0;
            
            add_or_sub_R_reg1 <= 0;
            add_or_sub_G_reg1 <= 0;
            add_or_sub_B_reg1 <= 0;
            
            stage_8_valid <= 0;
        end
        else
        begin
            A_R_reg1 <= A_R_reg;
            A_G_reg1 <= A_G_reg;
            A_B_reg1 <= A_B_reg;
            
            add_or_sub_R_reg1 <= add_or_sub_R_reg;
            add_or_sub_G_reg1 <= add_or_sub_G_reg;
            add_or_sub_B_reg1 <= add_or_sub_B_reg;

            stage_8_valid <= stage_7_valid;
        end
    end
    
    
    //Update stage 9 pipeline registers
    always @(posedge clk)
    begin
    if(rst)
        begin
            A_R_reg2 <= 0;
            A_G_reg2 <= 0;
            A_B_reg2 <= 0;
            
            add_or_sub_R_reg2 <= 0;
            add_or_sub_G_reg2 <= 0;
            add_or_sub_B_reg2 <= 0;
            
            Mult_Red_Reg <= 0;
            Mult_Green_Reg <= 0;
            Mult_Blue_Reg <= 0;
            
            stage_9_valid <= 0;
        end
        else
        begin
            A_R_reg2 <= A_R_reg1;
            A_G_reg2 <= A_G_reg1;
            A_B_reg2 <= A_B_reg1;
            
            add_or_sub_R_reg2 <= add_or_sub_R_reg1;
            add_or_sub_G_reg2 <= add_or_sub_G_reg1;
            add_or_sub_B_reg2 <= add_or_sub_B_reg1;
            
            Mult_Red_Reg <= Diff_R_times_T;
            Mult_Green_Reg <= Diff_G_times_T;
            Mult_Blue_Reg <= Diff_B_times_T;

            stage_9_valid <= stage_8_valid;
        end
    end
    
    assign output_valid = stage_9_valid;
    
    
/////////////////////////////////////////////////////////////////////////////////////////////
//BLOCK INSTANTIATIONS
/////////////////////////////////////////////////////////////////////////////////////////////

    //Detect the type of edges
    ED_Top Edge_detection(
        .output_pixel_1(in1), .output_pixel_2(in2), .output_pixel_3(in3),
        .output_pixel_4(in4), .output_pixel_5(in5), .output_pixel_6(in6), 
        .output_pixel_7(in7), .output_pixel_8(in8), .output_pixel_9(in9),
        
        .ED1_out(ed1), .ED2_out(ed2), .ED3_out(ed3)
    );
    
    //P0 blocks for mean filtering
    block_P0 P0_Red(
        .in1(in1[23:16]), .in2(in2[23:16]), .in3(in3[23:16]),
        .in4(in4[23:16]), .in5(in5[23:16]), .in6(in6[23:16]),
        .in7(in7[23:16]), .in8(in8[23:16]), .in9(in9[23:16]),
        
        .p0_result(p0_red_out)
    );
    
    block_P0 P0_Green(
        .in1(in1[15:8]), .in2(in2[15:8]), .in3(in3[15:8]),
        .in4(in4[15:8]), .in5(in5[15:8]), .in6(in6[15:8]),
        .in7(in7[15:8]), .in8(in8[15:8]), .in9(in9[15:8]),
        
        .p0_result(p0_green_out)
    );
    
    block_P0 P0_Blue(
        .in1(in1[7:0]), .in2(in2[7:0]), .in3(in3[7:0]),
        .in4(in4[7:0]), .in5(in5[7:0]), .in6(in6[7:0]),
        .in7(in7[7:0]), .in8(in8[7:0]), .in9(in9[7:0]),
        
        .p0_result(p0_blue_out)
    );
    
    //P1 blocks for edge preserving
    block_P1 P1_Red(
        .in1(in1[23:16]), .in2(in2[23:16]), .in3(in3[23:16]),
        .in4(in4[23:16]), .in5(in5[23:16]), .in6(in6[23:16]),
        .in7(in7[23:16]), .in8(in8[23:16]), .in9(in9[23:16]),
        
        .p1_result(p1_red_out)
    );
    
    block_P1 P1_Green(
        .in1(in1[15:8]), .in2(in2[15:8]), .in3(in3[15:8]),
        .in4(in4[15:8]), .in5(in5[15:8]), .in6(in6[15:8]),
        .in7(in7[15:8]), .in8(in8[15:8]), .in9(in9[15:8]),
        
        .p1_result(p1_green_out)
    );
    
    block_P1 P1_Blue(
        .in1(in1[7:0]), .in2(in2[7:0]), .in3(in3[7:0]),
        .in4(in4[7:0]), .in5(in5[7:0]), .in6(in6[7:0]),
        .in7(in7[7:0]), .in8(in8[7:0]), .in9(in9[7:0]),
        
        .p1_result(p1_blue_out)
    );
    
    //P2 blocks for edge preserving
    block_P2 P2_Red(
        .in1(in1[23:16]), .in2(in2[23:16]), .in3(in3[23:16]),
        .in4(in4[23:16]), .in5(in5[23:16]), .in6(in6[23:16]),
        .in7(in7[23:16]), .in8(in8[23:16]), .in9(in9[23:16]),
        
        .p2_result(p2_red_out)
    );
    
    block_P2 P2_Green(
        .in1(in1[15:8]), .in2(in2[15:8]), .in3(in3[15:8]),
        .in4(in4[15:8]), .in5(in5[15:8]), .in6(in6[15:8]),
        .in7(in7[15:8]), .in8(in8[15:8]), .in9(in9[15:8]),
        
        .p2_result(p2_green_out)
    );
    
    block_P2 P2_Blue(
        .in1(in1[7:0]), .in2(in2[7:0]), .in3(in3[7:0]),
        .in4(in4[7:0]), .in5(in5[7:0]), .in6(in6[7:0]),
        .in7(in7[7:0]), .in8(in8[7:0]), .in9(in9[7:0]),
        
        .p2_result(p2_blue_out)
    );
    
    //comparator blocks to find the minimum among R,G,B
    //compare p0,p1,p2
    wire [1:0]cmp_out_0,cmp_out_1,cmp_out_2;
    
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
        
    //Multiplexers Instantiations
    
   //p0,p1,p2 blocks
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
    
    //min atm muxes
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
    
    //stage 7 multiplier block instantiations
    Multiplier multiply_P0(
        .a(inv_mux0_reg),
        .b(P0_reg),
        
        .product(prod0)
    );
    
    Multiplier multiply_P1(
        .a(inv_mux1_reg),
        .b(P1_reg),
        
        .product(prod1)
    );
    
    Multiplier multiply_P2(
        .a(inv_mux2_reg),
        .b(P2_reg),
        
        .product(prod2)
    );
    
    //17 bit multiplexer
    mux_17bit Stage_7_Mux(
        .m1(prod0), .m2(prod1), .m3(prod2),
        
        .sel(final_edge_reg_2),
        
        .p(pre_transmission)
    );

    //subtractor instantiation
    Subtractor Sub(
        .a(pre_transmission),
        .diff(subtract_out)
    );
    
    //Subtractor modules to compute (Ic - Ac)
    Subtractor_SRSC Sub_Red(
        .a(in5[23:16]),
        .b(A_R),
    
        .out(IR_minus_AR),
        .add_or_sub(add_or_sub_R)
    );
    
    Subtractor_SRSC Sub_Green(
        .a(in5[15:8]),
        .b(A_G),
    
        .out(IG_minus_AG),
        .add_or_sub(add_or_sub_G)
    );


    Subtractor_SRSC Sub_Blue(
        .a(in5[7:0]),
        .b(A_B),
    
        .out(IB_minus_AB),
        .add_or_sub(add_or_sub_B)
    );
    
    
    //LUT to output the inverse of transmission values(Q0.16) in Q2.14 format
    Trans_LUT Transmission_Reciprocal_LUT(
        .in_q016(transmission),
        
        .out_q214(inverse_transmission)
    );

    //Multiplier modules to compute (Ic-Ac)*(1/T)
    Multiplier_SRSC Mult_Red(
        .p(IR_minus_AR_reg),
        .q(inverse_transmission_reg),
        
        .result(Diff_R_times_T)
    );
        
    Multiplier_SRSC Mult_Green(
        .p(IG_minus_AG_reg),
        .q(inverse_transmission_reg),
        
        .result(Diff_G_times_T)
    );
    
    Multiplier_SRSC Mult_Blue(
        .p(IB_minus_AB_reg),
        .q(inverse_transmission_reg),
        
        .result(Diff_B_times_T)
    );
    
    //Adder blocks to compute Ac +/- (|I-A|/t)
    Adder_SRSC Add_Red(
            .a(A_R_reg2),
            .b(Mult_Red_Reg),
            
            .add_or_sub(add_or_sub_R_reg2),
            
            .out(J_R)
        );
        
    Adder_SRSC Add_Green(
            .a(A_G_reg2),
            .b(Mult_Green_Reg),
            
            .add_or_sub(add_or_sub_G_reg2),
            
            .out(J_G)
        );
        
    Adder_SRSC Add_Blue(
            .a(A_B_reg2),
            .b(Mult_Blue_Reg),
            
            .add_or_sub(add_or_sub_B_reg2),
            
            .out(J_B)
        );
    
endmodule
