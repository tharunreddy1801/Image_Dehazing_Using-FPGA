module Comparator_Minimum(
    input [7:0]  red, green, blue,
    output [1:0] min_val
);

    assign min_val = (red <= green && red <= blue) ? 2'b00 :
                     (green <= red && green <= blue) ? 2'b01 :
                     2'b10;

endmodule
