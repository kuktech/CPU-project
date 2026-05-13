module instruction_decoder (
input [15:0] instruction,
input [7:0] status,
input [15:0] pc_in,
output reg alu_operand,
output reg [10:0] value,
output reg [2:0] des_reg,
output reg [2:0] src_reg,
output reg [15:0] pc_out
);

wire [4:0] op_group = instruction[15:11];
wire sop1 = instruction[4:2];
wire sop2 = instruction[1:0];

always @(*) begin
    value = 11'b0;
    des_reg = 3'b0;
    src_reg = 3'b0;
case (op_group)
    00000: begin if (sop2 == 2'b00) pc_out = pc_in + 1'b1;
                else if (sop2 == 2'b01) 
           end
    default: 
end



    
endcase
endmodule
