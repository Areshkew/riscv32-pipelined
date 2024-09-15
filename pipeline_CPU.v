`include "Memory_Block/register_file.v"
`include "Memory_Block/instr_mem.v"
`include "Memory_Block/data_mem.v"

`include "Computational_Block/ALU.v"
`include "Computational_Block/R_type.v"
`include "Computational_Block/I_type.v"
`include "Computational_Block/S_type.v"
`include "Computational_Block/B_type.v"

`include "Pipeline_Blocks/IF_ID.v"
`include "Pipeline_Blocks/ID_EX.v"
`include "Pipeline_Blocks/EX_MEM.v"
`include "Pipeline_Blocks/MEM_WR.v"
`include "Pipeline_Blocks/ctrl_unit.v"
`include "Pipeline_Blocks/WB_reg.v"
`include "Pipeline_Blocks/write_to_reg.v"

// Forwarding: 
// El valor de rd en el registro EX/MEM y el registro MEM/WB se comparan con los valores rs1 y rs2 en el registro ID/EX.
// Si la instrucción requiere los valores rs1 y rs2, entonces el MUX (dentro del módulo pipeline_CPU) 
// selecciona el valor requerido y lo reenvía al CPU.

// Stalling:
// Cuando una instrucción intenta cambiar el valor del PC, se establece la señal pc_replace. Luego, las señales de control
// de la instrucción que sale del registro ID/EX se establecen en 0 y los datos idata correspondientes a la instrucción
// que sale del registro IF/ID se cambian a la instrucción ADDI x0,x0,0. De esta manera, se invalidan las instrucciones previamente cargadas.
// La instrucción con el nuevo valor de PC se carga en el siguiente ciclo de reloj.

// Hazard detection:
// Si hay una instrucción ALU inmediatamente después de una instrucción de carga que escribe en el registro leído por la instrucción ALU, 
// se detecta el riesgo y la señal de bandera se establece en 0 y el valor iaddr_upd se establece en 4. Esto disminuye el valor del PC en 4 
// para que la misma instrucción se cargue nuevamente. La señal act también se establece en 0, lo que establece todas las señales de control 
// de la instrucción ALU en 0, de modo que no se escriban valores incorrectos en los registros. El desplazamiento del PC se da por el valor pc_new. 
// Si el valor del PC se toma de un registro (en caso de JALR), la señal pc_JALR se establece en 1.
module pipeline_CPU(
    input clk,
    input reset,
	
    output reg [31:0] PC,  
	output [31:0] L_regdata_out,
	output [31:0] EM_daddr_out,
	output [31:0] MW_drdata_out
);

	// If_FD wires
	wire [31:0] FD_idata_out;
    wire [31:0] FD_PC_out;
	//

	reg enable;
	reg act;

	// PC wires
	wire [31:0] PC_new;
	wire pc_replace;
	wire pc_JALR;
	reg [31:0] PC_upd;

	// ID_EX wires
    wire [4:0] DE_rs1_out;
    wire [4:0] DE_rs2_out;
    wire [4:0] DE_rd_out;
    wire DE_wer_out;

	wire [31:0] CU_imm_out;
    wire [31:0] DE_rv1_out;
    wire [31:0] DE_rv2_out;
    wire [3:0] DE_we_out;
    wire signed [31:0] DE_imm_out;
    wire [31:0] DE_PC_out;
	
	//
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;

	wire [31:0] rv1;
	wire [31:0] rv2;

	// ALU
	reg [31:0] AU_rv1_in;
	reg [31:0] AU_rv2_in;

	// MEM_WR
    wire [3:0] EM_we_out;
    wire EM_wer_out;
	wire [6:0] EM_op_out;
    wire [4:0] EM_rd_out;
    wire [31:0] EM_regdata_out;
    wire [31:0] EM_dwdata_out;
    wire MW_wer_out;
    wire [4:0] MW_rd_out;
    wire [31:0] MW_regdata_out;
	wire [31:0] MW_daddr_out;
	wire [31:0] DMEM_drdata_out;

	// WB_reg
	wire [4:0] WB_rd_out;
	wire [31:0] WB_regdata_out;
	wire WB_wer_out;
	 
	 //PC update - here, PC is called PC
    always@(posedge clk)
        begin
            if(reset)       
                PC = 0;
				else if(enable==0 || pc_replace==0)
					PC = PC+4-PC_upd;
            else if(pc_JALR==0)
                PC = PC+4-PC_upd+PC_new; //DEFINE PC.
				else
					 PC = PC_new;

        end
	 
	wire [31:0] idata;
    wire CU_wer_out;
    wire [3:0] CU_we_out,AU_we_out;
    wire [2:0] DE_funct3_out,EM_funct3_out,MW_funct3_out;
    wire [6:0] DE_op_out,MW_op_out;
    wire [31:0] AU_regdata_out,AU_pc_out,AU_daddr_out,AU_dwdata_out;
	 
	 // Assign values to rs1,rs2,rd
	 assign rs1 = FD_idata_out[19:15];
	 assign rs2 = FD_idata_out[24:20];
	 assign rd = FD_idata_out[11:7];
	 wire [4:0] rd_final;
	 assign rd_final = (PC<16) ? 0 : MW_rd_out;

	 always@(*)
	 begin 
		PC_upd=32'b0;
		enable=1;
		act=1;
		
		// 
		if(EM_rd_out == DE_rs1_out && EM_wer_out == 1 && PC>=12)
		begin
			if(EM_op_out == 7'b0000011)
			begin
				PC_upd = 4;
				enable=0;
				act=0;
			end
			else
				begin
				AU_rv1_in = EM_regdata_out;
				end
		end
		else if(MW_rd_out == DE_rs1_out && MW_wer_out == 1 && PC>=16)
			begin
			AU_rv1_in = L_regdata_out;
			end
		else if(WB_rd_out == DE_rs1_out && WB_wer_out == 1 && PC>=20)
			begin
			AU_rv1_in = WB_regdata_out;
			end
		else
			begin
			AU_rv1_in = DE_rv1_out;
			end
		
		// 
		if(EM_rd_out == DE_rs2_out && EM_wer_out == 1 && PC>=12 && (DE_op_out[6:4]==3'b110 || DE_op_out[6:4]==3'b011 || DE_op_out[6:4]==3'b010))
		begin
			if(EM_op_out == 7'b0000011)
			begin
				PC_upd = 4;
				enable=0;
				act=0;
			end
			else
			begin
			AU_rv2_in = EM_regdata_out;
			end
		end
		else if(MW_rd_out == DE_rs2_out && MW_wer_out == 1 && PC>=16 && (DE_op_out[6:4]==3'b110 || DE_op_out[6:4]==3'b011 || DE_op_out[6:4]==3'b010))
			begin
			AU_rv2_in = L_regdata_out;
			end
		else if(WB_rd_out == DE_rs2_out && WB_wer_out == 1 && PC>=20 && (DE_op_out[6:4]==3'b110 || DE_op_out[6:4]==3'b011 || DE_op_out[6:4]==3'b010))
			begin
			AU_rv2_in = WB_regdata_out;
			end
		else
			begin
			AU_rv2_in = DE_rv2_out;
			end
	 end

	// Module Instantiation 
    instr_mem im1(PC, idata);
    IF_ID fd1(clk, enable, pc_replace, PC, idata, FD_idata_out, FD_PC_out);
    ctrl_unit c1(FD_idata_out,CU_we_out,CU_imm_out,CU_wer_out);
    register_file rf1(clk,rs1,rs2,rd_final,L_regdata_out,MW_wer_out,rv1,rv2);
    ID_EX de1(clk,enable,pc_replace,FD_idata_out[30],rs1,rs2,rd,FD_idata_out[14:12],FD_idata_out[6:0],CU_wer_out,rv1,rv2,CU_we_out,CU_imm_out,FD_PC_out,DE_bit_th_out,DE_rs1_out,DE_rs2_out,DE_rd_out,DE_funct3_out,DE_op_out,DE_wer_out,DE_rv1_out,DE_rv2_out,DE_we_out,DE_imm_out,DE_PC_out,DE_enable_out);

    ALU a1(DE_funct3_out,DE_op_out, DE_bit_th_out,AU_rv1_in,AU_rv2_in,DE_we_out,DE_imm_out,DE_PC_out,EM_pc_replace_out,EM_enable_out,AU_regdata_out,AU_pc_out,AU_daddr_out,AU_we_out,AU_dwdata_out,PC_new,pc_replace,pc_JALR);
    EX_MEM em1(clk,act,DE_op_out,DE_funct3_out,AU_daddr_out,AU_we_out,DE_wer_out,DE_rd_out,AU_regdata_out,AU_dwdata_out,pc_replace,enable,EM_op_out,EM_funct3_out,EM_daddr_out,EM_we_out,EM_wer_out,EM_rd_out,EM_regdata_out,EM_dwdata_out,EM_pc_replace_out,EM_enable_out); 
    data_mem dm1(clk,EM_daddr_out,EM_dwdata_out,EM_we_out,DMEM_drdata_out);
    MEM_WR mw1(clk,EM_op_out,EM_funct3_out,EM_daddr_out,EM_wer_out,EM_rd_out,EM_regdata_out,DMEM_drdata_out,MW_op_out,MW_funct3_out,MW_daddr_out,MW_wer_out,MW_rd_out,MW_regdata_out,MW_drdata_out);
    write_to_reg l1(MW_op_out,MW_funct3_out,MW_daddr_out,MW_drdata_out,MW_regdata_out,L_regdata_out);
	WB_reg wb1(clk,MW_rd_out,L_regdata_out,MW_wer_out,WB_rd_out,WB_regdata_out,WB_wer_out);
endmodule
