module alu(

input wire [15:0] l_operand,
input wire [15:0] r_operand,

input wire [4:0] alu_sel,

input wire cf_in,   // ADDC, SUBC용 Carry 입력

output reg [15:0] alu_result0,
output reg [15:0] alu_result1,

output reg zf,
output reg cf,
output reg nf,
output reg vf

);

reg [16:0] temp;

reg [15:0] quotient;
reg [15:0] divisor;
reg [16:0] remainder;

integer i;

always @(*) begin

    alu_result0 = 16'b0;
    alu_result1 = 16'b0;

    zf = 1'b0;
    cf = 1'b0;
    nf = 1'b0;
    vf = 1'b0;

    temp = 17'b0;

    quotient  = 16'b0;
    divisor   = 16'b0;
    remainder = 17'b0;

    case(alu_sel)


    // ADD
    5'b00000: begin

        temp = l_operand + r_operand;

        alu_result0 = temp[15:0];

        cf = temp[16];

        vf = (~(l_operand[15] ^ r_operand[15])) &
             (l_operand[15] ^ alu_result0[15]);

    end

    // ADDC
    5'b00001: begin

        temp = l_operand + r_operand + cf_in;

        alu_result0 = temp[15:0];

        cf = temp[16];

        vf = (~(l_operand[15] ^ r_operand[15])) &
             (l_operand[15] ^ alu_result0[15]);

    end

    // SUB
    5'b00010: begin

        temp = l_operand - r_operand;

        alu_result0 = temp[15:0];

        cf = temp[16];

        vf = ((l_operand[15] ^ r_operand[15])) &
             (l_operand[15] ^ alu_result0[15]);

    end

    // SUBC
    5'b00011: begin

        temp = l_operand - r_operand - cf_in;

        alu_result0 = temp[15:0];

        cf = temp[16];

        vf = ((l_operand[15] ^ r_operand[15])) &
             (l_operand[15] ^ alu_result0[15]);

    end

    // MUL
    5'b00100: begin

        alu_result0 = 16'b0;
        alu_result1 = 16'b0;

        for(i=0; i<16; i=i+1) begin

            if(r_operand[i]) begin

                {alu_result1, alu_result0}
                    =
                {alu_result1, alu_result0}
                    +
                ({16'b0, l_operand} << i);

            end
        end

    end

    // DIV
    5'b00101: begin

        quotient  = 16'b0;
        divisor   = r_operand;
        remainder = 17'b0;

        if(divisor != 0) begin

            for(i=15; i>=0; i=i-1) begin

                remainder =
                {remainder[15:0], l_operand[i]};

                if(remainder >= {1'b0, divisor}) begin

                    remainder =
                    remainder - {1'b0, divisor};

                    quotient[i] = 1'b1;

                end

                else begin

                    quotient[i] = 1'b0;

                end
            end

            alu_result0 = quotient;
            alu_result1 = remainder[15:0];

        end

        else begin

            alu_result0 = 16'hFFFF;
            alu_result1 = 16'hFFFF;

        end

    end

    // MOD
    5'b00110: begin

        quotient  = 16'b0;
        divisor   = r_operand;
        remainder = 17'b0;

        if(divisor != 0) begin

            for(i=15; i>=0; i=i-1) begin

                remainder =
                {remainder[15:0], l_operand[i]};

                if(remainder >= {1'b0, divisor}) begin

                    remainder =
                    remainder - {1'b0, divisor};

                    quotient[i] = 1'b1;

                end

                else begin

                    quotient[i] = 1'b0;

                end
            end

            alu_result0 = remainder[15:0];

        end

        else begin

            alu_result0 = 16'hFFFF;

        end

    end

    // CMP
    // 결과 저장 없이 Flag만 갱신
    5'b00111: begin

        temp = l_operand - r_operand;

        alu_result0 = temp[15:0];

        cf = temp[16];

        vf = ((l_operand[15] ^ r_operand[15])) &
             (l_operand[15] ^ alu_result0[15]);

    end


    // AND
    5'b01000: begin

        alu_result0 = l_operand & r_operand;

    end

    // OR
    5'b01001: begin

        alu_result0 = l_operand | r_operand;

    end

    // XOR
    5'b01010: begin

        alu_result0 = l_operand ^ r_operand;

    end

    // NOT
    5'b01011: begin

        alu_result0 = ~l_operand;

    end


    // SHL
    5'b01100: begin

        alu_result0 = l_operand << 1;

        cf = l_operand[15];

    end

    // SHR
    5'b01101: begin

        alu_result0 = l_operand >> 1;

        cf = l_operand[0];

    end


    default: begin

        alu_result0 = 16'b0;
        alu_result1 = 16'b0;

    end

    endcase


    zf = (alu_result0 == 16'b0);

   
    nf = alu_result0[15];

end

endmodule


/*module alu(

    input wire [15:0] l_operand,
    input wire [15:0] r_operand,

    input wire [5:0]  alu_sel,   // [수정] 4'b → 6'b 확장 (연산 수 증가)
    input wire        cf_in,     // [추가] ADDC / SUBC 계열 carry 입력
    input wire        exe_32,

    output reg [15:0] alu_result0,
    output reg [15:0] alu_result1,

    output reg zf,
    output reg cf,
    output reg nf,
    output reg vf

);

// ─────────────────────────────────────────────────
// alu_sel 인코딩 상수
// ─────────────────────────────────────────────────
// Arithmetic (16-bit)
localparam ADD    = 6'd0;
localparam ADDC   = 6'd1;   // [추가]
localparam ADDB   = 6'd2;   // [추가] byte
localparam ADDBC  = 6'd3;   // [추가] byte + carry
localparam SUB    = 6'd4;
localparam SUBC   = 6'd5;   // [추가]
localparam SUBB   = 6'd6;   // [추가] byte
localparam SUBBC  = 6'd7;   // [추가] byte - carry
// Mul / Div / Mod
localparam MUL    = 6'd8;
localparam MULB   = 6'd9;   // [추가] byte
localparam DIV    = 6'd10;
localparam DIVB   = 6'd11;  // [추가] byte
localparam MOD    = 6'd12;
localparam MODB   = 6'd13;  // [추가] byte
// Unary
localparam INC    = 6'd14;  // [추가]
localparam DEC    = 6'd15;  // [추가]
localparam NEC    = 6'd16;  // [추가] 2의 보수 부정
localparam NOT_OP = 6'd17;
// Logical
localparam AND_OP = 6'd18;
localparam OR_OP  = 6'd19;
localparam XOR_OP = 6'd20;
localparam NOR_OP = 6'd21;  // [추가]
// Compare
localparam CMP    = 6'd22;  // [추가] 플래그만 갱신
// Shift / Rotate (by 1)
localparam SHL    = 6'd23;
localparam SHR    = 6'd24;
localparam ASL    = 6'd25;  // [추가] 산술 좌시프트
localparam ASR    = 6'd26;  // [추가] 산술 우시프트
localparam ROL    = 6'd27;  // [추가] 좌회전
localparam ROR    = 6'd28;  // [추가] 우회전
// Shift / Rotate (by #value, r_operand[3:0] 사용)
localparam SHL_N  = 6'd29;  // [추가]
localparam SHR_N  = 6'd30;  // [추가]
localparam ASL_N  = 6'd31;  // [추가]
localparam ASR_N  = 6'd32;  // [추가]
localparam ROL_N  = 6'd33;  // [추가]
localparam ROR_N  = 6'd34;  // [추가]

// ─────────────────────────────────────────────────
// 내부 변수
// ─────────────────────────────────────────────────
reg [16:0] temp;
reg [8:0]  temp_b;

reg [15:0] quotient;
reg [15:0] divisor;
reg [16:0] remainder;

reg [7:0]  quotient_b;   // [추가] byte 나눗셈용
reg [7:0]  divisor_b;
reg [8:0]  remainder_b;

reg [3:0]  shamt;        // [추가] shift amount

integer i;

always @(*) begin

    alu_result0 = 16'b0;
    alu_result1 = 16'b0;
    zf          = 1'b0;
    cf          = 1'b0;
    nf          = 1'b0;
    vf          = 1'b0;
    temp        = 17'b0;
    temp_b      = 9'b0;
    quotient    = 16'b0;
    divisor     = 16'b0;
    remainder   = 17'b0;
    quotient_b  = 8'b0;
    divisor_b   = 8'b0;
    remainder_b = 9'b0;
    shamt       = 4'b0;

    case(alu_sel)

    // ─────────────────────────────────────────────
    // ADD 계열
    // ─────────────────────────────────────────────
    ADD: begin
        temp        = {1'b0, l_operand} + {1'b0, r_operand};
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (~(l_operand[15] ^ r_operand[15])) & (l_operand[15] ^ alu_result0[15]);
    end

    ADDC: begin  // Rd + Rs + carry_in
        temp        = {1'b0, l_operand} + {1'b0, r_operand} + {16'b0, cf_in};
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (~(l_operand[15] ^ r_operand[15])) & (l_operand[15] ^ alu_result0[15]);
    end

    ADDB: begin  // Rd[7:0] + Rs[7:0], 상위 바이트 보존
        temp_b      = {1'b0, l_operand[7:0]} + {1'b0, r_operand[7:0]};
        alu_result0 = {l_operand[15:8], temp_b[7:0]};
        cf = temp_b[8];
        vf = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp_b[7]);
    end

    ADDBC: begin  // Rd[7:0] + Rs[7:0] + carry_in
        temp_b      = {1'b0, l_operand[7:0]} + {1'b0, r_operand[7:0]} + {8'b0, cf_in};
        alu_result0 = {l_operand[15:8], temp_b[7:0]};
        cf = temp_b[8];
        vf = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp_b[7]);
    end

    // ─────────────────────────────────────────────
    // SUB 계열
    // ─────────────────────────────────────────────
    SUB: begin
        temp        = {1'b0, l_operand} - {1'b0, r_operand};
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0[15]);
    end

    SUBC: begin  // Rd - Rs - carry_in
        temp        = {1'b0, l_operand} - {1'b0, r_operand} - {16'b0, cf_in};
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0[15]);
    end

    SUBB: begin  // Rd[7:0] - Rs[7:0], 상위 바이트 보존
        temp_b      = {1'b0, l_operand[7:0]} - {1'b0, r_operand[7:0]};
        alu_result0 = {l_operand[15:8], temp_b[7:0]};
        cf = temp_b[8];
        vf = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp_b[7]);
    end

    SUBBC: begin  // Rd[7:0] - Rs[7:0] - carry_in
        temp_b      = {1'b0, l_operand[7:0]} - {1'b0, r_operand[7:0]} - {8'b0, cf_in};
        alu_result0 = {l_operand[15:8], temp_b[7:0]};
        cf = temp_b[8];
        vf = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp_b[7]);
    end

    // ─────────────────────────────────────────────
    // MUL / MULB  (부호 없는 곱셈 - 의도된 설계)
    // ─────────────────────────────────────────────
    MUL: begin  // [수정] {16'b0, l_operand} << i 로 비트 폭 명시
        alu_result0 = 16'b0;
        alu_result1 = 16'b0;
        for(i = 0; i < 16; i = i + 1) begin
            if(r_operand[i]) begin
                {alu_result1, alu_result0} =
                    {alu_result1, alu_result0} + ({16'b0, l_operand} << i);
            end
        end
    end

    MULB: begin  // 8×8 → 16, 결과는 alu_result0
        alu_result0 = 16'b0;
        for(i = 0; i < 8; i = i + 1) begin
            if(r_operand[i]) begin
                alu_result0 = alu_result0 + ({8'b0, l_operand[7:0]} << i);
            end
        end
    end

    // ─────────────────────────────────────────────
    // DIV / DIVB  (부호 없는 나눗셈 - 의도된 설계)
    // ─────────────────────────────────────────────
    DIV: begin  // [수정] remainder 비교 명시: {1'b0, divisor}
        quotient  = 16'b0;
        divisor   = r_operand;
        remainder = 17'b0;
        if(divisor != 16'b0) begin
            for(i = 15; i >= 0; i = i - 1) begin
                remainder = {remainder[15:0], l_operand[i]};
                if(remainder >= {1'b0, divisor}) begin
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

    DIVB: begin  // 8÷8, 몫 → alu_result0[7:0], 나머지 → alu_result1[7:0]
        quotient_b  = 8'b0;
        divisor_b   = r_operand[7:0];
        remainder_b = 9'b0;
        if(divisor_b != 8'b0) begin
            for(i = 7; i >= 0; i = i - 1) begin
                remainder_b = {remainder_b[7:0], l_operand[i]};
                if(remainder_b >= {1'b0, divisor_b}) begin
                    remainder_b  = remainder_b - {1'b0, divisor_b};
                    quotient_b[i] = 1'b1;
                end else begin
                    quotient_b[i] = 1'b0;
                end
            end
            alu_result0 = {8'b0, quotient_b};
            alu_result1 = {8'b0, remainder_b[7:0]};
        end else begin
            alu_result0 = 16'hFFFF;
            alu_result1 = 16'hFFFF;
        end
    end

    // ─────────────────────────────────────────────
    // MOD / MODB
    // ─────────────────────────────────────────────
    MOD: begin
        quotient  = 16'b0;
        divisor   = r_operand;
        remainder = 17'b0;
        if(divisor != 16'b0) begin
            for(i = 15; i >= 0; i = i - 1) begin
                remainder = {remainder[15:0], l_operand[i]};
                if(remainder >= {1'b0, divisor}) begin
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

    MODB: begin
        quotient_b  = 8'b0;
        divisor_b   = r_operand[7:0];
        remainder_b = 9'b0;
        if(divisor_b != 8'b0) begin
            for(i = 7; i >= 0; i = i - 1) begin
                remainder_b = {remainder_b[7:0], l_operand[i]};
                if(remainder_b >= {1'b0, divisor_b}) begin
                    remainder_b  = remainder_b - {1'b0, divisor_b};
                    quotient_b[i] = 1'b1;
                end else begin
                    quotient_b[i] = 1'b0;
                end
            end
            alu_result0 = {8'b0, remainder_b[7:0]};
        end else begin
            alu_result0 = 16'hFFFF;
        end
    end

    // ─────────────────────────────────────────────
    // INC / DEC / NEC / NOT
    // ─────────────────────────────────────────────
    INC: begin
        temp        = {1'b0, l_operand} + 17'd1;
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (~l_operand[15]) & alu_result0[15];  // 양수 → 음수 overflow
    end

    DEC: begin
        temp        = {1'b0, l_operand} - 17'd1;
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = l_operand[15] & (~alu_result0[15]);  // 음수 → 양수 overflow
    end

    NEC: begin  // 2의 보수 부정: ~l_operand + 1
        temp        = {1'b0, ~l_operand} + 17'd1;
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (l_operand == 16'h8000);  // 0x8000 부정 시 overflow
    end

    NOT_OP: begin
        alu_result0 = ~l_operand;
    end

    // ─────────────────────────────────────────────
    // AND / OR / XOR / NOR
    // ─────────────────────────────────────────────
    AND_OP: alu_result0 = l_operand & r_operand;
    OR_OP:  alu_result0 = l_operand | r_operand;
    XOR_OP: alu_result0 = l_operand ^ r_operand;
    NOR_OP: alu_result0 = ~(l_operand | r_operand);

    // ─────────────────────────────────────────────
    // CMP  (플래그만 갱신 → 디코더에서 reg_wr_en=0 처리)
    // ─────────────────────────────────────────────
    CMP: begin
        temp        = {1'b0, l_operand} - {1'b0, r_operand};
        alu_result0 = temp[15:0];
        cf = temp[16];
        vf = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ temp[15]);
    end

    // ─────────────────────────────────────────────
    // Shift / Rotate  (by 1)
    // ─────────────────────────────────────────────
    SHL: begin  // 논리 좌시프트
        alu_result0 = l_operand << 1;
        cf = l_operand[15];
    end

    SHR: begin  // 논리 우시프트
        alu_result0 = l_operand >> 1;
        cf = l_operand[0];
    end

    ASL: begin  // 산술 좌시프트 (부호 변화 → vf)
        alu_result0 = l_operand << 1;
        cf = l_operand[15];
        vf = l_operand[15] ^ l_operand[14];
    end

    ASR: begin  // 산술 우시프트 (부호 비트 유지)
        alu_result0 = {l_operand[15], l_operand[15:1]};
        cf = l_operand[0];
    end

    ROL: begin  // 좌회전
        alu_result0 = {l_operand[14:0], l_operand[15]};
        cf = l_operand[15];
    end

    ROR: begin  // 우회전
        alu_result0 = {l_operand[0], l_operand[15:1]};
        cf = l_operand[0];
    end

    // ─────────────────────────────────────────────
    // Shift / Rotate  (by #value, r_operand[3:0])
    // cf = 시프트 시 마지막으로 밀려난 비트
    // ─────────────────────────────────────────────
    SHL_N: begin
        shamt = r_operand[3:0];
        if(shamt == 4'b0) begin
            alu_result0 = l_operand;
        end else begin
            alu_result0    = l_operand << shamt;
            cf = l_operand[16 - shamt];  // 마지막으로 밀려난 비트
        end
    end

    SHR_N: begin
        shamt = r_operand[3:0];
        if(shamt == 4'b0) begin
            alu_result0 = l_operand;
        end else begin
            alu_result0 = l_operand >> shamt;
            cf = l_operand[shamt - 1];
        end
    end

    ASL_N: begin
        shamt = r_operand[3:0];
        if(shamt == 4'b0) begin
            alu_result0 = l_operand;
        end else begin
            alu_result0 = l_operand << shamt;
            cf = l_operand[16 - shamt];
            vf = l_operand[15] ^ alu_result0[15];  // 부호 변화
        end
    end

    ASR_N: begin
        shamt = r_operand[3:0];
        if(shamt == 4'b0) begin
            alu_result0 = l_operand;
        end else begin
            alu_result0 = $signed(l_operand) >>> shamt;  // 부호 비트 유지
            cf = l_operand[shamt - 1];
        end
    end

    ROL_N: begin
        shamt = r_operand[3:0];
        if(shamt == 4'b0) begin
            alu_result0 = l_operand;
        end else begin
            alu_result0 = (l_operand << shamt) | (l_operand >> (16 - shamt));
            cf = l_operand[16 - shamt];
        end
    end

    ROR_N: begin
        shamt = r_operand[3:0];
        if(shamt == 4'b0) begin
            alu_result0 = l_operand;
        end else begin
            alu_result0 = (l_operand >> shamt) | (l_operand << (16 - shamt));
            cf = l_operand[shamt - 1];
        end
    end

    default: begin
        alu_result0 = 16'b0;
        alu_result1 = 16'b0;
    end

    endcase

    // ─────────────────────────────────────────────
    // 공통 플래그 (case 이후 항상 갱신)
    // ─────────────────────────────────────────────
    zf = (alu_result0 == 16'b0);
    nf = alu_result0[15];

end

endmodule*/