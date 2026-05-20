module program_bus (
input wire clock,
input wire reset_b,
input wire t1,
input wire t3,
input wire wr_en,
input wire [15:0] pc,
input wire [15:0] program_data,

output reg [15:0] pbus_in_data,
output wire [15:0] pbus_in_address
);

assign pbus_in_address = pc;

always @(posedge clock or negedge reset_b) begin
    if (!reset_b) begin
        pbus_in_data <= 16'h0000;
    end
    else if (wr_en) begin
        pbus_in_data <= program_data;
    end
    
end

endmodule