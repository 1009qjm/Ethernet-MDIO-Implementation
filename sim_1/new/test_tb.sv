`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/25 15:21:42
// Design Name: 
// Module Name: test_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_tb(

    );
logic clk;
logic rst_n;
logic eth_mdc;
wire eth_mdio;
logic eth_rst_n;
logic start;
logic is_rd;
logic [4:0] phy_addr;
logic [4:0] reg_addr;
logic [15:0] wr_data;
logic [15:0] rd_data;
logic o_vld;
//
pullup(eth_mdio);
//clk
initial begin
    clk=0;
    forever begin
        #40 clk=~clk;
    end
end
//rst_n
initial begin
    rst_n=0;
    #120
    rst_n=1;
end
//start
initial begin
    start=0;
    #200
    start=1;
    #80
    start=0;
    #10000
    start=1;
    #80
    start=0;
end
//is_rd
initial begin
    is_rd=0;
    #10280
    is_rd=1;
end
//addr
initial begin
    phy_addr=5'b00001;
    reg_addr=5'b00101;
end
//wr_data
initial begin
    wr_data=16'b0101010110101010;
end
//*******************************************************************
//为PHY寄存器赋初始值
logic we_i;
logic strobe_i;
logic  [7:0]  address_i;
logic  [7:0]  data_i;
logic  [7:0]  data_o;
logic clk_i;
logic rst_i;
//clk_i
initial begin
    clk_i=0;
    forever begin
        #40 clk_i=~clk_i;
    end
end
//rst_i
initial begin
    rst_i=1;
    #160
    rst_i=0;
end
//others
initial begin
    we_i           = 1'b0;
    strobe_i       = 1'b0;     
    address_i      = 8'd0;
    data_i         = 8'd0;
    #200        
    we_i           = 1'b1;         //像地址5'h05写入16'h55aa
    strobe_i       = 1'b1; 
    address_i      = 8'h0a;
    data_i         = 8'h55;
    #80             
    address_i      = 8'h0b;
    data_i         = 8'haa;
    #80             
    address_i      = 8'h40;        //设置PHY芯片的PHY地址
    data_i         = 8'b00000001;            
    #80
    we_i           = 1'b0;
    strobe_i       = 1'b0;    
    address_i      = 8'd0;
    data_i         = 8'd0;    
end
//*******************************************************************
//inst
mdio_driver U(
.clk(clk),
.rst_n(rst_n),
.eth_mdc(eth_mdc),
.eth_mdio(eth_mdio),
.eth_rst_n(eth_rst_n),
//
.start(start),
.is_rd(is_rd),
.phy_addr(phy_addr),
.reg_addr(reg_addr),
.wr_data(wr_data),
.rd_data(rd_data),
.o_vld(o_vld)
    );

mdio_slave_interface V
( 
.rst_n_i(rst_n), 
.mdc_i(eth_mdc), 
.mdio(eth_mdio), 
//wishbone interface 
.clk_i(clk_i), 
.rst_i(rst_i), 
.address_i(address_i),		//Address signal OK 
.data_i(data_i),		    //Data input signal OK
.data_o(data_o),			//Data output signal OK 
.strobe_i(strobe_i),		//Selection pass signal OK 
.we_i(we_i),			//Write enable signal OK 
.ack_o() 
); 
endmodule
