module Trans_LUT (
    input  [15:0] x,     // Q0.16 Transmission value input (unsigned)
    output [15:0] y      // Q2.14 Inverse Transmission value output (unsigned)
);
    
    wire [31:0] reciprocal;
    assign reciprocal = (x != 0) ? (32'd1073741824 / x) : 32'd65535;
    
    assign y = (reciprocal > 32'hFFFF) ? 16'hFFFF : reciprocal[15:0];
    
endmodule
