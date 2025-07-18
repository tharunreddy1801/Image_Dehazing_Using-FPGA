def generate_reciprocal_lut_q0_16():
    print("module ReciprocalLUT (")
    print("    input  [7:0] in_val,")
    print("    output reg [15:0] out_val")
    print(");")
    print()
    print("always @(*) begin")
    print("    case (in_val)")

    for i in range(1, 256):
        reciprocal = 1 / i
        fixed_point = int(round(reciprocal * (1 << 16)))  # Q0.16 format
        print(f"        8'd{i:3}: out_val = 16'd{fixed_point:5};  // 1/{i} ≈ {reciprocal:.8f}")

    print("        default: out_val = 16'd0;  // undefined for 0")
    print("    endcase")
    print("end")
    print()
    print("endmodule")

# Run the function
generate_reciprocal_lut_q0_16()
