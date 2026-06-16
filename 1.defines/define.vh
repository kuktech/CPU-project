`define HALT 10'b0000000001

`define LD 10'b0001000000
`define ST 10'b0001000001
`define POP 10'b0001000010
`define PUSH 10'b0001000011
`define LDIL 5'b00001
`define LDIH 5'b00011
`define MV 10'b0001000100
`define MVSP 10'b0001000101
`define SWAP 10'b0001000110
`define EXHG 10'b0001000111

`define INC 10'b0010000000
`define DEC 10'b0010000001
`define NEC 10'b0010000010
`define NOT 10'b0010000011

`define SHL 10'b0010000100
`define SHR 10'b0010000101
`define ASL 10'b0010000110
`define ASR 10'b0010000111
`define ROL 10'b0010001000
`define ROR 10'b0010001001
`define SHL_Value 10'b0010010100
`define SHR_Value 10'b0010010101
`define ASL_Value 10'b0010010110
`define ASR_Value 10'b0010010111
`define ROL_Value 10'b0010011000
`define ROR_Value 10'b0010011001

`define ADD 10'b0010100000
`define ADDC 10'b0010100001
`define ADDB 10'b0010100010
`define ADDBC 10'b0010100011
`define SUB 10'b0010100100
`define SUBC 10'b0010100101
`define SUBB 10'b0010100110
`define SUBBC 10'b0010100111
`define MUL 10'b0010101000
`define MULHB 10'b0010101011
`define MULLB 10'b0010101010
`define DIV 10'b0010101100
`define DIVB 10'b0010101110
`define MOD 10'b0010101101
`define MODB 10'b0010101111

`define AND 10'b0011000000
`define OR 10'b0011000001
`define XOR 10'b0011000010
`define NOR 10'b0011000011

`define CMP 10'b0011100000

`define CLR_SR 7'b0100000    
`define CLR_RD 7'b0100001
`define SET_SR 7'b0100010
`define SET_RD 7'b0100011

`define CALL 5'b01100
`define RET 10'b0110100000

`define BR 5'b01110
`define BRR 5'b01111

`define BRNZ 5'b10000
`define BRZ 5'b10001
`define BRNS 5'b10010
`define BRS 5'b10011
`define BRNC 5'b10100
`define BRC 5'b10101
`define BRNV 5'b10110
`define BRV 5'b10111
`define BRNGT 5'b11000
`define BRGT 5'b11001
`define BRNLT 5'b11010
`define BRLT 5'b11011


`define GRP_DATA_SHIFT  5'b00100
`define GRP_ARITH       5'b00101
`define GRP_LOGIC       5'b00110
`define GRP_CMP         5'b00111

`define DS_INC      5'b000_00
`define DS_DEC      5'b000_01
`define DS_NEC      5'b000_10
`define DS_NOT      5'b000_11

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

`define AR_ADD      5'b000_00
`define AR_ADDC     5'b000_01
`define AR_ADDB     5'b000_10
`define AR_ADDBC    5'b000_11
`define AR_SUB      5'b001_00
`define AR_SUBC     5'b001_01
`define AR_SUBB     5'b001_10
`define AR_SUBBC    5'b001_11
`define AR_MUL      5'b010_00
`define AR_MULHB    5'b010_11
`define AR_MULLB    5'b010_10
`define AR_DIV      5'b011_00
`define AR_MOD      5'b011_01
`define AR_DIVB     5'b011_10
`define AR_MODB     5'b011_11

`define LG_AND      5'b000_00
`define LG_OR       5'b000_01
`define LG_XOR      5'b000_10
`define LG_NOR      5'b000_11

`define SR_CF  3'b000
`define SR_ZF  3'b001
`define SR_NF  3'b010
`define SR_VF  3'b011
`define SR_SF  3'b100
`define SR_HF  3'b101
`define SR_LTF 3'b110
`define SR_GTF 3'b111