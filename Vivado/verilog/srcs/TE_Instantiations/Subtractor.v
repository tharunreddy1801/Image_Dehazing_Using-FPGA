// Compute T(x) = 1 - ω * min(Pc / Ac)
module Subtractor (
    input  [15:0] in, // ω * min(Pc / Ac) : c ∈ {R, G, B}
    
    output [15:0] out // Transmission value in Q0.16
);
    
    parameter [15:0] ONE = 16'd65535; // 0.999.... = 1.0 in Q0.16 format
    parameter [15:0] T0  = 16'd21299; // Lower bound for transmission = 0.325 in Q0.16 format
    parameter [15:0] MAX_T  = 16'd44237; // ONE - T0 = 0.675 in Q0.16 format
    
    assign out = (in > MAX_T) ?  T0 : ONE - in;
    
endmodule
