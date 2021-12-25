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
//clk
initial begin
    clk=0;
    forever begin
        #5 clk=~clk;
    end
end
//rst_n
initial begin
    rst_n=0;
    #20
    rst_n=1;
end
//start
initial begin
    start=0;
    #100
    start=1;
    #10
    start=0;
    #700
    start=1;
    #10
    start=0;
end
//is_rd
initial begin
    is_rd=1;
    #800
    is_rd=0;
end
//addr
initial begin
    phy_addr=5'b00110;
    reg_addr=5'b00100;
end
//wr_data
initial begin
    wr_data=16'd12;
end

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
endmodule
