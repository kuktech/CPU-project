module program_bus (
    input  wire  clock,
    input  wire  resetb,
    input  wire  t1,
    input  wire  t2,

    input  wire [15:0] pc,
    input  wire [15:0] program_data,

    output reg  prdb_pin,
    output reg  pcsb_pin,

    output wire [15:0] pbus_in_address,
    output wire [15:0] pbus_in_data
);

assign pbus_in_address = pc;
assign pbus_in_data    = program_data;

always @(posedge clock or negedge resetb) begin
    if (!resetb) begin
        prdb_pin <= 1'b1;
        pcsb_pin <= 1'b1;
    end
    else if (t1) begin
        prdb_pin <= 1'b0;
        pcsb_pin <= 1'b0;
    end
    else if (t2) begin
        prdb_pin <= 1'b1;
        pcsb_pin <= 1'b1;
    end
end

endmodule