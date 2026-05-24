module alu(

input wire [15:0] l_operand,
input wire [15:0] r_operand,

input wire [5:0] alu_sel,    // 6비트 → 최대 64개 연산 (인코딩표 참조하셈)
/* 5비트로 하면 명령어 수 부족해서 6비트로 바꿈 그래서 decoder 만들 때 참고하셈 아니다 그냥 꾹 참고 하셈 */
input wire [7:0] shift_amt,  // SHL, SHR, ASL, ASR, ROL, ROR #value 용 즉값

input wire cf_in,            // ADDC, SUBC, ADDBC, SUBBC 용 Carry 입력

output reg [15:0] alu_result0,
output reg [15:0] alu_result1,

output reg zf,   // Zero flag
output reg cf,   // Carry flag
output reg nf,   // Negative(Sign) flag
output reg vf,   // Overflow flag
output reg gtf,  // Greater-Than flag (CMP 전용)
output reg ltf   // Less-Than flag    (CMP 전용)

);

// =========================================================
// alu_sel 인코딩표 (6비트, 충돌 없음, 총 35개)
// ---------------------------------------------------------
// 000000  INC        000001  DEC        000010  NEC        000011  NOT
// ---------------------------------------------------------
// 000100  SHL(1)     000101  SHR(1)     000110  ASL(1)     000111  ASR(1)
// 001000  ROL(1)     001001  ROR(1)
// ---------------------------------------------------------
// 001010  SHL_V      001011  SHR_V      001100  ASL_V      001101  ASR_V
// 001110  ROL_V      001111  ROR_V
// ---------------------------------------------------------
// 010000  AND        010001  OR         010010  XOR        010011  NOR
// ---------------------------------------------------------
// 010100  CMP
// ---------------------------------------------------------
// 010101  ADD        010110  ADDC       010111  ADDB       011000  ADDBC
// 011001  SUB        011010  SUBC       011011  SUBB       011100  SUBBC
// ---------------------------------------------------------
// 011101  MUL        011110  MULB
// 011111  DIV        100000  DIVB
// 100001  MOD        100010  MODB
// =========================================================

// 여기 다 6비트임, 전에 못 넣었던 명령어들 추가함 ㅄ
// Data operation
`define ALU_INC     6'b000000
`define ALU_DEC     6'b000001
`define ALU_NEC     6'b000010
`define ALU_NOT     6'b000011

// Shift/Rotate 1-bit
`define ALU_SHL     6'b000100
`define ALU_SHR     6'b000101
`define ALU_ASL     6'b000110
`define ALU_ASR     6'b000111
`define ALU_ROL     6'b001000
`define ALU_ROR     6'b001001

// Shift/Rotate #value
`define ALU_SHL_V   6'b001010
`define ALU_SHR_V   6'b001011
`define ALU_ASL_V   6'b001100
`define ALU_ASR_V   6'b001101
`define ALU_ROL_V   6'b001110
`define ALU_ROR_V   6'b001111

// Logical
`define ALU_AND     6'b010000
`define ALU_OR      6'b010001
`define ALU_XOR     6'b010010
`define ALU_NOR     6'b010011

