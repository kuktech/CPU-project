module program_counter(
input wire clock,
input wire resetb,

input wire [15:0] pc_in,

input wire pc_wr_en,
input wire [1:0] pc_sel,
input wire call,

input wire t1,
input wire t3,
input wire t5,

input wire [10:0] offset,

output wire [15:0] next_pc
);

reg [15:0] pc = 16'b0;
wire [15:0] offset_ext;
assign offset_ext = {{5{offset[10]}}, offset};

always @(posedge clock or negedge resetb) begin
    if (!resetb) begin
        pc <= 16'b0;
    end
     else if (t1) begin
        pc <= pc + 1'b1;
    end
    else if(pc_wr_en)begin
        case (pc_sel)
            2'b01: begin
                if ((call && t5) || (!call && t3)) begin
                    pc <= pc + offset_ext;
                end
            end
            2'b10: begin
                if (t3) begin
                    pc <= offset_ext;
                end
            end
            2'b11: begin
                if (t5) begin
                    pc <= pc_in;
                end
            end
            default: pc <= pc;
        endcase
    end
end

assign next_pc = pc;

endmodule
