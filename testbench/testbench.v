`timescale 1ns/1ps

module tb_top;

// ─── 1. DUT 연결용 신호 선언 ──────────────────────────
reg         clock;
reg         resetb;
reg  [15:0] program_data;
reg  [15:0] dmem_rdata;      // data memory → CPU

wire [15:0] pbus_in_address;
wire        prdb_pin;
wire        pcsb_pin;

wire [15:0] mbr;             // CPU → data memory (write data)
wire [15:0] mar;             // CPU → data memory (address)
wire        drdb_pin;
wire        dwrb_pin;
wire        dcsb_pin;

// ─── 2. DUT 인스턴스 ──────────────────────────────────
top u_top (
    .clock          (clock),
    .resetb         (resetb),
    .program_data   (program_data),
    .dmem_rdata     (dmem_rdata),    // 추가
    .pbus_in_address(pbus_in_address),
    .prdb_pin       (prdb_pin),
    .pcsb_pin       (pcsb_pin),
    .mbr            (mbr),
    .mar            (mar),
    .drdb_pin       (drdb_pin),
    .dwrb_pin       (dwrb_pin),
    .dcsb_pin       (dcsb_pin)
);

// ─── 3. 메모리 선언 ───────────────────────────────────
reg [15:0] pgm_mem  [0:16'hffff];
reg [15:0] data_mem [0:16'hffff];

wire [15:0] pgm_addr  = pbus_in_address[15:1];
wire [15:0] data_addr = mar[15:1];

// ─── 4. 메모리 초기화 + 명령어 로드 ──────────────────
integer i;
initial begin
    for (i = 0; i < 16'hffff; i = i+1) begin
        pgm_mem[i]  = i;
        data_mem[i] = i;
    end
    $readmemh("./toycom3_top.stimulus", pgm_mem);
end

// ─── 5. Program Memory 읽기 ───────────────────────────
always @(*) begin
    if (prdb_pin == 0 && pcsb_pin == 0)
        program_data = #5 pgm_mem[pgm_addr];
    else
        program_data = 16'hzzzz;
end

// ─── 6. Data Memory 읽기 ──────────────────────────────
initial begin
    forever begin
        @(negedge drdb_pin) begin
            if (dcsb_pin == 0) #5 dmem_rdata = data_mem[data_addr];
        end
        @(posedge drdb_pin) #5 dmem_rdata = 16'hzzzz;
    end
end

// ─── 7. Data Memory 쓰기 ──────────────────────────────
initial begin
    forever begin
        @(negedge dwrb_pin) begin
            if (dcsb_pin == 0) data_mem[data_addr] = mbr;
        end
    end
end

// ─── 8. Clock 생성 ────────────────────────────────────
always #50 clock = ~clock;

// ─── 9. 초기화 및 Reset ───────────────────────────────
initial begin
    clock       = 1'b0;
    resetb      = 1'b0;
    program_data = 16'hzzzz;
    dmem_rdata  = 16'hzzzz;

    $display("========== ToyCom3 Test Start ==========");
    #100 resetb = 1'b1;
end

// ─── 10. 종료 조건 ────────────────────────────────────
initial begin
    forever begin
        @(negedge dwrb_pin) begin
            if (dcsb_pin == 0 && mbr == 16'hffff) begin
                $display("Test PASS: mbr = 0x%h", mbr);
                #50 $finish;
            end
        end
    end
end

endmodule