module instruction_register (
input wire clock,
input wire resetb,

input wire t1,

input wire branch_en,

input wire [15:0] pbus_in_data,

output reg [15:0] instruction_out,

output wire wr_en

);
assign wr_en = t1;

always @(posedge clock or negedge resetb) begin
    if(!resetb)begin
        instruction_out <= 16'b0;
    end
    else if (wr_en) begin
        instruction_out <= pbus_in_data;
    end
    
end

endmodule