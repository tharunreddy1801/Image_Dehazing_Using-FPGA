# generate_lut_reciprocal_q016_to_q214.py

def generate_verilog_lut(filename="Transmission_Reciprocal_LUT.v"):
    with open(filename, "w") as f:
        f.write("// Auto-generated LUT: Q0.16 input -> Q2.14 reciprocal output\n")
        f.write("module ReciprocalLUT(\n")
        f.write("    input  wire [15:0] in_q016,\n")
        f.write("    output reg  [15:0] out_q214\n")
        f.write(");\n\n")
        f.write("    always @(*) begin\n")
        f.write("        case(in_q016)\n")

        for i in range(1, 65536):
            recip = (1 << 30) // i  # (65536 * 16384) = 1073741824
            if recip > 65535:
                recip = 65535  # clamp to max value of 16-bit Q2.14
            f.write(f"            16'h{i:04X}: out_q214 = 16'h{recip:04X};\n")

        # Handle zero input case (optional saturation)
        f.write("            16'h0000: out_q214 = 16'hFFFF;\n")
        f.write("        endcase\n")
        f.write("    end\n")
        f.write("endmodule\n")

    print(f"Verilog LUT module written to {filename}")

generate_verilog_lut()
