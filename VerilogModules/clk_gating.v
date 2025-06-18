module clk_gating( input clk_in, input enable,output  a_out,output  t_out);
assign a_out= enable & clk_in;
assign t_out=enable & ~clk_in;
endmodule
