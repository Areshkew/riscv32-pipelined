module B_type(
    input [2:0] funct3,
	input [31:0] PC,
    input signed [31:0] imm,
    input signed [31:0] rv1,
    input signed [31:0] rv2,
    output reg [31:0] out,
    output reg jump_enable
);
    wire [31:0] tempA; // rv1
    wire [31:0] tempB; // rv2
    
    // Convert to unsigned
    assign tempA = rv1;
    assign tempB = rv2;

    always @(funct3 or rv1 or rv2) begin
        case(funct3)
        3'b000: 
		  begin
		  out = (rv1==rv2)? (imm-12) : (0);
		  jump_enable = (rv1==rv2)?1:0;
		  end
		  3'b001: 
		  begin
		  out = (rv1!=rv2)? (imm-12) : (0);
		  jump_enable = (rv1!=rv2)?1:0;
		  end
        3'b100: 
		  begin
		  out = (rv1<rv2)? (imm-12) : (0);
		  jump_enable = (rv1<rv2)?1:0;
		  end
        3'b101: 
		  begin
		  out = (rv1>=rv2)? (imm-12) : (0);
		  jump_enable = (rv1>=rv2)?1:0;
		  end
        3'b110: 
		  begin
		  out = (tempA<tempB)? (imm-12) : (0);
		  jump_enable = (tempA<tempB)?1:0;
		  end
        3'b111: 
		  begin
		  out = (tempA>=tempB)? (imm-12) : (0);
		  jump_enable = (tempA>=tempB)?1:0;
		  end
		endcase
    end

endmodule