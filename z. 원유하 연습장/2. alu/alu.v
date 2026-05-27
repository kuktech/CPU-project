module alu(

input wire [15:0] l_operand,
input wire [15:0] r_operand,

input wire [4:0] alu_sel,    // 5비트 opcode (명령어[15:11])
input wire [2:0] sop1,       // 명령어[4:2] — 그룹 내 세부 선택 상위
input wire [1:0] sop2,       // 명령어[1:0] — 그룹 내 세부 선택 하위
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
// alu_sel (5-bit) 그룹 코드  ─  명령어[15:11] 그대로 사용
// ---------------------------------------------------------
// 00100  DATA_SHIFT   Data Operation + Shift/Rotate
// 00101  ARITH        Arithmetic (ADD/SUB/MUL/DIV/MOD)
// 00110  LOGIC        Logical (AND/OR/XOR/NOR)
// 00111  CMP          Compare
// =========================================================
//
// 그룹 내 세부 선택: {sop1[2:0], sop2[1:0]}  (5-bit)
//
// ── DATA_SHIFT (alu_sel = 00100) ─────────────────────────
//  {sop1, sop2}
//  000_00  INC        000_01  DEC        000_10  NEC        000_11  NOT
//  001_00  SHL(1)     001_01  SHR(1)     001_10  ASL(1)     001_11  ASR(1)
//  010_00  ROL(1)     010_01  ROR(1)
//  101_00  SHL_V      101_01  SHR_V      101_10  ASL_V      101_11  ASR_V
//  110_00  ROL_V      110_01  ROR_V
//
// ── ARITH (alu_sel = 00101) ──────────────────────────────
//  {sop1, sop2}
//  000_00  ADD        000_01  ADDC       000_10  ADDB       000_11  ADDBC
//  001_00  SUB        001_01  SUBC       001_10  SUBB       001_11  SUBBC
//  010_00  MUL        010_10  MULB
//  011_00  DIV        011_01  MOD        011_10  DIVB       011_11  MODB
//
// ── LOGIC (alu_sel = 00110) ──────────────────────────────
//  {sop1, sop2}  ─  sop1 무시, sop2만 사용
//  xxx_00  AND        xxx_01  OR         xxx_10  XOR        xxx_11  NOR
//
// ── CMP (alu_sel = 00111) ────────────────────────────────
//  sub-op 없음
// =========================================================

// ── alu_sel 그룹 코드 ─────────────────────────────────────
`define GRP_DATA_SHIFT  5'b00100
`define GRP_ARITH       5'b00101
`define GRP_LOGIC       5'b00110
`define GRP_CMP         5'b00111

// ── DATA_SHIFT 그룹 내 {sop1, sop2} ──────────────────────
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

// ── ARITH 그룹 내 {sop1, sop2} ───────────────────────────
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

// ── LOGIC 그룹 내 sop2 (2-bit) ───────────────────────────
`define LG_AND      2'b00
`define LG_OR       2'b01
`define LG_XOR      2'b10
`define LG_NOR      2'b11

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

    // =========================================================
    // DATA_SHIFT 그룹 (opcode = 00100)
    // =========================================================
    `GRP_DATA_SHIFT: begin
        case ({sop1, sop2})

        /* 여기서부터 찐 시작 */
        // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
        // Data Operation

        // INC Rd : Rd <-- Rd + 1
        `DS_INC: begin
            temp        = l_operand + 1;
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = (~l_operand[15]) & alu_result0[15];
        end

        // DEC Rd : Rd <-- Rd - 1
        `DS_DEC: begin
            temp        = l_operand - 1;
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = l_operand[15] & (~alu_result0[15]);
        end

        // NEC Rd : Rd <-- ~Rd + 1  (2의 보수 부정)
        `DS_NEC: begin
            temp        = (~l_operand) + 1;
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = l_operand[15] & alu_result0[15];
        end

        // NOT Rd : Rd <-- ~Rd  (1의 보수)
        `DS_NOT: begin
            alu_result0 = ~l_operand;
        end

        // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
        // Shift / Rotate  (1-bit)

        // SHL : logical shift left 1
        `DS_SHL: begin
            cf          = l_operand[15];
            alu_result0 = l_operand << 1;
        end

        // SHR : logical shift right 1
        `DS_SHR: begin
            cf          = l_operand[0];
            alu_result0 = l_operand >> 1;
        end

        // ASL : arithmetic shift left 1 (MSB→CF, vf = 부호 변화)
        `DS_ASL: begin
            cf          = l_operand[15];
            alu_result0 = l_operand <<< 1;
            vf          = cf ^ alu_result0[15];
        end

        // ASR : arithmetic shift right 1 (부호 비트 유지)
        `DS_ASR: begin
            cf          = l_operand[0];
            alu_result0 = $signed(l_operand) >>> 1;
        end

        // ROL : rotate left 1
        `DS_ROL: begin
            cf          = l_operand[15];
            alu_result0 = {l_operand[14:0], l_operand[15]};
        end

        // ROR : rotate right 1
        `DS_ROR: begin
            cf          = l_operand[0];
            alu_result0 = {l_operand[0], l_operand[15:1]};
        end

        // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
        // Shift / Rotate  (#value 즉값)

        // SHL #value
        `DS_SHL_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                cf          = l_operand[16 - shift_amt];
                alu_result0 = l_operand << shift_amt;
            end
        end

        // SHR #value
        `DS_SHR_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                cf          = l_operand[shift_amt - 1];
                alu_result0 = l_operand >> shift_amt;
            end
        end

        // ASL #value
        `DS_ASL_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                cf          = l_operand[16 - shift_amt];
                alu_result0 = l_operand <<< shift_amt;
                vf          = cf ^ alu_result0[15];
            end
        end

        // ASR #value
        `DS_ASR_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                cf          = l_operand[shift_amt - 1];
                alu_result0 = $signed(l_operand) >>> shift_amt;
            end
        end

        // ROL #value
        `DS_ROL_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                alu_result0 = (l_operand << shift_amt) | (l_operand >> (16 - shift_amt));
                cf          = l_operand[16 - shift_amt];
            end
        end

        // ROR #value
        `DS_ROR_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                alu_result0 = (l_operand >> shift_amt) | (l_operand << (16 - shift_amt));
                cf          = l_operand[shift_amt - 1];
            end
        end

        default: begin
            alu_result0 = 16'b0;
            alu_result1 = 16'b0;
        end

        endcase
    end

    // =========================================================
    // ARITH 그룹 (opcode = 00101)
    // =========================================================
    `GRP_ARITH: begin
        case ({sop1, sop2})

        // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
        // Arithmetic – 16-bit

        `AR_ADD: begin
            temp        = l_operand + r_operand;
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = (~(l_operand[15] ^ r_operand[15])) & (l_operand[15] ^ alu_result0[15]);
        end

        `AR_ADDC: begin
            temp        = l_operand + r_operand + {16'b0, cf_in};
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = (~(l_operand[15] ^ r_operand[15])) & (l_operand[15] ^ alu_result0[15]);
        end

        // ADDB : Rd[7:0] + Rs[7:0], 상위 바이트 유지
        `AR_ADDB: begin
            temp        = {9'b0, l_operand[7:0]} + {9'b0, r_operand[7:0]};
            alu_result0 = {l_operand[15:8], temp[7:0]};
            cf = temp[8];
            vf = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp[7]);
        end

        // ADDBC : Rd[7:0] + Rs[7:0] + cy
        `AR_ADDBC: begin
            temp        = {9'b0, l_operand[7:0]} + {9'b0, r_operand[7:0]} + {8'b0, cf_in};
            alu_result0 = {l_operand[15:8], temp[7:0]};
            cf = temp[8];
            vf = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp[7]);
        end

        `AR_SUB: begin
            temp        = l_operand - r_operand;
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0[15]);
        end

        `AR_SUBC: begin
            temp        = l_operand - r_operand - {16'b0, cf_in};
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0[15]);
        end

        // SUBB : Rd[7:0] - Rs[7:0], 상위 바이트 유지
        `AR_SUBB: begin
            temp        = {9'b0, l_operand[7:0]} - {9'b0, r_operand[7:0]};
            alu_result0 = {l_operand[15:8], temp[7:0]};
            cf = temp[8];
            vf = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp[7]);
        end

        // SUBBC : Rd[7:0] - Rs[7:0] - cy
        `AR_SUBBC: begin
            temp        = {9'b0, l_operand[7:0]} - {9'b0, r_operand[7:0]} - {8'b0, cf_in};
            alu_result0 = {l_operand[15:8], temp[7:0]};
            cf = temp[8];
            vf = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp[7]);
        end

        // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
        // MUL / DIV / MOD  – Shift 기반

        // MUL : {alu_result1, alu_result0} = Rd * Rs (32-bit)
        // Shift-and-Add: Rs[i]==1 이면 l_operand << i 를 누산
        `AR_MUL: begin
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
        `AR_MULB: begin
            mul_temp = 32'b0;
            for (i = 0; i < 8; i = i + 1) begin
                if (r_operand[i])
                    mul_temp = mul_temp + ({24'b0, l_operand[7:0]} << i);
            end
            alu_result0 = mul_temp[15:0];
        end

        // DIV : alu_result0 = 몫(16-bit), alu_result1 = 나머지(16-bit)
        // Shift-and-Subtract (Restoring Division)
        `AR_DIV: begin
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
        `AR_DIVB: begin
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
        `AR_MOD: begin
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
        `AR_MODB: begin
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
    end

    // =========================================================
    // LOGIC 그룹 (opcode = 00110)
    // sop1 무시, sop2만으로 구분
    // =========================================================
    `GRP_LOGIC: begin
        case (sop2)

        // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
        // Logical

        `LG_AND: begin
            alu_result0 = l_operand & r_operand;
        end

        `LG_OR: begin
            alu_result0 = l_operand | r_operand;
        end

        `LG_XOR: begin
            alu_result0 = l_operand ^ r_operand;
        end

        `LG_NOR: begin
            alu_result0 = ~(l_operand | r_operand);
        end

        default: begin
            alu_result0 = 16'b0;
        end

        endcase
    end

    // =========================================================
    // CMP 그룹 (opcode = 00111)
    // =========================================================
    `GRP_CMP: begin

        // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
        // Compare  (writeback 없음, flags only)

        temp        = l_operand - r_operand;
        alu_result0 = temp[15:0];
        cf  = temp[16];
        vf  = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0[15]);
        gtf = (~alu_result0[15]) & (alu_result0 != 16'b0) & (~vf);
        ltf = alu_result0[15] ^ vf;
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