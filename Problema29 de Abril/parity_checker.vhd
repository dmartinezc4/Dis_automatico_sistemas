--------------------------------------------------------------------------------
--
-- Title       : 	Parity checker with genric size and type of parity
-- Design      :	
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : parityChecker.vhd
-- Generated   : 06 April 2022
--------------------------------------------------------------------------------
-- Description : Parity Checker
-- Checks the parity generic to set the size of the word and the type of parity
-- Definition of odd parity: The number of '1' in the word plus the parity bit 
--								adds to an odd number
-- Definition even: The number of '1' in the word plus the parity bit adds to an
--						even number.		
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 06/04/22  :| First version

-- -----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parity_checker is
	generic(
		g_size_word		: integer := 8; --Number of bytes to check parity
		g_parity_type	: std_logic := '0' -- '0' for even '1' for odd
	);
	port(
		input_bits 	: in std_logic_vector(g_size_word-1 downto 0);
		parity 		: out std_logic
	);
end parity_checker;

architecture rtl of parity_checker is 
	signal internal_result : std_logic_vector(g_size_word downto 0); -- 1 bit larger than 
	-- the word so both parities canb be checked.
begin
	process(input_bits, internal_result)
	begin
		-- If we set the value of the first internal result to 0  we will get the result for 
		-- even parity as it will result 1 only if the number of '1' is even
		internal_result(0) <=  g_parity_type;
		parity_combinational : for i in 0 to g_size_word-1 loop
			--Cascade xor
			internal_result(i+1) <= internal_result(i) xor input_bits(i); 
		end loop;
		parity <= internal_result(g_size_word); --Asign the last result
	end process;
end rtl;
