`include "1.defines/define.vh"
module alu(

input wire t3,

input wire [15:0] l_operand,
input wire [15:0] r_operand,

input wire [4:0] alu_sel,    
input wire [4:0] alu_sop,     
input wire [7:0] shift_amt,  

input wire cf_in,            

output reg [15:0] alu_result0,
output reg [15:0] alu_result1,

output reg zf,   
output reg cf,   
output reg nf,   
output reg vf,   
output reg gtf,  
output reg ltf
);

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
if(t3)begin
    case (alu_sel)
    `GRP_DATA_SHIFT: begin
        case (alu_sop)
        `DS_INC: begin
            temp        = l_operand + 1;
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = (~l_operand[15]) & alu_result0[15];
        end

        `DS_DEC: begin
            temp        = l_operand - 1;
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = l_operand[15] & (~alu_result0[15]);
        end

        `DS_NEC: begin
            temp        = (~l_operand) + 1;
            alu_result0 = temp[15:0];
            cf = temp[16];
            vf = l_operand[15] & alu_result0[15];
        end
        `DS_NOT: begin
            alu_result0 = ~l_operand;
        end

        `DS_SHL: begin
            cf          = l_operand[15];
            alu_result0 = l_operand << 1;
        end

        `DS_SHR: begin
            cf          = l_operand[0];
            alu_result0 = l_operand >> 1;
        end

        `DS_ASL: begin
            cf          = l_operand[15];
            alu_result0 = l_operand <<< 1;
            vf          = cf ^ alu_result0[15];
        end

        `DS_ASR: begin
            cf          = l_operand[0];
            alu_result0 = $signed(l_operand) >>> 1;
        end

        `DS_ROL: begin
            cf          = l_operand[15];
            alu_result0 = {l_operand[14:0], l_operand[15]};
        end

        `DS_ROR: begin
            cf          = l_operand[0];
            alu_result0 = {l_operand[0], l_operand[15:1]};
        end

        `DS_SHL_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                cf          = l_operand[16 - shift_amt];
                alu_result0 = l_operand << shift_amt;
            end
        end

        `DS_SHR_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                cf          = l_operand[shift_amt - 1];
                alu_result0 = l_operand >> shift_amt;
            end
        end

        `DS_ASL_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                cf          = l_operand[16 - shift_amt];
                alu_result0 = l_operand <<< shift_amt;
                vf          = cf ^ alu_result0[15];
            end
        end

        `DS_ASR_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                cf          = l_operand[shift_amt - 1];
                alu_result0 = $signed(l_operand) >>> shift_amt;
            end
        end

        `DS_ROL_V: begin
            if (shift_amt == 0) begin
                alu_result0 = l_operand;
            end else begin
                alu_result0 = (l_operand << shift_amt) | (l_operand >> (16 - shift_amt));
                cf          = l_operand[16 - shift_amt];
            end
        end

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

    `GRP_ARITH: begin
        case (alu_sop)
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

        `AR_ADDB: begin
            temp        = {9'b0, l_operand[7:0]} + {9'b0, r_operand[7:0]};
            alu_result0 = {l_operand[15:8], temp[7:0]};
            cf = temp[8];
            vf = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp[7]);
        end

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

        `AR_SUBB: begin
            temp        = {9'b0, l_operand[7:0]} - {9'b0, r_operand[7:0]};
            alu_result0 = {l_operand[15:8], temp[7:0]};
            cf = temp[8];
            vf = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp[7]);
        end

        `AR_SUBBC: begin
            temp        = {9'b0, l_operand[7:0]} - {9'b0, r_operand[7:0]} - {8'b0, cf_in};
            alu_result0 = {l_operand[15:8], temp[7:0]};
            cf = temp[8];
            vf = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp[7]);
        end

        `AR_MUL: begin
            mul_temp = 32'b0;
            for (i = 0; i < 16; i = i + 1) begin
                if (r_operand[i])
                    mul_temp = mul_temp + ({16'b0, l_operand} << i);
            end
            alu_result0 = mul_temp[15:0];
            alu_result1 = mul_temp[31:16];
        end

        `AR_MULB: begin
            mul_temp = 32'b0;
            for (i = 0; i < 8; i = i + 1) begin
                if (r_operand[i])
                    mul_temp = mul_temp + ({24'b0, l_operand[7:0]} << i);
            end
            alu_result0 = mul_temp[15:0];
        end

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

    `GRP_LOGIC: begin
        case (alu_sop)
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

    `GRP_CMP: begin
        temp        = l_operand - r_operand;
        alu_result0 = temp[15:0];
        gtf = (~alu_result0[15]) & (alu_result0 != 16'b0) & (~vf);
        ltf = alu_result0[15] ^ vf;
    end

    default: begin
        alu_result0 = 16'b0;
        alu_result1 = 16'b0;
    end

    endcase
end
    zf = (alu_result0 == 16'b0);
    nf = alu_result0[15];

end
endmodule