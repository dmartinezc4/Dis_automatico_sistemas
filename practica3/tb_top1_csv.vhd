----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.05.2022 10:32:41
-- Design Name: 
-- Module Name: tb_top1_csv - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity tb_top1_csv is
end tb_top1_csv;


architecture testBench of tb_top1_csv is

    --File handler
	file file_input : text;
	-- ports for the top
	signal rst_n:      std_logic; -- Reset
	signal clk100Mhz:  std_logic; -- Reloj
	signal BTNC:       std_logic; -- Boton
	signal LED:        std_logic; -- LED
	
    component top_practica1 is
      port (
          rst_n         : in std_logic;
          clk100Mhz     : in std_logic;
          BTNC           : in std_logic;
          LED           : out std_logic
      );
    end component;
    
    constant freq : integer := 100_000; --KHZ
    constant clk_period : time := (1 ms/ freq);
begin

    --Instanciar top
    UUT: top_practica1
        port map (
          rst_n     => rst_n,
          clk100Mhz => clk100Mhz,
          BTNC       => BTNC,
          LED       => LED
        );
        clk100Mhz <= not clk100Mhz after clk_period/2;
proc_sequencer : process
	-- Process to read the data
		file text_file :text open read_mode is "inputs.csv";
		variable text_line : line; -- Current line
		variable ok: boolean; -- Saves the status of the operation of reading
		variable char : character; -- Read each character of the line(used when using comments)
		variable delay: time; -- Saves the desired delay time
		variable data: std_logic; --Generates a variable of the first operand rst_n type (which is the same for the rest)
		variable expected_led: std_logic;
begin 

    while not endfile(text_file) loop
        readline(text_file, text_line);
            -- Skip empty lines and commented lines
            if text_line.all'length = 0 or text_line.all(1) = '#' then
                next;
            end if;
        -- Read the delay time
        read(text_line, delay, ok);
        assert ok
            report "Read 'delay' failed for line: " & text_line.all
            severity failure;
            
        -- Read first operand (rst_n)
        read(text_line, data, ok);
        assert ok
            report "Read 'rst_n' failed for line: " & text_line.all
            severity failure;
        rst_n <= data;
        
         -- Read first operand (BTNC)
        read(text_line, data, ok);
        assert ok
            report "Read 'A' failed for line: " & text_line.all
            severity failure;
        BTNC <= data;
        
        -- Read the second operand (Expected LED value)
        read(text_line, data, ok);
        assert ok
            report "Read 'LED' failed for line: " & text_line.all
            severity failure;
            LED <= data;
            
            -- Wait for the delay
            wait for delay;


            -- Print the comments(if any) to console
			-- Print trailing comment to console, if any
			read(text_line, char, ok); -- Skip expected newline
			read(text_line, char, ok);
			if char = '#' then
				read(text_line, char, ok); -- Skip expected newline
				report text_line.all;
			end if;
			
			--Verify the LED_expected is correct
			expected_led := (rst_n and BTNC);
			
			
			assert expected_led = LED
				report "Unexpected result: " &
					"rst_n = "& std_logic'image(rst_n) & "; "&
					"clk100Mhz = "& std_logic'image(clk100Mhz) & "; "&
					"BTNC = "& std_logic'image(BTNC) & "; "&
					"LED = " & std_logic'image(LED)
				severity error;
			
				
		end loop;
		report "Finished" severity FAILURE; 
end process;

end testBench;
