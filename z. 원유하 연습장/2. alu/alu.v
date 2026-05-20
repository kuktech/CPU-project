module alu(

input wire [15:0] l_operand,
input wire [15:0] r_operand,

input wire [4:0] alu_sel,

input wire exe_32,

output reg [15:0] alu_result0,
output reg [15:0] alu_result1,

output reg zf,
output reg cf,
output reg nf,
output reg vf

);

reg [16:0] temp;

always @(*) begin

    alu_result0 = 16'b0;
    alu_result1 = 16'b0;

    zf = 1'b0;
    cf = 1'b0;
    nf = 1'b0;
    vf = 1'b0;

    case(alu_sel)

    // ADD
    5'b00000: begin

        temp = l_operand + r_operand;

        alu_result0 = temp[15:0];
        cf = temp[16];

        vf = (~(l_operand[15] ^ r_operand[15])) &
             (l_operand[15] ^ alu_result0[15]);
    end

    // SUB
    5'b00001: begin

        temp = l_operand - r_operand;

        alu_result0 = temp[15:0];
        cf = temp[16];

        vf = ((l_operand[15] ^ r_operand[15])) &
             (l_operand[15] ^ alu_result0[15]);
    end

    // AND
    5'b00010:
        alu_result0 = l_operand & r_operand;

    // OR
    5'b00011:
        alu_result0 = l_operand | r_operand;

    // XOR
    5'b00100:
        alu_result0 = l_operand ^ r_operand;

    // NOT
    5'b00101:
        alu_result0 = ~l_operand;

    // INC
    5'b00110: begin

        temp = l_operand + 1;

        alu_result0 = temp[15:0];
        cf = temp[16];
    end

    // DEC
    5'b00111: begin

        temp = l_operand - 1;

        alu_result0 = temp[15:0];
        cf = temp[16];
    end

    // SHL
    5'b01000: begin

        alu_result0 = l_operand << 1;
        cf = l_operand[15];
    end

    // SHR
    5'b01001: begin

        alu_result0 = l_operand >> 1;
        cf = l_operand[0];
    end

    // 32bit ADD
    5'b01010: begin

        if(exe_32) begin

            {cf, alu_result0} =
                l_operand + r_operand;

            alu_result1 = cf;
        end
    end

    default: begin
        alu_result0 = 16'b0;
        alu_result1 = 16'b0;
    end

    endcase

    // Zero Flag
    if(alu_result0 == 16'b0)
        zf = 1'b1;

    // Negative Flag
    nf = alu_result0[15];

end

endmodule