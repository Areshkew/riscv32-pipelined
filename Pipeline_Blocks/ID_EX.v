module ID_EX (
  input clk,
  input enable,
  input pc_replace,

  //Register file inputs
  input bit_th_in,
  input [4:0] rs1_in,
  input [4:0] rs2_in,
  input [4:0] rd_in,
  input [2:0] funct3_in,
  input [6:0] op,
  input wer_in,
  input [31:0] rv1_in,
  input [31:0] rv2_in,

  //Control block inputs
  input [3:0] we_in,
  input signed [31:0] imm_in,
  input [31:0] iaddr_in,

  //Register file outputs
  output reg bit_th_out,
  output reg [4:0] DE_rs1_out,
  output reg [4:0] DE_rs2_out,
  output reg [4:0] DE_rd_out,
  output reg [2:0] DE_funct3_out,
  output reg [6:0] DE_op_out,
  output reg DE_wer_out,
  output reg [31:0] DE_rv1_out,
  output reg [31:0] DE_rv2_out,

  //Control block outputs
  output reg [3:0] DE_we_out,
  output reg signed [31:0] DE_imm_out,
  output reg [31:0] DE_iaddr_out,
	output reg DE_enable_out
);

  always @(posedge clk) begin
    if (enable) begin
      DE_rs1_out = rs1_in;
      DE_rs2_out = rs2_in;
      DE_rd_out = rd_in;
      DE_funct3_out = funct3_in;
      DE_op_out = op;
      DE_imm_out = imm_in;
      DE_iaddr_out = iaddr_in;
      DE_wer_out =  wer_in&!pc_replace&enable;
      DE_we_out = we_in&{!pc_replace&enable,!pc_replace&enable,!pc_replace&enable,!pc_replace&enable};
      DE_rv1_out = rv1_in;
      DE_rv2_out = rv2_in;
      bit_th_out = bit_th_in;
      DE_enable_out = enable;
    end
  end

endmodule
