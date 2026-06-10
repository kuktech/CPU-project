module stack_pointer (
input wire clock,
input wire resetb,

input wire t2,
input wire t5,

input wire sp_sel,
input wire sp_wr_en,
input wire mv_sp,

input wire [15:0] rs_data,

output wire [15:0] sp_out
);
reg [15:0] sp = 16'b0000000011111111;
assign sp_out = sp;

always @(posedge clock or negedge resetb ) begin
    if(!resetb)begin
        sp = 16'b0000000011111111;
    end
    else if(t5&&sp_wr_en)begin
        if(mv_sp)begin
            sp <= rs_data;
        end
        else if (sp_sel) begin
            sp <= sp - 1;
        end
        else if (!sp_sel) begin
            sp <= sp + 1;
        end
    end
end
endmodule