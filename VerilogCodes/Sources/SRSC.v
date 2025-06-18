module SRSC (
    input  wire        clk,
    input  wire        rst,
    
    input  wire [7:0]  I_R,
    input  wire [7:0]  I_G, 
    input  wire [7:0]  I_B,
    input wire input_is_valid,
    
    input  wire [7:0]  A_R,
    input  wire [7:0]  A_G,
    input  wire [7:0]  A_B,
    input wire ale_in_valid,
   
    input  wire [15:0] transmission,
    input  wire        i_trans_valid,
    
    output wire [7:0]   J_R,
    output wire [7:0]   J_G,
    output wire [7:0]   J_B,
    output wire         o_valid
);

    //Compute (Ic - Ac)
    wire [7:0] IR_minus_AR, IG_minus_AG, IB_minus_AB;
    wire add_or_sub_R, add_or_sub_G, add_or_sub_B;
        
    //Inverted transmission value
    wire [15:0] inverse_transmission;
    
    //Pipeline Registers for stage 7
    reg [7:0] A_R_reg, A_G_reg, A_B_reg;
    reg [7:0] IR_minus_AR_reg, IG_minus_AG_reg, IB_minus_AB_reg;
    reg add_or_sub_R_reg, add_or_sub_G_reg, add_or_sub_B_reg;
    reg [15:0] inverse_transmission_reg;
    reg stage_7_valid;
    
    //Pipeline Registers for stage 8
    reg [7:0] A_R_reg1, A_G_reg1, A_B_reg1;
    reg add_or_sub_R_reg1, add_or_sub_G_reg1, add_or_sub_B_reg1;
    reg stage_8_valid;

    //Compute (Ic-Ac)*(1/T)
    wire [15:0] Diff_R_times_T, Diff_G_times_T, Diff_B_times_T;
    
    //Pipeline Registers for stage 9
    reg [7:0] A_R_reg2, A_G_reg2, A_B_reg2;
    reg add_or_sub_R_reg2, add_or_sub_G_reg2, add_or_sub_B_reg2;
    reg[15:0] Mult_Red_Reg, Mult_Green_Reg, Mult_Blue_Reg;
    reg stage_9_valid;
    
    //Compute Ac +/- (|I-A|/t)
    wire [7:0] Sum_Red, Sum_Green, Sum_Blue;
    
    
    //Update stage 7 pipeline registers
    always @(posedge clk)
    begin
        if(rst)
        begin
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
        begin
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
            
            stage_7_valid <= input_is_valid;
        end
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
    
    assign o_valid = stage_9_valid;
    
////////////////////////////////////////////////////////////////
//BLOCK DECLARATIONS
////////////////////////////////////////////////////////////////

    //Subtractor modules to compute (Ic - Ac)
    Subtractor_SRSC Sub_Red(
        .a(I_R),
        .b(A_R),
    
        .out(IR_minus_AR),
        .add_or_sub(add_or_sub_R)
    );
    
    Subtractor_SRSC Sub_Green(
        .a(I_G),
        .b(A_G),
    
        .out(IG_minus_AG),
        .add_or_sub(add_or_sub_G)
    );


    Subtractor_SRSC Sub_Blue(
        .a(I_B),
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
