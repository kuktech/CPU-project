

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
    output reg halt,

    output wire sop1,
    output wire sop2
);
wire [9:0] operation = {instruction[15:11],instruction[4:0]};
wire [2:0] rd     = instruction[10:8];
wire [2:0] rs     = instruction[7:5];


`define HALT 10'0000000001

`define LDI_value 10'0000100000
`define LDI 10'0001000000
`define STI 10'0001000001
`define MV 10'0001000100
`define EXHG 10'0001000101
`define SWAP 10'0001000110
`define PUSH 10'0001100000
`define POP 10'0001100111

`define INC 10'0010000000
`define DEC 10'0010000001
`define NEC 10'0010000010
`define NOT 10'0010000011

`define SHL 10'0010000100
`define SHR 10'0010000101
`define ASL 10'0010000110
`define ASR 10'0010000111
`define ROL 10'0010001000
`define ROR 10'0010001001
`define SHL_value 10'0010010100
`define SHR_value 10'0010010101
`define ASL_value 10'0010010110
`define ASR_value 10'0010010111
`define ROL_value 10'0010011100
`define ROR_value 10'0010011101

`define ADD 10'0010100000
`define ADDC 10'0010100001
`define ADDB 10'0010100010
`define ADDBC 10'0010100011
`define SUB 10'0010100100
`define SUBC 10'0010100101
`define SUBB 10'0010100110
`define SUBBC 10'0010100111
`define MUL 10'0010101000
`define MULB 10'0010101010
`define DIV 10'0010101100
`define DIVB 10'0010101110
`define MOD 10'0010101101
`define MODB 10'0010101111

`define AND 10'0011000000
`define OR 10'0011000001
`define XOR 10'0011000010
`define NOR 10'0011000011

`define CMP 10'0011100000

`define Bit_manipulate 5'00000

`define Subroutine_CALL 5'00000
`define Subroutine_RET 5'00000

`define Branch_BR 5'00000
`define Branch_BRR 5'00000

`define BRNZ 5'00000
`define BRZ 5'00000
`define BRNS 5'00000
`define BRS 5'00000
`define BRNC 5'00000
`define BRC 5'00000
`define BRNV 5'00000
`define BRV 5'00000
`define BRNGT 5'00000
`define BRGT 5'00000
`define BRNLT 5'00000
`define BRLT 5'00000

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

    case (operation)
        System:
        Data_transfer:
        Data_operation:
        Shift_Rotate:
        Arithmetic:
        Logical:
        Compare:
        Bit_manipulate:
        Subroutine:
        Branch:
        Cond_Branch:
        default: begin
        end
    endcase
end

endmodule
