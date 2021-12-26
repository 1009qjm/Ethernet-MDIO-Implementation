`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/25 14:43:38
// Design Name: 
// Module Name: mdio_driver
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


module mdio_driver(
input logic clk,
input logic rst_n,
output logic eth_mdc,
inout wire eth_mdio,
output logic eth_rst_n,
//
input logic start,
input logic is_rd,
input logic [4:0] phy_addr,
input logic [4:0] reg_addr,
input logic [15:0] wr_data,
output logic [15:0] rd_data,
output logic o_vld
    );

typedef enum bit[5:0] {
    st_idle,                            //空闲状态
    st_pre,                             //32bit前导码
    st_start,                           //start+op
    st_addr,                            //phy_addr+reg_addr
    st_wr,                              //TA+Write
    st_rd                               //TA+Read
}STATE;

STATE state,next_state;
logic busy;
logic mdio_dir;                          //mdio方向，为1时由MAC驱动，否则由PHY驱动
logic mdo;
logic pre_done;
logic start_done;
logic addr_done;
logic wr_done;
logic rd_done;
logic [31:0] counter;                    //计数器
logic [63:0] data;
logic [15:0] data_recv;
//
assign eth_mdio=(mdio_dir==1'b1)?mdo:1'bz;                        //mdio_dir为1时由MAC驱动，否则挂起
//counter=0-31为st_pre,32-35为start,36-45为addr,46-63为读数据或写数据
assign pre_done=(counter==31)?1:0;
assign start_done=(counter==35)?1:0;
assign addr_done=(counter==45)?1:0;
assign wr_done=(counter==63&&~is_rd)?1:0;
assign rd_done=(counter==63&&is_rd)?1:0;
//state
always_ff@(posedge clk,negedge rst_n)
if(!rst_n)
   state<=st_idle;
else 
   state<=next_state;
//next_state
always_comb
begin
    case(state)
       st_idle:if(start)
                   next_state=st_pre;
               else
                   next_state=st_idle;
       st_pre:if(pre_done)
                   next_state=st_start;
              else
                   next_state=st_pre;
       st_start:if(start_done)
                   next_state=st_addr;
                else
                   next_state=st_start;
       st_addr:if(addr_done)
               begin
                   if(is_rd)
                       next_state=st_rd;
                   else
                       next_state=st_wr;
               end
       st_wr:if(wr_done)
                 next_state=st_idle;
             else
                 next_state=st_wr;
       st_rd:if(rd_done)
                next_state=st_idle;
             else
                next_state=st_rd;
        default:next_state=st_idle;
    endcase 
end
//data
always_ff@(posedge clk,negedge rst_n)
if(!rst_n)
    data<=64'd0;
else if(start)
begin
if(is_rd)
    data<={32'hffffffff,4'b0110,phy_addr,reg_addr,2'b10,16'd0};
else
    data<={32'hffffffff,4'b0101,phy_addr,reg_addr,2'b10,wr_data};
end
else if(busy)
    data<={data[62:0],1'b0};
//mdio_dir
always_comb 
if(state==st_rd||state==st_idle)           //空闲状态，或者读数据时,MAC不驱动MDIO信号
    mdio_dir=1'b0;
else
    mdio_dir=1'b1;
//mdo
always_comb
begin
    mdo=data[63];
end
//busy
always_ff@(posedge clk,negedge rst_n)
if(!rst_n)
   busy<=0;
else if(start)
   busy<=1;
else if(wr_done||rd_done)
   busy<=0;
//counter
always_ff@(posedge clk,negedge rst_n)
if(!rst_n)
   counter<=0;
else if(busy)
begin
    if(wr_done||rd_done)
        counter<=0;
    else
        counter<=counter+1;
end
//data_recv
always_ff@(posedge eth_mdc,negedge rst_n)
if(!rst_n)
    data_recv<=0;
else if(state==st_rd&&counter>47&&counter<=63)
    data_recv<={data_recv[14:0],eth_mdio};                           //高位先读取
//o_vld
always_ff@(posedge clk,negedge rst_n)
if(!rst_n)
    o_vld<=0;
else if(rd_done||wr_done)
    o_vld<=1;
else
    o_vld<=0;
//
assign eth_rst_n=rst_n;
assign eth_mdc=~clk;
assign rd_data=data_recv;
endmodule
