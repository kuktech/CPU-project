`include "define.vh"
module status_register (
    input wire clock,
    input wire resetb,

    input wire t3,
    input wire t5,                

    input wire sreg_wr_en,    
    input wire sr_bit_en,   
    input wire sr_bit_sel,  
    input wire [2:0] sr_bit_idx, 

    input wire alu_cf,
    input wire alu_zf,
    input wire alu_nf,
    input wire alu_vf,
    input wire alu_sf,
    input wire alu_hf,
    input wire alu_ltf,
    input wire alu_gtf,

    output reg cf,
    output reg zf,          
    output reg nf,         
    output reg vf,
    output reg sf,
    output reg hf, 
    output reg ltf,         
    output reg gtf,         
             
    output wire cf_out       
);
assign cf_out = cf;

always @(posedge clock or negedge resetb) begin
    if (!resetb) begin
        cf <= 1'b0;
        zf <= 1'b0;
        nf <= 1'b0;
        vf <= 1'b0;
        sf <= 1'b0;
        hf <= 1'b0;
        ltf<= 1'b0; 
        gtf<= 1'b0;
    end

    else if (t5 && sreg_wr_en) begin
        cf  <= alu_cf;
        zf  <= alu_zf;
        nf  <= alu_nf;
        vf  <= alu_vf;
        sf  <= alu_sf;
        hf  <= alu_hf;
        ltf <= alu_ltf;
        gtf <= alu_gtf;
    end

    else if (t3 && sr_bit_en) begin
        if (sr_bit_sel) begin
             case (sr_bit_idx)
                `SR_CF: cf <= 1'b1;
                `SR_ZF: zf <= 1'b1;
                `SR_NF: nf <= 1'b1;
                `SR_SF: sf <= 1'b1;
                `SR_HF: hf <= 1'b1;
                `SR_VF: vf <= 1'b1;
                `SR_LTF: ltf <= 1'b1; 
                `SR_GTF: gtf <= 1'b1;
                default : ;
            endcase
        end
        else  begin
            case(sr_bit_idx) 
                `SR_CF: cf <= 1'b0;
                `SR_ZF: zf <= 1'b0;
                `SR_NF: nf <= 1'b0;
                `SR_SF: sf <= 1'b0;
                `SR_HF: hf <= 1'b0;
                `SR_VF: vf <= 1'b0;
                `SR_LTF: ltf <= 1'b0; 
                `SR_GTF: gtf <= 1'b0;
                default: ;
            endcase
        end
    end
end
endmodule
