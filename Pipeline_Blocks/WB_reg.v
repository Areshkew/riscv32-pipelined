module WB_reg(
	input clk,

	input [4:0] MW_rd_out,
	input [31:0] L_regdata_out,
	input MW_wer_out,
    
	output reg [4:0] WB_rd_out,
	output reg [31:0] WB_regdata_out,
	output reg WB_wer_out
);
	always@(posedge clk)
	begin
		WB_rd_out = MW_rd_out;
		WB_regdata_out = L_regdata_out;
		WB_wer_out = MW_wer_out;
	end
endmodule