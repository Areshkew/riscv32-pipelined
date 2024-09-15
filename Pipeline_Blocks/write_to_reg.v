module write_to_reg (
    input [6:0] MW_op_out,
    input [2:0] MW_funct3_out,
    input [31:0] MW_daddr_out,
    input [31:0] MW_drdata_out,
    input [31:0] MW_regdata_out,
    output reg [31:0] L_regdata_out
);  
    reg [31:0] offset;

    always @(*)
    begin 

        if (MW_op_out == 7'b0000011)
        begin
            offset = (MW_daddr_out[1:0]<<3);
            case(MW_funct3_out)
                3'b000: L_regdata_out = {{24{MW_drdata_out[offset+7]}}, MW_drdata_out[offset +: 8]};    //LB
                3'b001: L_regdata_out = {{16{MW_drdata_out[offset+15]}}, MW_drdata_out[offset +: 16]};  //LH
                3'b010: L_regdata_out = MW_drdata_out;                                   			    //LW
                3'b100: L_regdata_out = {24'b0, MW_drdata_out[offset +: 8]};             			    //LBU
                3'b101: L_regdata_out = {16'b0, MW_drdata_out[offset +: 16]};            			    //LHU
            endcase 
        end
         else begin
            L_regdata_out = MW_regdata_out;
        end

    end
endmodule
