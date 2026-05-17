module program_counter(
input wire clock,
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

always @(posedge clock) begin
    if(pc_wr_en)begin
    case (pc_sel)
        2'b00: if(t1)begin
                pc <= pc + 2;
            end
        2'b01: if(t3)begin
                pc <= pc + offset;
            end
        2'b10: if(t3)begin
                pc <= offset;
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
