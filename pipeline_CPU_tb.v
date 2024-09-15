`include "pipeline_CPU.v"
`timescale 1ns / 1ps
 
module pipeline_CPU_TB();
    reg clk, reset;
    wire [31:0] PC;
    wire [31:0] L_regdata_out;
    wire [31:0] EM_daddr_out;
    wire [31:0] MW_drdata_out;

    pipeline_CPU riscv(clk, reset, PC, L_regdata_out, EM_daddr_out, MW_drdata_out);
	 
    initial begin
        clk=0;
        repeat(50) #5 clk = ~clk;
    end 

    initial begin
        $dumpfile("pipeline_CPU_tb.vcd");
        $dumpvars(0, pipeline_CPU_TB);
       
        clk = 1;
        reset = 1;
        #10;
        reset = 0;
    end
endmodule