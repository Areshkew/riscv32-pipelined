module ctrl_unit (
	input [31:0] instr32,  
    output reg [3:0] we,
    output reg signed [31:0] imm,
    output reg we_reg
);

    always@(*) begin
            case(instr32[6:0])
                7'b0000011: // TIPO I (Load operations)
                begin
                    imm = {{20{instr32[31]}},instr32[31:20]};
                    we_reg = 1;
                    we = 4'b0;
                end
                //

                7'b0010011: // TIPO I (Immediate Operations)
                begin
                    imm = { {20{instr32[31]}}, instr32[31:20] }; // Convert to 32 bits, repeat 20 bits with sign if exists. This is for negative number
                    we_reg = 1;
                    we = 4'b0;
                end
                //

                7'b0010111: // TIPO U (add upper immediate to PC) 
                begin
					imm = {instr32[31:12], 12'b0};
					we_reg = 1;
					we = 4'b0;
				end
                //

                7'b0100011: // TIPO S (Store)
                begin
                    imm = { {20{instr32[31]}}, instr32[31:25], instr32[11:7] };
                    we_reg = 0;
                    
                    case(instr32[14:12])
                        3'b000: we = 4'b0001;
                        3'b001: we = 4'b0011;
                        3'b010: we = 4'b1111; 
                    endcase
                end
                //

                7'b0110011: // TIPO R (Arithmetic Operations)
                begin
                    we_reg = 1;
                    we = 4'b0;
                end
                //

                7'b0110111: // TIPO U (load upper immediate)
                begin
					imm = {instr32[31:12], 12'b0};
					we_reg = 1;
					we = 4'b0;
				end
                //

                7'b1100011: // TIPO B (Branch if)
                begin
                    imm = {{20{instr32[31]}}, instr32[31], instr32[7], instr32[30:25], instr32[11:8], 1'b0};
                    we_reg = 0;
                    we = 4'b0;
                end
                //

                7'b1100111: // TIPO I (jump and link register)
                begin
					imm = {{20{instr32[31]}}, instr32[31:20]};
					we_reg = 1;
					we = 4'b0;
                end
                //

                7'b1101111: // TIPO J (jump and link)
                begin
					imm = {{11{instr32[31]}}, instr32[31], instr32[19:12], instr32[20], instr32[30:21], 1'b0};
					we_reg = 1;
					we = 4'b0;
                end

			endcase
    end
endmodule