`timescale 1ns/1ps

module cpu_tb;
reg clock;
reg resetb;
reg [15:0] program_data;
reg [15:0] dmem_rdata;     

wire [15:0] pbus_in_address;
wire prdb_pin;
wire pcsb_pin;

wire [15:0] mbr;        
wire [15:0] mar;             
wire drdb_pin;
wire dwrb_pin;
wire dcsb_pin;

top u_top (
    .clock(clock),
    .resetb(resetb),
    .program_data(program_data),
    .dmem_rdata(dmem_rdata),    
    .pbus_in_address(pbus_in_address),
    .prdb_pin(prdb_pin),
    .pcsb_pin(pcsb_pin),
    .mbr(mbr),
    .mar(mar),
    .drdb_pin(drdb_pin),
    .dwrb_pin(dwrb_pin),
    .dcsb_pin(dcsb_pin)
);

reg [15:0] pgm_mem [0:16'hffff];
reg [15:0] data_mem [0:16'hffff];

wire [15:0] pgm_addr = pbus_in_address[15:1];
wire [15:0] data_addr = mar[15:1];

integer i;
initial begin
    for (i = 0; i < 16'hffff; i = i+1) begin
        pgm_mem[i] = i;
        data_mem[i] = i;
    end
  
end

always @(*) begin
    if (prdb_pin == 0 && pcsb_pin == 0)
        program_data = #5 pgm_mem[pgm_addr];
    else
        program_data = 16'hzzzz;
end

initial begin
    forever begin
        @(negedge drdb_pin) begin
            if (dcsb_pin == 0) #5 dmem_rdata = data_mem[data_addr];
        end
        @(posedge drdb_pin) #5 dmem_rdata = 16'hzzzz;
    end
end

initial begin
    forever begin
        @(negedge dwrb_pin) begin
            if (dcsb_pin == 0) data_mem[data_addr] = mbr;
        end
    end
end

always #50 clock = ~clock;

initial begin
    clock       = 1'b0;
    resetb      = 1'b0;
    program_data = 16'hzzzz;
    dmem_rdata  = 16'hzzzz;

    $display("========== ToyCom3 Test Start ==========");
    #100 resetb = 1'b1;
end

initial begin
    forever begin
        @(negedge dwrb_pin) begin
            if (dcsb_pin == 0 && mbr == 16'hffff) begin
                $display("Test PASS: mbr = 0x%h", mbr);
                #50 $finish;
            end
        end
    end
end

parameter TEST_IDX = 0; 

task load_all_instructions;
begin
    pgm_mem[ 0] = 16'h0000;  // NOP
    pgm_mem[ 1] = 16'h0001;  // HALT
    pgm_mem[ 2] = 16'h1140;  // LD R1,(R2)
    pgm_mem[ 3] = 16'h1141;  // ST (R1),R2
    pgm_mem[ 4] = 16'h1102;  // POP R1
    pgm_mem[ 5] = 16'h1043;  // PUSH R2
    pgm_mem[ 6] = 16'h0905;  // LDIL R1,#5
    pgm_mem[ 7] = 16'h1905;  // LDIH R1,#5
    pgm_mem[ 8] = 16'h1144;  // MV R1,R2
    pgm_mem[ 9] = 16'h1745;  // MVSP SP,R2
    pgm_mem[10] = 16'h1106;  // SWAP R1
    pgm_mem[11] = 16'h1147;  // EXHG R1,R2
    pgm_mem[12] = 16'h2100;  // INC R1
    pgm_mem[13] = 16'h2101;  // DEC R1
    pgm_mem[14] = 16'h2102;  // NEC R1
    pgm_mem[15] = 16'h2103;  // NOT R1
    pgm_mem[16] = 16'h2104;  // SHL R1
    pgm_mem[17] = 16'h2105;  // SHR R1
    pgm_mem[18] = 16'h2106;  // ASL R1
    pgm_mem[19] = 16'h2107;  // ASR R1
    pgm_mem[20] = 16'h2108;  // ROL R1
    pgm_mem[21] = 16'h2109;  // ROR R1
    pgm_mem[22] = 16'h21B4;  // SHL R1,#5
    pgm_mem[23] = 16'h21B5;  // SHR R1,#5
    pgm_mem[24] = 16'h21B6;  // ASL R1,#5
    pgm_mem[25] = 16'h21B7;  // ASR R1,#5
    pgm_mem[26] = 16'h21B8;  // ROL R1,#5
    pgm_mem[27] = 16'h21B9;  // ROR R1,#5
    pgm_mem[28] = 16'h2940;  // ADD R1,R2
    pgm_mem[29] = 16'h2941;  // ADDC R1,R2
    pgm_mem[30] = 16'h2942;  // ADDB R1,R2
    pgm_mem[31] = 16'h2943;  // ADDBC R1,R2
    pgm_mem[32] = 16'h2944;  // SUB R1,R2
    pgm_mem[33] = 16'h2945;  // SUBC R1,R2
    pgm_mem[34] = 16'h2946;  // SUBB R1,R2
    pgm_mem[35] = 16'h2947;  // SUBBC R1,R2
    pgm_mem[36] = 16'h2948;  // MUL R1,R2
    pgm_mem[37] = 16'h294B;  // MULHB R1,R2
    pgm_mem[38] = 16'h294A;  // MULLB R1,R2
    pgm_mem[39] = 16'h294C;  // DIV R1,R2
    pgm_mem[40] = 16'h294E;  // DIVB R1,R2
    pgm_mem[41] = 16'h294D;  // MOD R1,R2
    pgm_mem[42] = 16'h294F;  // MODB R1,R2
    pgm_mem[43] = 16'h3140;  // AND R1,R2
    pgm_mem[44] = 16'h3141;  // OR R1,R2
    pgm_mem[45] = 16'h3142;  // XOR R1,R2
    pgm_mem[46] = 16'h3143;  // NOR R1,R2
    pgm_mem[47] = 16'h3940;  // CMP R1,R2
    pgm_mem[48] = 16'h400C;  // CLR SR.3
    pgm_mem[49] = 16'h410D;  // CLR R1.3
    pgm_mem[50] = 16'h400E;  // SET SR.3
    pgm_mem[51] = 16'h410F;  // SET R1.3
    pgm_mem[52] = 16'h600A;  // CALL +10
    pgm_mem[53] = 16'h6800;  // RET
    pgm_mem[54] = 16'h700A;  // BR +10
    pgm_mem[55] = 16'h780A;  // BRR +10
    pgm_mem[56] = 16'h800A;  // BRNZ +10
    pgm_mem[57] = 16'h880A;  // BRZ +10
    pgm_mem[58] = 16'h900A;  // BRNS +10
    pgm_mem[59] = 16'h980A;  // BRS +10
    pgm_mem[60] = 16'hA00A;  // BRNC +10
    pgm_mem[61] = 16'hA80A;  // BRC +10
    pgm_mem[62] = 16'hB00A;  // BRNV +10
    pgm_mem[63] = 16'hB80A;  // BRV +10
    pgm_mem[64] = 16'hC00A;  // BRNGT +10
    pgm_mem[65] = 16'hC80A;  // BRGT +10
    pgm_mem[66] = 16'hD00A;  // BRNLT +10
    pgm_mem[67] = 16'hD80A;  // BRLT +10
end
endtask

initial begin
    // 전체 NOP으로 초기화
    for (i = 0; i < 16'hffff; i = i+1)
        pgm_mem[i] = 16'h0000;

    // 명령어 테이블 로드
    load_all_instructions;

    // TEST_IDX 명령어만 pgm_mem[0]에 복사, 이후 HALT
    pgm_mem[0] = pgm_mem[TEST_IDX];
    pgm_mem[1] = 16'h0001;  // HALT

    // 레지스터 초기값 설정용 선행 명령어가 필요하면 여기에 추가
    // ex) R1=0x0010, R2=0x0005 세팅 후 테스트 명령어 실행
    // pgm_mem[0] = 16'h0910;  // LDIL R1, #0x10
    // pgm_mem[1] = 16'h0A05;  // LDIL R2, #0x05
    // pgm_mem[2] = pgm_mem[TEST_IDX];
    // pgm_mem[3] = 16'h0001;  // HALT
end
endmodule