module program_counter(
input wire clock,
input wire reset_b,
input wire [15:0] pc_in,
input wire pc_wr_en,
input wire [1:0] pc_sel,
input wire t1,
input wire t3,
input wire t5,

input wire [10:0] offset,

output wire [15:0] next_pc
);

reg [15:0] pc = 16'b0;
wire [15:0] offset_ext;
assign offset_ext = {{5{offset[10]}}, offset};

always @(posedge clock or negedge reset_b) begin
    if (!reset_b) begin
        pc <= 16'b0;
    end
    else if(pc_wr_en)begin
    case (pc_sel)
        2'b00: if(t1)begin
                pc <= pc + 2;
            end
        2'b01: if(t3)begin
                pc <= pc + offset_ext;
            end
        2'b10: if(t3)begin
                pc <= offset_ext;
            end
        2'b11: if(t5)begin
                pc <= pc_in;
            end
        default: pc <= pc + 2;
    endcase
    end
end

assign next_pc = pc;

endmodule
