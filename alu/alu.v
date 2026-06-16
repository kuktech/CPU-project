`include "1.defines/define.vh"
module alu(
input wire clock,
input wire resetb,
input wire t3,

input wire [15:0] l_operand,
input wire [15:0] r_operand,

input wire [4:0] alu_sel,    
input wire [4:0] alu_sop,     
input wire [2:0] shift_amt,  

input wire alu_cf_in,            

output reg [15:0] alu_result0,
output reg [15:0] alu_result1,

output reg alu_cf,
output reg alu_zf,
output reg alu_nf,   
output reg alu_vf,
output reg alu_sf,
output reg alu_hf, 
output reg alu_gtf,  
output reg alu_ltf
);

reg [16:0] temp;
reg [31:0] mul_temp;

reg [15:0] quotient;
reg [15:0] divisor;
reg [16:0] remainder;

reg [15:0] alu_result0_dec;
reg [15:0] alu_result1_dec;

reg alu_cf_dec;
reg alu_zf_dec;
reg alu_nf_dec;  
reg alu_vf_dec;
reg alu_sf_dec;
reg alu_hf_dec;
reg alu_gtf_dec;  
reg alu_ltf_dec;

integer i;

always @(*) begin
    alu_result0_dec = 16'b0;
    alu_result1_dec = 16'b0;

    alu_cf_dec  = 1'b0;
    alu_zf_dec  = 1'b0;
    alu_nf_dec  = 1'b0;
    alu_vf_dec  = 1'b0;
    alu_sf_dec  = 1'b0;
    alu_hf_dec  = 1'b0;
    alu_gtf_dec = 1'b0;
    alu_ltf_dec = 1'b0;

    temp      = 17'b0;
    mul_temp  = 32'b0;
    quotient  = 16'b0;
    divisor   = 16'b0;
    remainder = 17'b0;


    case (alu_sel)
    `GRP_DATA_SHIFT: begin
        case (alu_sop)

        `DS_INC: begin
            temp        = l_operand + 1;
            alu_result0_dec = temp[15:0];
            alu_cf_dec = temp[16];
            alu_hf_dec = (l_operand[3:0] == 4'hF);       
            alu_vf_dec = (~l_operand[15]) & alu_result0_dec[15];
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_sf_dec = 1'b0;
        end

        `DS_DEC: begin
            temp        = l_operand - 1;
            alu_result0_dec = temp[15:0];
            alu_hf_dec = (l_operand[3:0] == 4'h0);       
            alu_vf_dec = l_operand[15] & (~alu_result0_dec[15]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
            alu_sf_dec = 1'b0;
        end

        `DS_NEC: begin
            temp        = (~l_operand) + 1;
            alu_result0_dec = temp[15:0];
            alu_nf_dec = alu_result0_dec[15];
            alu_sf_dec = alu_nf_dec;                        
        end

        `DS_NOT: begin
            alu_result0_dec = ~l_operand;
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_sf_dec = alu_nf_dec;                          
        end

        `DS_SHL: begin
            alu_cf_dec      = l_operand[15];
            alu_result0_dec = l_operand << 1;
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_SHR: begin
            alu_cf_dec      = l_operand[0];
            alu_result0_dec = l_operand >> 1;
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_ASL: begin
            alu_cf_dec      = l_operand[15];
            alu_result0_dec = l_operand <<< 1;
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_ASR: begin
            alu_cf_dec      = l_operand[0];
            alu_result0_dec = $signed(l_operand) >>> 1;
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_ROL: begin
            alu_cf_dec      = l_operand[15];
            alu_result0_dec = {l_operand[14:0], l_operand[15]};
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_ROR: begin
            alu_cf_dec      = l_operand[0];
            alu_result0_dec = {l_operand[0], l_operand[15:1]};
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_SHL_V: begin
            if (shift_amt == 0) begin
                alu_result0_dec = l_operand;
            end else begin
                alu_cf_dec      = l_operand[16 - shift_amt];
                alu_result0_dec = l_operand << shift_amt;
            end
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_SHR_V: begin
            if (shift_amt == 0) begin
                alu_result0_dec = l_operand;
            end else begin
                alu_cf_dec      = l_operand[shift_amt - 1];
                alu_result0_dec = l_operand >> shift_amt;
            end
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_ASL_V: begin
            if (shift_amt == 0) begin
                alu_result0_dec = l_operand;
            end else begin
                alu_cf_dec      = l_operand[16 - shift_amt];
                alu_result0_dec = l_operand <<< shift_amt;
            end
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_ASR_V: begin
            if (shift_amt == 0) begin
                alu_result0_dec = l_operand;
            end else begin
                alu_cf_dec      = l_operand[shift_amt - 1];
                alu_result0_dec = $signed(l_operand) >>> shift_amt;
            end
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_ROL_V: begin
            if (shift_amt == 0) begin
                alu_result0_dec = l_operand;
            end else begin
                alu_result0_dec = (l_operand << shift_amt) | (l_operand >> (16 - shift_amt));
                alu_cf_dec      = l_operand[16 - shift_amt];
            end
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        `DS_ROR_V: begin
            if (shift_amt == 0) begin
                alu_result0_dec = l_operand;
            end else begin
                alu_result0_dec = (l_operand >> shift_amt) | (l_operand << (16 - shift_amt));
                alu_cf_dec      = l_operand[shift_amt - 1];
            end
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
        end

        default: begin
            alu_result0_dec = 16'b0;
            alu_result1_dec = 16'b0;
        end

        endcase
    end
    `GRP_ARITH: begin
        case (alu_sop)

        `AR_ADD: begin
            temp        = l_operand + r_operand;
            alu_result0_dec = temp[15:0];
            alu_cf_dec = temp[16];
            alu_hf_dec = (l_operand[3:0] + r_operand[3:0]) > 4'hF;
            alu_vf_dec = (~(l_operand[15] ^ r_operand[15])) & (l_operand[15] ^ alu_result0_dec[15]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_sf_dec = 1'b0;
        end

        `AR_ADDC: begin
            temp        = l_operand + r_operand + {16'b0, alu_cf_in};
            alu_result0_dec = temp[15:0];
            alu_cf_dec = temp[16];
            alu_hf_dec = (l_operand[3:0] + r_operand[3:0] + alu_cf_in) > 4'hF;
            alu_vf_dec = (~(l_operand[15] ^ r_operand[15])) & (l_operand[15] ^ alu_result0_dec[15]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_sf_dec = 1'b0;
        end

        `AR_ADDB: begin
            temp        = {9'b0, l_operand[7:0]} + {9'b0, r_operand[7:0]};
            alu_result0_dec = {l_operand[15:8], temp[7:0]};
            alu_cf_dec = temp[8];
            alu_hf_dec = (l_operand[3:0] + r_operand[3:0]) > 4'hF;
            alu_vf_dec = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp[7]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_sf_dec = 1'b0;
        end

        `AR_ADDBC: begin
            temp        = {9'b0, l_operand[7:0]} + {9'b0, r_operand[7:0]} + {8'b0, alu_cf_in};
            alu_result0_dec = {l_operand[15:8], temp[7:0]};
            alu_cf_dec = temp[8];
            alu_hf_dec = (l_operand[3:0] + r_operand[3:0] + alu_cf_in) > 4'hF;
            alu_vf_dec = (~(l_operand[7] ^ r_operand[7])) & (l_operand[7] ^ temp[7]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_sf_dec = 1'b0;
        end

        `AR_SUB: begin
            temp        = l_operand - r_operand;
            alu_result0_dec = temp[15:0];
            alu_cf_dec = temp[16];
            alu_hf_dec = (l_operand[3:0] < r_operand[3:0]);
            alu_vf_dec = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0_dec[15]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_sf_dec = 1'b0;
        end

        `AR_SUBC: begin
            temp        = l_operand - r_operand - {16'b0, alu_cf_in};
            alu_result0_dec = temp[15:0];
            alu_hf_dec = (l_operand[3:0] < r_operand[3:0]);
            alu_vf_dec = (l_operand[15] ^ r_operand[15]) & (l_operand[15] ^ alu_result0_dec[15]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
            alu_sf_dec = 1'b0;
        end

        `AR_SUBB: begin
            temp        = {9'b0, l_operand[7:0]} - {9'b0, r_operand[7:0]};
            alu_result0_dec = {l_operand[15:8], temp[7:0]};
            alu_hf_dec = (l_operand[3:0] < r_operand[3:0]);
            alu_vf_dec = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp[7]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
            alu_sf_dec = 1'b0;
        end

        `AR_SUBBC: begin
            temp        = {9'b0, l_operand[7:0]} - {9'b0, r_operand[7:0]} - {8'b0, alu_cf_in};
            alu_result0_dec = {l_operand[15:8], temp[7:0]};
            alu_hf_dec = (l_operand[3:0] < r_operand[3:0]);
            alu_vf_dec = (l_operand[7] ^ r_operand[7]) & (l_operand[7] ^ temp[7]);
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
            alu_sf_dec = 1'b0;
        end

        `AR_MUL: begin
            mul_temp = 32'b0;
            for (i = 0; i < 16; i = i + 1) begin
                if (r_operand[i])
                    mul_temp = mul_temp + ({16'b0, l_operand} << i);
            end
            alu_result0_dec = mul_temp[15:0];
            alu_result1_dec = mul_temp[31:16];
            alu_nf_dec = alu_result0_dec[15];
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
        end

        `AR_MULHB: begin
            mul_temp = 32'b0;
            for (i = 0; i < 16; i = i + 1) begin
                if (r_operand[i])
                    mul_temp = mul_temp + ({24'b0, l_operand[15:8]} << i);
            end
            alu_result0_dec = mul_temp[15:0];
            alu_nf_dec = 1'b0;
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = mul_temp[16];
        end

        `AR_MULLB: begin
            mul_temp = 32'b0;
            for (i = 0; i < 8; i = i + 1) begin
                if (r_operand[i])
                    mul_temp = mul_temp + ({24'b0, l_operand[7:0]} << i);
            end
            alu_result0_dec = mul_temp[15:0];
            alu_nf_dec = 1'b0;
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = mul_temp[16];
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
                alu_result0_dec = quotient;
                alu_result1_dec = remainder[15:0];
            end else begin
                alu_result0_dec = 16'hFFFF;
                alu_result1_dec = 16'hFFFF;
            end
            alu_nf_dec = 1'b0;
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
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
                alu_result0_dec = {l_operand[15:8], quotient[7:0]};
                alu_result1_dec = {8'b0, remainder[7:0]};
            end else begin
                alu_result0_dec = 16'hFFFF;
                alu_result1_dec = 16'hFFFF;
            end
            alu_nf_dec = 1'b0;
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
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
                alu_result0_dec = remainder[15:0];
            end else begin
                alu_result0_dec = 16'hFFFF;
            end
            alu_nf_dec = 1'b0;
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
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
                alu_result0_dec = {l_operand[15:8], remainder[7:0]};
            end else begin
                alu_result0_dec = 16'hFFFF;
            end
            alu_nf_dec = 1'b0;
            alu_zf_dec = (alu_result0_dec == 16'b0);
            alu_cf_dec = 1'b0;
        end

        default: begin
            alu_result0_dec = 16'b0;
            alu_result1_dec = 16'b0;
        end

        endcase
    end

    `GRP_LOGIC: begin
        case (alu_sop)
        `LG_AND: begin
            alu_result0_dec = l_operand & r_operand;
        end
        `LG_OR: begin
            alu_result0_dec = l_operand | r_operand;
        end
        `LG_XOR: begin
            alu_result0_dec = l_operand ^ r_operand;
        end
        `LG_NOR: begin
            alu_result0_dec = ~(l_operand | r_operand);
        end
        default: begin
            alu_result0_dec = 16'b0;
        end
        endcase
        alu_vf_dec = 1'b0;
        alu_nf_dec = alu_result0_dec[15];
        alu_zf_dec = (alu_result0_dec == 16'b0);
        alu_sf_dec = alu_nf_dec;              
    end
    
    `GRP_CMP: begin
        temp        = l_operand - r_operand;
        alu_result0_dec = temp[15:0];
        alu_zf_dec  = (alu_result0_dec == 16'b0);
        alu_gtf_dec = (~alu_result0_dec[15]) & (~alu_zf_dec);
        alu_ltf_dec = alu_result0_dec[15];
    end

    default: begin
        alu_result0_dec = 16'b0;
        alu_result1_dec = 16'b0;
    end

    endcase
end

always@(posedge clock or negedge resetb) begin
     if(!resetb)begin
        alu_result0 <= 16'b0;
        alu_result1 <= 16'b0;

        alu_cf  <= 1'b0;
        alu_zf  <= 1'b0;
        alu_nf  <= 1'b0;
        alu_vf  <= 1'b0;
        alu_sf  <= 1'b0;
        alu_hf  <= 1'b0;
        alu_gtf <= 1'b0;
        alu_ltf <= 1'b0;
    end
     else if(t3)begin
        alu_result0 <= alu_result0_dec;
        alu_result1 <= alu_result1_dec;
        alu_cf <= alu_cf_dec;
        alu_zf <= alu_zf_dec;
        alu_nf <= alu_nf_dec;
        alu_vf <= alu_vf_dec;
        alu_sf <= alu_sf_dec;
        alu_hf <= alu_hf_dec;
        alu_gtf <= alu_gtf_dec;
        alu_ltf <= alu_ltf_dec;
   end
end
endmodule