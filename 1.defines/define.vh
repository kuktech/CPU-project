`define HALT 10'b0000000001

`define LDI_Value 10'b0000100000
`define LDI 10'b0001000000
`define STI 10'b0001000001
`define MV 10'b0001000100
`define EXHG 10'b0001000101
`define SWAP 10'b0001000110
`define PUSH 10'b0001100000
`define POP 10'b0001100111

`define INC 10'b0010000000
`define DEC 10'b0010000001
`define NEC 10'b010000010
`define NOT 10'b0010000011

`define SHL 10'b0010000100
`define SHR 10'b0010000101
`define ASL 10'b0010000110
`define ASR 10'b0010000111
`define ROL 10'b0010001000
`define ROR 10'b0010001001
`define SHL_value 10'b0010010100
`define SHR_value 10'b0010010101
`define ASL_value 10'b0010010110
`define ASR_value 10'b0010010111
`define ROL_value 10'b0010011100
`define ROR_value 10'b0010011101

`define ADD 10'b0010100000
`define ADDC 10'b0010100001
`define ADDB 10'b0010100010
`define ADDBC 10'b0010100011
`define SUB 10'b0010100100
`define SUBC 10'b0010100101
`define SUBB 10'b0010100110
`define SUBBC 10'b0010100111
`define MUL 10'b0010101000
`define MULB 10'b0010101010
`define DIV 10'b0010101100
`define DIVB 10'b0010101110
`define MOD 10'b0010101101
`define MODB 10'b0010101111

`define AND 10'b0011000000
`define OR 10'b0011000001
`define XOR 10'b0011000010
`define NOR 10'b0011000011

`define CMP 10'b0011100000

`define Bit_manipulate 5'b01000

`define CALL 10'b0110000000
`define RET 10'b0110100000

`define BR 10'b0111000000
`define BRR 10'b0110100000

`define BRNZ 10'b0111000000
`define BRZ 10'b0111100000
`define BRNS 10'b1000000000
`define BRS 10'b1000100000
`define BRNC 10'b1001000000
`define BRC 10'b1001100000
`define BRNV 10'b1011000000
`define BRV 10'b1011100000
`define BRNGT 10'b1100000000
`define BRGT 10'b1100100000
`define BRNLT 10'b1101000000
`define BRLT 10'b1101100000


// ── alu_sel 그룹 코드 ─────────────────────────────────────
`define GRP_DATA_SHIFT  5'b00100
`define GRP_ARITH       5'b00101
`define GRP_LOGIC       5'b00110
`define GRP_CMP         5'b00111

// ── DATA 그룹 내 {sop} ──────────────────────
`define DS_INC      5'b000_00
`define DS_DEC      5'b000_01
`define DS_NEC      5'b000_10
`define DS_NOT      5'b000_11

// ── SHIFT & Rotate 그룹 내 {sop} ──────────────────────
`define DS_SHL      5'b001_00
`define DS_SHR      5'b001_01
`define DS_ASL      5'b001_10
`define DS_ASR      5'b001_11
`define DS_ROL      5'b010_00
`define DS_ROR      5'b010_01
`define DS_SHL_V    5'b101_00
`define DS_SHR_V    5'b101_01
`define DS_ASL_V    5'b101_10
`define DS_ASR_V    5'b101_11
`define DS_ROL_V    5'b110_00
`define DS_ROR_V    5'b110_01

// ── ARITH 그룹 내 {sop} ───────────────────────────
`define AR_ADD      5'b000_00
`define AR_ADDC     5'b000_01
`define AR_ADDB     5'b000_10
`define AR_ADDBC    5'b000_11
`define AR_SUB      5'b001_00
`define AR_SUBC     5'b001_01
`define AR_SUBB     5'b001_10
`define AR_SUBBC    5'b001_11
`define AR_MUL      5'b010_00
`define AR_MULB     5'b010_10
`define AR_DIV      5'b011_00
`define AR_MOD      5'b011_01
`define AR_DIVB     5'b011_10
`define AR_MODB     5'b011_11

// ── LOGIC 그룹 내 sop2 (2-bit)지만 sop을 합쳤기에 sop1 무시하고 5비트로 바꿈 ───────────────────────────
`define LG_AND      5'b000_00
`define LG_OR       5'b000_01
`define LG_XOR      5'b000_10
`define LG_NOR      5'b000_11