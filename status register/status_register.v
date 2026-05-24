module status_register (

    input  wire        clock,
    input  wire        reset_b,

    // 게이트
    input  wire        t5,          // ALU 결과 확정 타이밍 (SR 갱신)
    input  wire        t2,          // 명령어 실행 타이밍 (CLR/SET)

    // 명령어 종류 식별
    input  wire        sr_wr_en,    // ALU 연산 결과로 SR을 갱신할 때 1
    input  wire        sr_bit_en,   // CLR SR.n / SET SR.n 명령어일 때 1
    input  wire        sr_bit_sel,  // 0 = CLR,  1 = SET

    // ALU 플래그 입력 (alu_plus.v 출력과 직결)
    input  wire        alu_zf,
    input  wire        alu_cf,
    input  wire        alu_nf,
    input  wire        alu_vf,
    input  wire        alu_gtf,
    input  wire        alu_ltf,

    // CLR/SET 대상 비트 번호 (명령어 [7:2] 필드 = SR.n)
    // SR 비트 배치: [5]=LT [4]=GT [3]=VF [2]=CF [1]=NF [0]=ZF
    input  wire [2:0]  sr_bit_idx,  // 0~5

    // SR 출력
    output reg         zf,          // bit 0 : Zero / EQ
    output reg         nf,          // bit 1 : Negative / Sign
    output reg         cf,          // bit 2 : Carry
    output reg         vf,          // bit 3 : Overflow
    output reg         gtf,         // bit 4 : Greater-Than  (CMP 전용)
    output reg         ltf,         // bit 5 : Less-Than     (CMP 전용)

    // 분기 조건 출력 (컨트롤러 → PC 선택에 사용)
    output wire        br_z,        // BRZ  : z==1
    output wire        br_nz,       // BRNZ : z==0
    output wire        br_s,        // BRS  : n==1
    output wire        br_ns,       // BRNS : n==0
    output wire        br_c,        // BRC  : c==1
    output wire        br_nc,       // BRNC : c==0
    output wire        br_v,        // BRV  : v==1
    output wire        br_nv,       // BRNV : v==0
    output wire        br_gt,       // BRGT : gt==1
    output wire        br_ngt,      // BRNGT: gt==0
    output wire        br_lt,       // BRLT : lt==1
    output wire        br_nlt,      // BRNLT: lt==0

    // ADDC/SUBC/ADDBC/SUBBC 용 Carry 피드백
    output wire        cf_out       // ALU cf_in 으로 연결
);

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// SR 비트 인덱스 상수
`define SR_ZF  3'd0
`define SR_NF  3'd1
`define SR_CF  3'd2
`define SR_VF  3'd3
`define SR_GTF 3'd4
`define SR_LTF 3'd5

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// SR 래치
always @(posedge clock or negedge reset_b) begin
    if (!reset_b) begin
        zf  <= 1'b0;
        nf  <= 1'b0;
        cf  <= 1'b0;
        vf  <= 1'b0;
        gtf <= 1'b0;
        ltf <= 1'b0;
    end

    // t5: ALU 연산 결과로 SR 전체 갱신
    else if (t5 && sr_wr_en) begin
        zf  <= alu_zf;
        nf  <= alu_nf;
        cf  <= alu_cf;
        vf  <= alu_vf;
        gtf <= alu_gtf;
        ltf <= alu_ltf;
    end

    // t2: CLR SR.n / SET SR.n 명령어 처리
    else if (t2 && sr_bit_en) begin
        if (!sr_bit_sel) begin
            // CLR SR.n : SR(n) <-- 0
            case (sr_bit_idx)
                `SR_ZF  : zf  <= 1'b0;
                `SR_NF  : nf  <= 1'b0;
                `SR_CF  : cf  <= 1'b0;
                `SR_VF  : vf  <= 1'b0;
                `SR_GTF : gtf <= 1'b0;
                `SR_LTF : ltf <= 1'b0;
                default : ;
            endcase
        end else begin
            // SET SR.n : SR(n) <-- 1
            case (sr_bit_idx)
                `SR_ZF  : zf  <= 1'b1;
                `SR_NF  : nf  <= 1'b1;
                `SR_CF  : cf  <= 1'b1;
                `SR_VF  : vf  <= 1'b1;
                `SR_GTF : gtf <= 1'b1;
                `SR_LTF : ltf <= 1'b1;
                default : ;
            endcase
        end
    end
end

// =============================================================
// 분기 조건 출력 (조합 논리 – 등록된 SR 값 그대로 반영) 이게 뭔지는 나도 잘 모르겠음
// 명령어 셋 기준:
//   BRNZ : z=0 → PC <-- PC+offset
//   BRZ  : z=1 → PC <-- PC+offset
//   BRNS : s=0 → PC <-- PC+offset
//   BRS  : s=1 → PC <-- PC+offset
//   BRNC : c=0 → PC <-- PC+offset
//   BRC  : c=1 → PC <-- PC+offset
//   BRNV : v=0 → PC <-- PC+offset
//   BRV  : v=1 → PC <-- PC+offset
//   BRNGT: gt=0→ PC <-- PC+offset
//   BRGT : gt=1→ PC <-- PC+offset
//   BRNLT: lt=0→ PC <-- PC+offset
//   BRLT : lt=1→ PC <-- PC+offset
// =============================================================
assign br_z   =  zf;
assign br_nz  = ~zf;
assign br_s   =  nf;
assign br_ns  = ~nf;
assign br_c   =  cf;
assign br_nc  = ~cf;
assign br_v   =  vf;
assign br_nv  = ~vf;
assign br_gt  =  gtf;
assign br_ngt = ~gtf;
assign br_lt  =  ltf;
assign br_nlt = ~ltf;

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// Carry 피드백 → ALU의 cf_in 포트로 연결

assign cf_out = cf;

endmodule