module instruction_decoder (
    input [15:0] instruction,
    input [7:0] status,

    output reg [4:0] alu_sel,
    output reg [3:0] op_group,
    output reg [2:0] des_reg,
    output reg [2:0] src_reg,
    output reg [10:0] value,

    output reg reg_wr,
    output reg sreg_wr,
    output reg pc_wr,
    output reg sp_wr,
    output reg mem_rd,
    output reg mem_wr,
    output reg halt
);
wire [4:0] opcode = instruction[15:11];
wire [2:0] rd     = instruction[10:8];
wire [2:0] rs     = instruction[7:5];
wire [2:0] sop1   = instruction[4:2];
wire [1:0] sop2   = instruction[1:0];

always @(*) begin
    alu_sel  = 5'b00000;
    op_group = 4'b0000;
    des_reg  = 3'b000;
    src_reg  = 3'b000;
    value    = 11'b0;

    reg_wr   = 1'b0;
    sreg_wr  = 1'b0;
    pc_wr    = 1'b0;
    sp_wr    = 1'b0;
    mem_rd   = 1'b0;
    mem_wr   = 1'b0;
    halt     = 1'b0;

    case (opcode)
    // =====================================================
    // Data Operation
    // =====================================================

    `ALU_INC,
    `ALU_DEC,
    `ALU_NEC:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b1;
    end

    `ALU_NOT:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b0;
    end

    // =====================================================
    // Shift / Rotate (1-bit)
    // =====================================================

    `ALU_SHL,
    `ALU_SHR,
    `ALU_ASL,
    `ALU_ASR,
    `ALU_ROL,
    `ALU_ROR:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b1;
    end

    // =====================================================
    // Shift / Rotate (#value)
    // =====================================================

    `ALU_SHL_V,
    `ALU_SHR_V,
    `ALU_ASL_V,
    `ALU_ASR_V,
    `ALU_ROL_V,
    `ALU_ROR_V:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b1;
    end

    // =====================================================
    // Logical
    // =====================================================

    `ALU_AND,
    `ALU_OR,
    `ALU_XOR,
    `ALU_NOR:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b1;
    end

    // =====================================================
    // Compare
    // =====================================================

    `ALU_CMP:
    begin
        reg_wr  = 1'b0;
        sreg_wr = 1'b1;
    end

    // =====================================================
    // Arithmetic
    // =====================================================

    `ALU_ADD,
    `ALU_ADDC,
    `ALU_ADDB,
    `ALU_ADDBC,
    `ALU_SUB,
    `ALU_SUBC,
    `ALU_SUBB,
    `ALU_SUBBC:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b1;
    end

    // =====================================================
    // MUL
    // =====================================================

    `ALU_MUL,
    `ALU_MULB:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b0;
    end

    // =====================================================
    // DIV
    // =====================================================

    `ALU_DIV,
    `ALU_DIVB:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b0;
    end

    // =====================================================
    // MOD
    // =====================================================

    `ALU_MOD,
    `ALU_MODB:
    begin
        reg_wr  = 1'b1;
        sreg_wr = 1'b0;
    end

    // =====================================================

    default: begin
        reg_wr  = 1'b0;
        sreg_wr = 1'b0;
    end

endcase

end

endmodule

