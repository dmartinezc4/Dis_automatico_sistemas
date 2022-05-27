--------------------------------------------------------------------------------
--
-- Title       : 	Debounce Logic module
-- Design      :	
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : debouncer.vhd
-- Generated   : 7 February 2022
--------------------------------------------------------------------------------
-- Description : Given a synchronous signal it debounces it.
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 07/02/22  :| First version

-- -----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity debouncer is
    generic(
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic; -- asynchronous reset, low -active
        clk         : in    std_logic; -- system clk
        ena         : in    std_logic; -- enable must be on 1 to work (kind of synchronous reset)
        sig_in      : in    std_logic; -- signal to debounce
        debounced   : out   std_logic  -- 1 pulse flag output when the timeout has occurred
    ); 
end debouncer;


architecture Behavioural of debouncer is 
      
    -- Calculate the number of cycles of the counter (debounce_time * freq), result in cycles
    constant c_cycles           : integer := integer(g_timeout * g_clock_freq_KHZ) ;
	-- Calculate the length of the counter so the count fits
    constant c_counter_width    : integer := integer(ceil(log2(real(c_cycles))));
    
    -- -----------------------------------------------------------------------------
    type state_type is (idle,btn_prs,valid,btn_unprs);--estados
	signal current_state,next_state: state_type;--registros de estados
	signal counter: unsigned(c_counter_width-1 downto 0);-- contador
	signal time_elapsed: std_logic;--ha pasado el tiempo
    -- -----------------------------------------------------------------------------
    
    
begin
    --Timer
    process (clk, rst_n)
    begin
    -- -----------------------------------------------------------------------------
	-- Completar el timer que genera la señal de time_elapsed para trancionar en las maquinas de estados
	if(rst_n='0') then
	    time_elapsed<='0';
        counter<=(others=>'0');	
	
	elsif(rising_edge(clk))then			
			if(counter < to_unsigned(c_cycles,counter'length))then
				counter<=counter+1;
				
			else
				time_elapsed<='1';
				counter<=(others=>'0');
			end if;
			
	end if;
	
	-- -----------------------------------------------------------------------------
    end process;

    --FSM Register of next state
    process (clk, rst_n)
    begin
  
    if(rst_n ='0') then
        current_state<=idle;
	elsif(rising_edge(clk)) then
			current_state<=next_state;
    end if; 
    end process;
	
    process (current_state,sig_in,rst_n,ena)--sensitivity list)
    begin
		case current_state is
			when idle => --idle
					debounced<='0';
					if(sig_in='1') then
						next_state<=btn_prs;
					elsif(rst_n='0') then
						next_state<=idle;
					end if;
			when btn_prs => --btn_prs
				debounced<='0';
				
				if(ena='0') then
					next_state<=idle;
					
				elsif(time_elapsed<='0') then
					next_state<=btn_prs;
					
				elsif(time_elapsed<='1' and sig_in<='0')then
					next_state<=idle;
				elsif(time_elapsed<='1' and sig_in<='1') then
					next_state<=valid;
				end if;
			when valid => --valid
				debounced<='1';
				if(ena<='0')then 
					next_state<=idle;
				elsif(sig_in<='0')then
					next_state<=btn_unprs;
				end if;
			when btn_unprs => --btn_unprs
				debounced<='0';
				if(time_elapsed<='0')then
					
					next_state<=btn_unprs;
				elsif(ena='0' or time_elapsed<='0') then
					next_state<=idle;
				end if;			
			when others=>
				next_state<=idle;debounced<='0';
		end case;		      
    end process;
end Behavioural;