module EX_MEM (
  input clk,

  input act,
  input [6:0] DE_op_out,
  input [2:0] DE_funct3_out,
  input [31:0] AU_daddr_out,
  input [3:0] AU_we_out,
  input DE_wer_out,
  input [4:0] DE_rd_out,
  input [31:0] AU_regdata_out,
  input [31:0] AU_dwdata_out,
	input pc_replace,
	input enable,

  output reg [6:0] EM_op_out,
  output reg [2:0] EM_funct3_out,
  output reg [31:0] EM_daddr_out,
  output reg [3:0] EM_we_out,
  output reg EM_wer_out,
  output reg [4:0] EM_rd_out,
  output reg [31:0] EM_regdata_out,
  output reg [31:0] EM_dwdata_out,
	output reg EM_pc_replace_out,
	output reg EM_enable_out 
);

  always @(posedge clk) begin
    EM_op_out = DE_op_out;
    EM_funct3_out = DE_funct3_out;
    EM_daddr_out = AU_daddr_out;
    EM_we_out = AU_we_out&{act,act,act,act};
    EM_wer_out = DE_wer_out&act;
    EM_rd_out = DE_rd_out;
    EM_regdata_out = AU_regdata_out;
    EM_dwdata_out = AU_dwdata_out;
		EM_pc_replace_out = pc_replace;
		EM_enable_out = enable;
  end

endmodule
