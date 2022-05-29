----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.05.2022 11:42:01
-- Design Name: 
-- Module Name: MEMS - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEMS is
    port (clk: in std_logic;
         lrsel: in std_logic;
         data: out std_logic
         );
end MEMS;

architecture structural of MEMS is

component Shift_register is
    generic(g_n:integer:=8
    );
    port ( clk: in std_logic;
           rst_n: in std_logic;
           s0,s1: in std_logic;
           din: in std_logic_vector(g_n-1 downto 0);          
           dout: out std_logic_vector(g_n-1 downto 0)
           );
end component;

component fsm_sclk is
	generic(
		g_freq_SCLK_KHZ	: integer := 1_500; -- Frequency in KHz of the 
											--synchronous generated clk
		g_system_clock 	: integer := 100_000 --Frequency in KHz of the system clk
	);
	port (
		rst_n		: in std_logic; -- asynchronous reset, low active
		clk 		: in std_logic; -- system clk
		start		: in std_logic; -- signal to start the synchronous clk
		SCLK 		: out std_logic;-- Synchronous clock at the g_freq_SCLK_KHZ
		SCLK_rise	: out std_logic;-- one cycle signal of the rising edge of SCLK
		SCLK_fall	: out std_logic -- one cycle signal of the falling edge of SCLK
	);
end component;


begin


    shift_register_inst:shift_register
        generic map(g_n:integer:=8
        );
        port map( clk: in std_logic;
               rst_n: in std_logic;
               s0,s1: in std_logic;
               din: in std_logic_vector(g_n-1 downto 0);          
               dout: out std_logic_vector(g_n-1 downto 0)
               );


fsm_clk_inst: fsm_sclk
        generic map(
		g_freq_SCLK_KHZ	: integer := 1_500; -- Frequency in KHz of the 
											--synchronous generated clk
		g_system_clock 	: integer := 100_000 --Frequency in KHz of the system clk
	);
	port map(
		rst_n		: in std_logic; -- asynchronous reset, low active
		clk 		: in std_logic; -- system clk
		start		: in std_logic; -- signal to start the synchronous clk
		SCLK 		: out std_logic;-- Synchronous clock at the g_freq_SCLK_KHZ
		SCLK_rise	: out std_logic;-- one cycle signal of the rising edge of SCLK
		SCLK_fall	: out std_logic -- one cycle signal of the falling edge of SCLK
	);




end structural;
