module instruction_decoder (
input [15:0] instruction,
input [7:0] status,
output reg alu_operand
);
wire opcode = instruction[15:11];
wire rd = instruction[10:8];
wire rs = instruction[7:5];
wire sop1 = instruction[4:2];
wire sop2 = instruction[1:0];

case (opcode)
    00000: begin if (sop2 == 2'b00)
                 else if (sop2 == 2'b01)
           end





    default: 
endcase
endmodule
