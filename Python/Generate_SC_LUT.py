def to_q8_8(val):
    """Convert a float to Q8.8 fixed-point (16-bit unsigned int)."""
    return min(65535, max(0, int(round(val * 256))))

def generate_verilog_lut_module(power, module_name, filename):
    with open(filename, 'w') as f:
        f.write(f"module {module_name} (\n")
        f.write("    input  [7:0] x,\n")
        f.write("    output reg [15:0] y_q8_8\n")
        f.write(");\n\n")
        f.write("    always @(*) begin\n")
        f.write("        case (x)\n")

        for x in range(256):
            val = x ** power if x > 0 else 0
            q8_8_val = to_q8_8(val)
            comment = f"{x}^{power:.1f} ~= {val:.6f}"  # safer ASCII
            f.write(f"            8'd{x:<3}: y_q8_8 = 16'd{q8_8_val};  // {comment}\n")

        f.write("            default: y_q8_8 = 16'd0;\n")
        f.write("        endcase\n")
        f.write("    end\n")
        f.write("endmodule\n")
    print(f"Generated {filename} for {module_name} (x^{power})")

# Generate both LUTs
generate_verilog_lut_module(0.3, "LUT_03", "LUT_03.v")
generate_verilog_lut_module(0.7, "LUT_07", "LUT_07.v")
