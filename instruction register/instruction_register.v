module instruction_register (
input wire clock,
input wire resetb,

input wire t1,

input wire [15:0] pbus_in_data,

output reg [15:0] instruction
);

always @(posedge clock or negedge resetb) begin
    if(!resetb)begin
        instruction <= 16'b0;
    end
    else if (t1) begin
        instruction <= pbus_in_data;
    end
    
end

endmodule