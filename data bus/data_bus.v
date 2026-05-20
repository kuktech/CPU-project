module data_bus(
    input  wire        clock,
    input  wire        resetb,

    input  wire        t2,
    input  wire        t4,

    input  wire [1:0]  dbus_access,
    input  wire [1:0]  dbus_addr_sel,
    input  wire [1:0]  dbus_data_sel,

    input  wire [15:0] rd_data,
    input  wire [15:0] rs_data,
    input  wire [15:0] sp_in,
    input  wire [15:0] pc_in,

    input  wire [15:0] dmem_rdata,    

    output reg         drdb_pin,
    output reg         dwrb_pin,
    output reg         dcsb_pin,

    output reg  [15:0] mbr,
    output reg  [15:0] mar
);

reg drdb;
reg dwrb;
reg dcsb;

always @(*) begin
    drdb <= 1'b1;
    dwrb <= 1'b1;
    dcsb <= 1'b1;
    
    if(t2) begin
        case({dbus_access,dbus_addr_sel,dbus_data_sel}) 
            6'b100000:begin   //load
                      mar <= rs_data;    
                      dcsb <= 1'b0;
                      drdb <= 1'b0;
                      end
            6'b110101:begin //store
                      mar <= rs_data;
                      mbr <= rd_data;
                      dcsb <= 1'b0;
                      dwrb <= 1'b0;
            end  
            6'b111010:begin //push
                      mar <= sp_in-1'b1;
                      mbr <= rs_data;
                      dcsb <= 1'b0;
                      dwrb <= 1'b0;
            end   
            6'b101100: begin//pop
                      mar <= sp_in;
                      dcsb <= 1'b0;
                      drdb <= 1'b0;
            end  
             6'b111011: begin//call
                       mar <= sp_in-1'b1;
                       mbr <= pc_in;
                       dcsb <= 1'b0;
                       dwrb <= 1'b0;
             end
              6'b101100:begin//ret
                       mar <= sp_in;
                       dcsb <= 1'b0;
                       drdb <= 1'b0;
              end 
        endcase          
    end
    else if(t4) begin
         case({dbus_access,dbus_addr_sel,dbus_data_sel}) 
            6'b100000:begin   //load
                      mbr <= dmem_rdata;
                      end  
            6'b101100:begin//pop
                      mbr <= dmem_rdata;
                      end  
            6'b101100:begin//ret
                      mbr <= dmem_rdata;
                
              end 
        endcase 
    end
end

always @(posedge clock or negedge resetb) begin
    if(!resetb) begin
        drdb_pin <= 1'b0;
        dwrb_pin <= 1'b0;
        dcsb_pin <= 1'b0;
    end
    else if(t4)begin
        drdb_pin <= drdb;
        dwrb_pin <= dwrb;
        dcsb_pin <= dcsb;
    end

    
end
endmodule