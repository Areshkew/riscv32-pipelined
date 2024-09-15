module IF_ID (
  input clk,                  
  input enable,      
  input pc_replace, 

  input wire[31:0] PC_in, 
  input wire [31:0] idata_in, 
  output reg [31:0] FD_idata_out, 
  output reg [31:0] FD_PC_out 
);
  

  always @(negedge clk) begin
    if (enable) begin
      
      // Añadir Addi en caso que se necesite (Stalling)
      FD_idata_out = pc_replace ? (32'b00000000000000000000000000010011) : idata_in;
      FD_PC_out = PC_in;
    end
  end
  

endmodule