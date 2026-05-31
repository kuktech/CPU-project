module data_bus(
    input  wire  clock,
    input  wire  resetb,

    input  wire  t2,
    input  wire  t4,
    input  wire  t5,

    input  wire [1:0] dbus_access,
    input  wire [1:0] dbus_addr_sel,
    input  wire [1:0] dbus_data_sel,

    input  wire [15:0] rd_data,
    input  wire [15:0] rs_data,
    input  wire [15:0] sp_in,
    input  wire [15:0] pc_in,

    input  wire [15:0] dmem_rdata,    

    output reg  drdb_pin,
    output reg  dwrb_pin,
    output reg  dcsb_pin,

    output reg [15:0] mbr,
    output reg [15:0] mar,

    output reg[15:0] dbus_in_data,
    output reg[15:0] dbus_in_pc
);

reg drdb;
reg dwrb;
reg dcsb;

always @(*) begin
    drdb = 1'b1;
    dwrb = 1'b1;
    dcsb = 1'b1;
     case({dbus_access,dbus_addr_sel,dbus_data_sel}) 
            6'b100000:begin   //load
                      dcsb = 1'b0;
                      drdb = 1'b0;
                      end
            6'b110101:begin //store
                      dcsb = 1'b0;
                      dwrb = 1'b0;
            end  
            6'b111010:begin //push
                      dcsb = 1'b0;
                      dwrb = 1'b0;
            end   
            6'b101100: begin//pop , ret
                      dcsb = 1'b0;
                      drdb = 1'b0;
            end  
             6'b111011: begin//call
                      dcsb = 1'b0;
                      dwrb = 1'b0;
             end
            default: begin
                    drdb = 1'b1;
                    dwrb = 1'b1;
                    dcsb = 1'b1;
            end
        endcase          
end

always @(posedge clock or negedge resetb) begin
    if(!resetb) begin
        drdb_pin <= 1'b1;
        dwrb_pin <= 1'b1;
        dcsb_pin <= 1'b1;
        mar <= 16'b0;
        mbr <= 16'b0;
        dbus_in_data <=16'b0;
        dbus_in_pc <= 16'b0;
    end
    else if(t2) begin
         drdb_pin <= drdb;
         dwrb_pin <= dwrb;
         dcsb_pin <= dcsb;
        case({dbus_access,dbus_addr_sel,dbus_data_sel}) 
            6'b100000:begin   //load
                      mar <= rs_data;    
                      end
            6'b110101:begin //store
                      mar <= rd_data;  
                      mbr <= rs_data;     
                      end  
            6'b111010:begin //push
                      mar <= sp_in-1'b1;
                      mbr <= rs_data;    
                      end   
            6'b101100: begin//pop , ret
                      mar <= sp_in;
                      end  
            6'b111011:begin//call
                      mar <= sp_in-1'b1;
                      mbr <= pc_in;
                     end
     
        endcase          
    end
    else if(t4) begin 
         case({dbus_access,dbus_addr_sel,dbus_data_sel}) 
            6'b100000:begin   //load
                      dbus_in_data <= dmem_rdata;
                      end  
            6'b101100:begin//pop , ret
                      dbus_in_data <= dmem_rdata;
                      end  
        endcase 
    end
    if (t5) begin
            drdb_pin <= 1'b1;
            dwrb_pin <= 1'b1;
            dcsb_pin <= 1'b1;
        end
    
end
endmodule