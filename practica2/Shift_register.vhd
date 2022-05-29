----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.05.2022 13:50:45
-- Design Name: 
-- Module Name: Shift_register - Behavioral
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

entity Shift_register is
    generic(g_n:integer:=8
    );
    port ( clk: in std_logic;
           rst_n: in std_logic;
           s0,s1: in std_logic;
           din: in std_logic_vector(g_n-1 downto 0);          
           dout: out std_logic_vector(g_n-1 downto 0)
           );
end Shift_register;

architecture Behavioral of Shift_register is    
    begin   
    
    process (clk,rst_n)
    
        variable reg: std_logic_vector(g_n-1 downto 0) := (others =>'0');
        begin
        
            if(rst_n='0')then
               reg:=(others =>'0');
            elsif(rising_edge(clk))then
                if(s0='0' and s1='0')then       --no cambios
                    reg:=reg;
                    
                elsif(s0='0' and s1='1') then   --rotar a derecha
                    reg:=reg(g_n-1 downto 1);
                    
                elsif(s0='1' and s1='0') then   --rotar a izquierda
                    reg:=reg(g_n-2 downto 0);
                    
                elsif(s0='1' and s1='1') then   --cargar en paralelo 
                    reg:=din;
               
                end if;               
                
            end if;
            dout<=reg;    
    end process;    
    
end Behavioral;
