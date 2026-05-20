module data_bus_control (
    input  wire        clk,
    input  wire        reset,

    input  wire        t2,
    input  wire        t4,

    input  wire [1:0]  dbus_access,
    input  wire [1:0]  dbus_addr_sel,
    input  wire [1:0]  dbus_data_sel,

    input  wire [15:0] rd_data,
    input  wire [15:0] rs_data,
    input  wire [15:0] sp_out,
    input  wire [15:0] pc_out,

    input  wire [15:0] dmem_rdata,   // 외부 data memory에서 들어오는 data

    output reg  [15:0] dmem_addr,    // 외부 data memory로 나가는 address
    output reg  [15:0] dmem_wdata,   // 외부 data memory로 나가는 write data
    output wire        RDb,
    output wire        WRb,

    output reg  [15:0] mbr
);

endmodule