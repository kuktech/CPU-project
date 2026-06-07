module top (
input wire clock,
input wire resetb,

input  wire [15:0] pbus_in_data,
output wire [15:0] p_addr,
output wire prdb_pin,
output wire pcsb_pin,

output wire [15:0] d_addr,
output wire [15:0] dmem_wdata,
output wire drdb_pin,
output wire dwrb_pin,
output wire dcsb_pin,

output wire halt
);
//state control
wire t1,t2,t3,t4,t5;
wire pc_wr_en;

//program counter
wire next_pc;


state_control u_state_control (
    .clock(clock),
    .resetb(resetb)
);

program_counter u_program_counter (
    .clock(clock),
    .resetb(resetb)
);

stack_pointer u_stack_pointer (
    .clock(clock),
    .resetb(resetb)
);

status_register u_status_register (
    .clock(clock)
);

instruction_register u_instruction_register (
    .clock(clock)
);

instruction_decoder u_instruction_decoder (
    .clock(clock)
);

register u_register (
    .clock(clock)
);

alu u_alu (
       
);

program_bus u_program_bus (
    .clock(clock)
);

data_bus u_data_bus (
    .clock(clock)
);

endmodule