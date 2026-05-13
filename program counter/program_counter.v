module program_counter (
    input wire        clock,
    input wire        reset,

    input wire        pc_wr_en,
    input wire        pc_sel,
    input wire        t1_wr,
    input wire        t3_wr,

    input wire [15:0] t1_pc_in,
    input wire [15:0] t3_pc_in,

    output reg [15:0] pc_out
);

wire [15:0] next_pc;
wire        pc_update_en;

assign next_pc = (pc_sel == 1'b0) ? t1_pc_in : t3_pc_in;

assign pc_update_en = pc_wr_en &&
                      (((pc_sel == 1'b0) && t1_wr) ||
                       ((pc_sel == 1'b1) && t3_wr));

always @(posedge clock or posedge reset) begin
    if (reset) begin
        pc_out <= 16'h0000;
    end
    else if (pc_update_en) begin
        pc_out <= next_pc;
    end
end

endmodule
