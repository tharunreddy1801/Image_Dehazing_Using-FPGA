`timescale 1ns/1ps
module LUT (
    input wire [7:0] in,
    output reg [8:0] out
);
    integer i;
    // Precomputed LUT for 256 / in (avoid division)
    reg [8:0] lut [0:255];

    initial begin
        lut[0]   = 9'd0;    lut[1]   = 9'd256;  lut[2]   = 9'd128;  
        lut[3]   = 9'd85;   lut[4]   = 9'd64;   lut[5]   = 9'd51;
        lut[6]   = 9'd42;   lut[7]   = 9'd36;   lut[8]   = 9'd32;
        lut[9]   = 9'd28;   lut[10]  = 9'd25;   lut[11]  = 9'd23;
        lut[12]  = 9'd21;   lut[13]  = 9'd19;   lut[14]  = 9'd18;
        lut[15]  = 9'd17;   lut[16]  = 9'd16;   lut[17]  = 9'd15;
        lut[18]  = 9'd14;   lut[19]  = 9'd13;   lut[20]  = 9'd12;
        lut[21]  = 9'd12;   lut[22]  = 9'd11;   lut[23]  = 9'd11;
        lut[24]  = 9'd10;   lut[25]  = 9'd10;   lut[26]  = 9'd9;
        lut[27]  = 9'd9;    lut[28]  = 9'd9;    lut[29]  = 9'd8;
        lut[30]  = 9'd8;    lut[31]  = 9'd8;    lut[32]  = 9'd8;
        lut[33]  = 9'd7;    lut[34]  = 9'd7;    lut[35]  = 9'd7;
        lut[36]  = 9'd7;    lut[37]  = 9'd6;    lut[38]  = 9'd6;
        lut[39]  = 9'd6;    lut[40]  = 9'd6;    lut[41]  = 9'd6;
        lut[42]  = 9'd6;    lut[43]  = 9'd5;    lut[44]  = 9'd5;
        lut[45]  = 9'd5;    lut[46]  = 9'd5;    lut[47]  = 9'd5;
        lut[48]  = 9'd5;    lut[49]  = 9'd5;    lut[50]  = 9'd5;
        lut[51]  = 9'd5;    lut[52]  = 9'd4;    lut[53]  = 9'd4;
        lut[54]  = 9'd4;    lut[55]  = 9'd4;    lut[56]  = 9'd4;
        lut[57]  = 9'd4;    lut[58]  = 9'd4;    lut[59]  = 9'd4;
        lut[60]  = 9'd4;    lut[61]  = 9'd4;    lut[62]  = 9'd4;
        lut[63]  = 9'd4;    lut[64]  = 9'd4;    lut[65]  = 9'd3;
        lut[66]  = 9'd3;    lut[67]  = 9'd3;    lut[68]  = 9'd3;
        lut[69]  = 9'd3;    lut[70]  = 9'd3;    lut[71]  = 9'd3;
        lut[72]  = 9'd3;    lut[73]  = 9'd3;    lut[74]  = 9'd3;
        lut[75]  = 9'd3;    lut[76]  = 9'd3;    lut[77]  = 9'd3;
        lut[78]  = 9'd3;    lut[79]  = 9'd3;    lut[80]  = 9'd3;
        lut[81]  = 9'd3;    lut[82]  = 9'd3;    lut[83]  = 9'd3;
        lut[84]  = 9'd3;    lut[85]  = 9'd3;    lut[86]  = 9'd2;
        lut[87]  = 9'd2;    lut[88]  = 9'd2;    lut[89]  = 9'd2;
        lut[90]  = 9'd2;    lut[91]  = 9'd2;    lut[92]  = 9'd2;
        lut[93]  = 9'd2;    lut[94]  = 9'd2;    lut[95]  = 9'd2;
        lut[96]  = 9'd2;    lut[97]  = 9'd2;    lut[98]  = 9'd2;
        lut[99]  = 9'd2;    lut[100] = 9'd2;
        lut[101] = 9'd2; lut[102] = 9'd2; lut[103] = 9'd2; lut[104] = 9'd2;
        lut[105] = 9'd2; lut[106] = 9'd2; lut[107] = 9'd2; lut[108] = 9'd2;
        lut[109] = 9'd2; lut[110] = 9'd2; lut[111] = 9'd2; lut[112] = 9'd2;
        lut[113] = 9'd2; lut[114] = 9'd2; lut[115] = 9'd2; lut[116] = 9'd2;
        lut[117] = 9'd2; lut[118] = 9'd2; lut[119] = 9'd2; lut[120] = 9'd2;
        lut[121] = 9'd2; lut[122] = 9'd2; lut[123] = 9'd2; lut[124] = 9'd2;
        lut[125] = 9'd2; lut[126] = 9'd2; lut[127] = 9'd2; lut[128] = 9'd2;
        lut[129] = 9'd1;
        
        for (i = 130; i < 256; i = i + 1) begin
            lut[i] = 9'd1;
        end
    end

    always @(*) begin
        out = lut[in];  
    end

endmodule
