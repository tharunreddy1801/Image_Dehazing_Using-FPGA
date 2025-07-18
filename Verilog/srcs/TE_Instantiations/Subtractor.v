module Subtractor(
    input  [15:0] in,  // OMEGA * min(Pc / Ac) ; c ∈ {R, G, B}
    
    output [15:0] diff // Final Transmission value
);
    
    parameter [16:0] ONE = 17'd65536; // 1.0 in Q0.17 format
    parameter [15:0] T0  = 16'd16384; // Lower bound for transmission is 0.25 in Q0.16 format
    
    assign diff = ((ONE - in) < T0) ?  T0 : ONE - in;
    
endmodule
