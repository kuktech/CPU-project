module instruction_decoder (
    input [15:0] instruction,
    input [7:0] status,

    output reg [3:0] op_group,
    output reg [2:0] op_kind,
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
    op_group = 4'b0000;
    op_kind  = 3'b000;
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
        // 나중에 채우기
        default: begin
        end
    endcase
end

endmodule
