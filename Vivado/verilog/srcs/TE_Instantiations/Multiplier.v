// Compute ω * Pc / Ac
module Multiplier (
    input         clk,
    input         rst,
    
    input  [15:0] Ac_Inv, // Scaled Inverted Atmospheric Light value in Q0.16 format (ω * 1/Ac) 
    input  [7:0]  Pc,     // Edge Detection Filter result
    
    output [15:0] product // ω * min(Pc / Ac) ; c ∈ {R, G, B} in Q0.16 format
);
    
    // Pipeline registers
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
    
    wire [23:0] result = Ac_Inv_P * Pc_P; // Q8.16
    
    assign product = result[15:0]; // Scale down to Q0.16 and eliminate overflow
    
endmodule
