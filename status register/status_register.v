module status_register (

    input  wire  clock,
    input  wire  resetb,

    // 게이트
    input  wire  t5,          
    input  wire  t2,          

    // 명령어 종류 식별
    input  wire  sreg_wr_en,    
    input  wire  sr_bit_en,   
    input  wire  sr_bit_sel,  

    // ALU 플래그 입력
    input  wire  alu_zf,
    input  wire  alu_cf,
    input  wire  alu_nf,
    input  wire  alu_vf,
    input  wire  alu_gtf,
    input  wire  alu_ltf,

    input  wire [2:0]  sr_bit_idx,  

    // SR 출력
    output reg         zf,          
    output reg         nf,         
    output reg         cf,          
    output reg         vf,          
    output reg         gtf,         
    output reg         ltf,         

    // 분기 조건 출력
    output wire        br_z,        
    output wire        br_nz,       
    output wire        br_s,        
    output wire        br_ns,       
    output wire        br_c,        
    output wire        br_nc,       
    output wire        br_v,        
    output wire        br_nv,       
    output wire        br_gt,       
    output wire        br_ngt,      
    output wire        br_lt,       
    output wire        br_nlt,     

    // ADDC/SUBC/ADDBC/SUBBC 용 Carry 피드백
    output wire        cf_out       
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
always @(posedge clock or negedge resetb) begin
    if (!resetb) begin
        zf  <= 1'b0;
        nf  <= 1'b0;
        cf  <= 1'b0;
        vf  <= 1'b0;
        gtf <= 1'b0;
        ltf <= 1'b0;
    end

    // t5: ALU 연산 결과로 SR 전체 갱신
    else if (t5 && sreg_wr_en) begin
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

assign cf_out = cf;

endmodule