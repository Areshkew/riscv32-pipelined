module R_type(
    input [2:0] func3,
    input bit_th,
    input signed [31:0] operator1,
    input signed [31:0] operator2,
    output reg[31:0] out
);
    wire [31:0] tempA;
    wire [31:0] tempB;
    assign tempA = operator1;
    assign tempB = operator2;

    always @(func3 or bit_th or operator1 or operator2) 
    begin
    	case(func3)
            3'b000:  
                begin  
                if(bit_th)
                    out = operator1-operator2; // sub      
                else
                    out = operator1+operator2; // add    
                end
            3'b001:    out = operator1<<operator2[4:0];	    // sll
            3'b010:    out = operator1<operator2;           // slt
            3'b011:    out = tempA<tempB;                     // sltu
            3'b100:    out = operator1^operator2;           // xor 
            3'b101:   
                begin
                    if(bit_th)
                        out = operator1>>>operator2[4:0]; // sra      
                    else
                        out = operator1>>operator2[4:0];  // srl 
                end

            3'b110: out = operator1|operator2; // or         
            3'b111:    out = operator1&operator2;       //and
        endcase
    end

endmodule

