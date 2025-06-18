module reciprocal_lut_12 (
    input  wire [11:0] t,
    output reg  [15:0] inv_t
);
    integer i;

    reg [15:0] lut_mem [0:4095];

    // Initialize the LUT at compile time (for simulation).
    // In an FPGA/ASIC flow, you might load from a memory init file (.mif/.hex).
    initial begin
        
        for (i = 0; i < 4096; i = i + 1) begin
            if (i == 0) begin
                lut_mem[i] = 16'd0; 
            end
            else begin
                lut_mem[i] = (16'd256 / i);  
            end
        end
    end

    always @(*) begin
        inv_t = lut_mem[t];
    end

endmodule
