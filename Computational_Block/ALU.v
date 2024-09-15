
module ALU (
    input [2:0] funct3,
    input [6:0] op,
    input bit_th,
    input [31:0] rv1,
    input [31:0] rv2,
    input [3:0] we, 
    input signed [31:0] imm,
    input [31:0] PC,
	input pc_replace_old,
	input enable_old,
    output reg [31:0] regdata,
    output reg [31:0] pc,
    output reg[31:0] daddr,
    output reg [3:0] we_final,
    output reg [31:0] dwdata,
	output reg[31:0] PC_new,
	output reg pc_replace,
	output reg pc_JALR
);
	 wire [31:0] regdata_R, regdata_I;
	 wire [31:0] regdata_L, PC_val;
	 wire jump_enable;
	 initial begin
		PC_new=0;
		pc_replace=0;
		pc_JALR=0;
	 end
	 
    always@(*) 
    begin
		  PC_new=0;
		  pc_replace=0;
		  pc_JALR=0;
		  
        case(op)
			7'b0000011:     // I
				begin
					daddr = rv1+imm;    
					we_final = we;
				end

			7'b0010011:     // I2
				begin
					regdata = regdata_I;
					we_final = we;
				end


			7'b0010111:		//U (Add upper imm to PC)
				begin
					regdata = PC+imm;
               		we_final = we;
				end
            
            
            7'b0100011:     //S type instructions
				begin
					daddr = rv1+imm;
						case(funct3)
						3'b000: dwdata = {rv2[7:0],rv2[7:0],rv2[7:0],rv2[7:0]};
						3'b001: dwdata = {rv2[15:0],rv2[15:0]};
						3'b010: dwdata = rv2;
						endcase
					we_final = we<<daddr[1:0];
				end

			7'b0110011:      //R type instructions
				begin
					regdata = regdata_R;
					we_final = we;
				end

			7'b0110111:		//U  (Load upper imm)
				begin
					regdata = imm;
                	we_final = we;
				end

			7'b1100011:		//B type 
				begin
					PC_new = PC_val;
				we_final = we;
					pc_replace=(pc_replace_old|!enable_old)?0:jump_enable;
				end

			7'b1100111:		//JALR
				begin
					regdata = PC+4;
					PC_new = (rv1+imm)&32'hfffffffe;
              		we_final = we;
					pc_replace=(pc_replace_old|!enable_old)?0:1;
					pc_JALR=1;
				end

			7'b1101111:		//JAL instruction
				begin
					regdata = PC+4;
					PC_new = imm-12;
					we_final = we;
					pc_replace=(pc_replace_old|!enable_old)?0:1;
				end
				
			endcase
    end

    // Module Instantiation
    R_type r1(funct3, bit_th, rv1, rv2, regdata_R);   
    I_type i1(bit_th, imm, rv1, funct3, regdata_I);
	B_type b1(funct3, PC, imm, rv1, rv2, PC_val,jump_enable);
	
endmodule