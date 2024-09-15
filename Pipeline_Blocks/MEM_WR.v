module MEM_WR (
  input clk,

  input [6:0] EM_op_out,
  input  [2:0] EM_funct3_out,
  input  [31:0] EM_daddr_out,
  input  EM_wer_out,
  input  [4:0] EM_rd_out,
  input  [31:0] EM_regdata_out,
  input [31:0] DMEM_drdata_out,

  output reg [6:0] MW_op_out,
  output reg [2:0] MW_funct3_out,
  output reg [31:0] MW_daddr_out,
  output reg MW_wer_out,
  output reg [4:0] MW_rd_out,
  output reg [31:0] MW_regdata_out,
  output reg [31:0] MW_drdata_out
);

  always @(posedge clk) begin
    MW_funct3_out = EM_funct3_out;
    MW_op_out = EM_op_out;
    MW_daddr_out = EM_daddr_out;
    MW_wer_out = EM_wer_out;
    MW_rd_out = EM_rd_out;
    MW_regdata_out = EM_regdata_out;
    MW_drdata_out = DMEM_drdata_out;
  end

endmodule
