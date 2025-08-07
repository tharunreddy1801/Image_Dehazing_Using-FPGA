module Multiplier (
    input clk,
    input rst,
    input  [15:0] Ac_Inv, // Inverted Atmospheric Light value in Q0.16 format
    input  [7:0]  Pc,     // Edge Detection Filter result
    output [15:0] product // OMEGA * min(Pc / Ac) ; c ∈ {R, G, B} in Q0.16 format
);

    parameter [15:0] MAX_OUTPUT = 16'd47415;   // 0.725 in Q0.16
    
    wire [23:0] unscaled_product;
    
    reg [15:0] Ac_Inv_P;
    reg [7:0]  Pc_P;
    
    // Pipeline inputs to reduce fan-out
    always @(posedge clk) begin
        if(rst) begin
            Ac_Inv_P <= 0;
            Pc_P <= 0;
        end
        else begin
            Ac_Inv_P <= Ac_Inv;
            Pc_P <= Pc;
        end
    end
    
    assign unscaled_product = Ac_Inv_P * Pc_P;
    
    // Combinational logic for OMEGA scaling
    wire [27:0] pre_scaled_product = (unscaled_product << 4) - unscaled_product;
    wire [23:0] scaled_product = pre_scaled_product >> 4;
    wire [15:0] result = scaled_product[15:0];
    
    // Overflow detection and output
    wire is_gt_one = (unscaled_product[23:16] != 0);
    assign product = is_gt_one ? MAX_OUTPUT : result;
    
endmodule
