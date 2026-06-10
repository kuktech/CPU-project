module program_memory(

    input wire [15:0] paddr_pin,

    input wire prdb_pin,
    input wire pcsb_pin,

    output reg [15:0] pdata_pin

);

reg [15:0] pgm_mem [0:65535]; //16'hffff + 1 = 65536

initial begin
    $readmemh("program.hex", pgm_mem);
end

always @(*) begin
    if(!prdb_pin && !pcsb_pin)
        pdata_pin = pgm_mem[paddr_pin];
    else
        pdata_pin = 16'hzzzz;
end

endmodule