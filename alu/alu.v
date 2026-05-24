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