// Compare
`define ALU_CMP     6'b010100

// Arithmetic (16-bit)
`define ALU_ADD     6'b010101
`define ALU_ADDC    6'b010110
`define ALU_ADDB    6'b010111
`define ALU_ADDBC   6'b011000
`define ALU_SUB     6'b011001
`define ALU_SUBC    6'b011010
`define ALU_SUBB    6'b011011
`define ALU_SUBBC   6'b011100

// MUL / DIV / MOD
`define ALU_MUL     6'b011101
`define ALU_MULB    6'b011110
`define ALU_DIV     6'b011111
`define ALU_DIVB    6'b100000
`define ALU_MOD     6'b100001
`define ALU_MODB    6'b100010

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

reg [16:0] temp;
reg [31:0] mul_temp;

reg [15:0] quotient;
reg [15:0] divisor;
reg [16:0] remainder;

integer i;

always @(*) begin

    // 기본값 초기화
    alu_result0 = 16'b0;
    alu_result1 = 16'b0;
    zf  = 1'b0;
    cf  = 1'b0;
    nf  = 1'b0;
    vf  = 1'b0;
    gtf = 1'b0;
    ltf = 1'b0;

    temp      = 17'b0;
    mul_temp  = 32'b0;
    quotient  = 16'b0;
    divisor   = 16'b0;
    remainder = 17'b0;

    case (alu_sel)

    /* 여기서부터 찐 시작 */
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // Data Operation

    // INC Rd : Rd <-- Rd + 1
    `ALU_INC: begin
        temp        = l_operand + 1;
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (~l_operand[15]) & alu_result0[15];
    end

    // DEC Rd : Rd <-- Rd - 1
    `ALU_DEC: begin
        temp        = l_operand - 1;
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = l_operand[15] & (~alu_result0[15]);
    end

    // NEC Rd : Rd <-- ~Rd + 1  (2의 보수 부정)
    `ALU_NEC: begin
        temp        = (~l_operand) + 1;
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = l_operand[15] & alu_result0[15];
    end

    // NOT Rd : Rd <-- ~Rd  (1의 보수)
    `ALU_NOT: begin
        alu_result0 = ~l_operand;
    end

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // Shift / Rotate  (1-bit)

    // SHL : logical shift left 1
    `ALU_SHL: begin
        cf          = l_operand[15];
        alu_result0 = l_operand << 1;
    end

    // SHR : logical shift right 1
    `ALU_SHR: begin
        cf          = l_operand[0];
        alu_result0 = l_operand >> 1;
    end

    // ASL : arithmetic shift left 1 (MSB→CF, vf = 부호 변화)
    `ALU_ASL: begin
        cf          = l_operand[15];
        alu_result0 = l_operand <<< 1;
        vf          = cf ^ alu_result0[15];
    end

    // ASR : arithmetic shift right 1 (부호 비트 유지)
    `ALU_ASR: begin
        cf          = l_operand[0];
        alu_result0 = $signed(l_operand) >>> 1;
    end

    // ROL : rotate left 1
    `ALU_ROL: begin
        cf          = l_operand[15];
        alu_result0 = {l_operand[14:0], l_operand[15]};
    end

    // ROR : rotate right 1
    `ALU_ROR: begin
        cf          = l_operand[0];
        alu_result0 = {l_operand[0], l_operand[15:1]};
    end

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // Shift / Rotate  (#value 즉값)

    // SHL #value
    `ALU_SHL_V: begin
        if (shift_amt == 0) begin
            alu_result0 = l_operand;
        end else begin
            cf          = l_operand[16 - shift_amt];
            alu_result0 = l_operand << shift_amt;
        end
    end

    // SHR #value
    `ALU_SHR_V: begin
        if (shift_amt == 0) begin
            alu_result0 = l_operand;
        end else begin
            cf          = l_operand[shift_amt - 1];
            alu_result0 = l_operand >> shift_amt;
        end
    end

    // ASL #value
    `ALU_ASL_V: begin
        if (shift_amt == 0) begin
            alu_result0 = l_operand;
        end else begin
            cf          = l_operand[16 - shift_amt];
            alu_result0 = l_operand <<< shift_amt;
            vf          = cf ^ alu_result0[15];
        end
    end

    // ASR #value
    `ALU_ASR_V: begin
        if (shift_amt == 0) begin
            alu_result0 = l_operand;
        end else begin
            cf          = l_operand[shift_amt - 1];
            alu_result0 = $signed(l_operand) >>> shift_amt;
        end
    end

    // ROL #value
    `ALU_ROL_V: begin
        if (shift_amt == 0) begin
            alu_result0 = l_operand;
        end else begin
            alu_result0 = (l_operand << shift_amt) | (l_operand >> (16 - shift_amt));
            cf          = l_operand[16 - shift_amt];
        end
    end

    // ROR #value
    `ALU_ROR_V: begin
        if (shift_amt == 0) begin
            alu_result0 = l_operand;
        end else begin
            alu_result0 = (l_operand >> shift_amt) | (l_operand << (16 - shift_amt));
            cf          = l_operand[shift_amt - 1];
        end
    end

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // Logical

    `ALU_AND: begin
        alu_result0 = l_operand & r_operand;
    end

    `ALU_OR: begin
        alu_result0 = l_operand | r_operand;
    end

    `ALU_XOR: begin
        alu_result0 = l_operand ^ r_operand;
    end

    `ALU_NOR: begin
        alu_result0 = ~(l_operand | r_operand);
    end

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // Compare  (writeback 없음, flags only)

    `ALU_CMP: begin
        temp        = l_operand - r_operand;
        alu_result0 = temp[15:0];
        cf  = temp[16];
        vf  = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0[15]);
        gtf = (~alu_result0[15]) & (alu_result0 != 16'b0) & (~vf);
        ltf = alu_result0[15] ^ vf;
    end

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // Arithmetic – 16-bit

    `ALU_ADD: begin
        temp        = l_operand + r_operand;
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (~(l_operand[15] ^ r_operand[15])) & (l_operand[15] ^ alu_result0[15]);
    end

    `ALU_ADDC: begin
        temp        = l_operand + r_operand + {16'b0, cf_in};
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (~(l_operand[15] ^ r_operand[15])) & (l_operand[15] ^ alu_result0[15]);
    end

    // ADDB : Rd[7:0] + Rs[7:0], 상위 바이트 유지
    `ALU_ADDB: begin
        temp        = {9'b0, l_operand[7:0]} + {9'b0, r_operand[7:0]};
        alu_result0 = {l_operand[15:8], temp[7:0]};
        cf = temp[8];
        vf = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp[7]);
    end

    // ADDBC : Rd[7:0] + Rs[7:0] + cy
    `ALU_ADDBC: begin
        temp        = {9'b0, l_operand[7:0]} + {9'b0, r_operand[7:0]} + {8'b0, cf_in};
        alu_result0 = {l_operand[15:8], temp[7:0]};
        cf = temp[8];
        vf = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp[7]);
    end

    `ALU_SUB: begin
        temp        = l_operand - r_operand;
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0[15]);
    end

    `ALU_SUBC: begin
        temp        = l_operand - r_operand - {16'b0, cf_in};
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0[15]);
    end

    // SUBB : Rd[7:0] - Rs[7:0], 상위 바이트 유지
    `ALU_SUBB: begin
        temp        = {9'b0, l_operand[7:0]} - {9'b0, r_operand[7:0]};
        alu_result0 = {l_operand[15:8], temp[7:0]};
        cf = temp[8];
        vf = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp[7]);
    end

    // SUBBC : Rd[7:0] - Rs[7:0] - cy
    `ALU_SUBBC: begin
        temp        = {9'b0, l_operand[7:0]} - {9'b0, r_operand[7:0]} - {8'b0, cf_in};
        alu_result0 = {l_operand[15:8], temp[7:0]};
        cf = temp[8];
        vf = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp[7]);
    end

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // MUL / DIV / MOD  – Shift 기반

    // MUL : {alu_result1, alu_result0} = Rd * Rs (32-bit)
    // Shift-and-Add: Rs[i]==1 이면 l_operand << i 를 누산
    `ALU_MUL: begin
        mul_temp = 32'b0;
        for (i = 0; i < 16; i = i + 1) begin
            if (r_operand[i])
                mul_temp = mul_temp + ({16'b0, l_operand} << i);
        end
        alu_result0 = mul_temp[15:0];
        alu_result1 = mul_temp[31:16];
    end

    // MULB : alu_result0 = Rd[7:0] * Rs[7:0] (16-bit)
    // Shift-and-Add: 8비트 기준
    `ALU_MULB: begin
        mul_temp = 32'b0;
        for (i = 0; i < 8; i = i + 1) begin
            if (r_operand[i])
                mul_temp = mul_temp + ({24'b0, l_operand[7:0]} << i);
        end
        alu_result0 = mul_temp[15:0];
    end

    // DIV : alu_result0 = 몫(16-bit), alu_result1 = 나머지(16-bit)
    // Shift-and-Subtract (Restoring Division)
    `ALU_DIV: begin
        quotient  = 16'b0;
        divisor   = r_operand;
        remainder = 17'b0;
        if (divisor != 0) begin
            for (i = 15; i >= 0; i = i - 1) begin
                remainder = {remainder[15:0], l_operand[i]};
                if (remainder >= {1'b0, divisor}) begin
                    remainder   = remainder - {1'b0, divisor};
                    quotient[i] = 1'b1;
                end else begin
                    quotient[i] = 1'b0;
                end
            end
            alu_result0 = quotient;
            alu_result1 = remainder[15:0];
        end else begin
            alu_result0 = 16'hFFFF;
            alu_result1 = 16'hFFFF;
        end
    end

    // DIVB : alu_result0[7:0] = 몫(8-bit), alu_result1[7:0] = 나머지
    // Shift-and-Subtract: 8비트 기준
    `ALU_DIVB: begin
        quotient  = 16'b0;
        divisor   = {8'b0, r_operand[7:0]};
        remainder = 17'b0;
        if (divisor != 0) begin
            for (i = 7; i >= 0; i = i - 1) begin
                remainder = {remainder[15:0], l_operand[i]};
                if (remainder >= {1'b0, divisor}) begin
                    remainder   = remainder - {1'b0, divisor};
                    quotient[i] = 1'b1;
                end else begin
                    quotient[i] = 1'b0;
                end
            end
            alu_result0 = {l_operand[15:8], quotient[7:0]};
            alu_result1 = {8'b0, remainder[7:0]};
        end else begin
            alu_result0 = 16'hFFFF;
            alu_result1 = 16'hFFFF;
        end
    end

    // MOD : alu_result0 = 나머지(16-bit)
    // Shift-and-Subtract (Restoring Division), 나머지만 반환
    `ALU_MOD: begin
        quotient  = 16'b0;
        divisor   = r_operand;
        remainder = 17'b0;
        if (divisor != 0) begin
            for (i = 15; i >= 0; i = i - 1) begin
                remainder = {remainder[15:0], l_operand[i]};
                if (remainder >= {1'b0, divisor}) begin
                    remainder   = remainder - {1'b0, divisor};
                    quotient[i] = 1'b1;
                end else begin
                    quotient[i] = 1'b0;
                end
            end
            alu_result0 = remainder[15:0];
        end else begin
            alu_result0 = 16'hFFFF;
        end
    end

    // MODB : alu_result0[7:0] = 나머지(8-bit), 상위 바이트 유지
    // Shift-and-Subtract: 8비트 기준
    `ALU_MODB: begin
        quotient  = 16'b0;
        divisor   = {8'b0, r_operand[7:0]};
        remainder = 17'b0;
        if (divisor != 0) begin
            for (i = 7; i >= 0; i = i - 1) begin
                remainder = {remainder[15:0], l_operand[i]};
                if (remainder >= {1'b0, divisor}) begin
                    remainder   = remainder - {1'b0, divisor};
                    quotient[i] = 1'b1;
                end else begin
                    quotient[i] = 1'b0;
                end
            end
            alu_result0 = {l_operand[15:8], remainder[7:0]};
        end else begin
            alu_result0 = 16'hFFFF;
        end
    end

    default: begin
        alu_result0 = 16'b0;
        alu_result1 = 16'b0;
    end

    endcase

    // 공통 ZF / NF 갱신 
    zf = (alu_result0 == 16'b0);
    nf = alu_result0[15];

end

endmodule