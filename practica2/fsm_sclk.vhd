--------------------------------------------------------------------------------
--
-- Title       : 	FSM for the Synchronous clock
-- Design      :	Synchronous Clock generator
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : fsm_sclk.vhd
-- Generated   : 20 February 2022
--------------------------------------------------------------------------------
-- Description : Generates a synchronous clock (SCLK) and a rising/falling edge 
--				signal (SCLK_rise/ SCLK_fall) it has a negative asynchronous 
--				reset (n_rst) and a generic to indicate the period of the 
-- 				synchronous clock.  
	
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 20/02/22  :| First version

-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;

entity fsm_sclk is
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
end fsm_sclk;

architecture behavioural of fsm_sclk is

	-- Tenéis que hacer la conversion necesaria para sacar la constante que indique
	--	el número de ciclos para medio periodo del SCLK. Debéis usar floor 
	-- para el redondeo (que opera con reales)
	
	--1 Hz = 1 ciclo
	-- f=(1/periodo)   periodo=(1/f)
	
	constant c_cycles : integer :=integer((1/g_freq_SCLK_KHZ)*g_system_clock); --Los ciclos serían el tiempo de este módulo * la frequencia del sistema total
	
	
	constant c_half_T_SCLK : integer := integer((1/g_freq_SCLK_KHZ)*g_system_clock); --constant value to compare and generate the rising/falling edge 
	constant c_counter_width :integer :=integer(floor(log2(real(c_cycles)))); -- the width of the counter, take as reference the debouncer
	
	type state_type is (sclk0,sclk1);                        --Estados  (respectivamente sclk=0 y sclk=1)
	signal current_state,next_state: state_type;       --Cambiar estados
	signal CNT: unsigned(c_counter_width-1 downto 0);  --Contador
	signal time_elapsed: std_logic;                    --Ha pasado el tiempo
	
	begin	
	
	
	process (clk,rst_n) begin --process contador
	   if(rst_n='0') then
	    CNT<=(others=>'0');
	    time_elapsed<='0';
	   elsif(rising_edge(clk))then
	       if(CNT<to_unsigned(c_half_T_SCLK,CNT'length))then
	           CNT<=CNT+1;
	       else
	           time_elapsed<='1';
	           CNT<=(others=>'0');
	       end if;
	    end if;
	    	
	end process;
	
	process (clk,rst_n) begin --Registro de siguiente estado
	if(rst_n='0')then
	   current_state<=sclk0;
    else
        current_state<=next_state;
	end if;
	
	end process;
	
	process (current_state)begin
	   case current_state is
	   
	   when sclk0=>
	       if(time_elapsed<='0')then
	           next_state<=sclk0;
	           sclk_fall<='0';
	       elsif(time_elapsed<='1')then
               next_state<=sclk1;
               sclk_rise<='1';
	       end if;
	   when sclk1=>
	       if(time_elapsed<='0')then
	           next_state<=sclk1;
	           sclk_rise<='0';
	       elsif(time_elapsed<='1')then
               next_state<=sclk0;
               sclk_fall<='1';
	       end if;
	   
	   when others=>
           next_state<=sclk0;
           sclk_fall<='0';
           sclk_rise<='0';
	   end case;
	   --Yo entiendo que pese a que no lo ponga en el pdf cuando hay un fall el rise tiene que acabar y viceversa
	   --Si no estarían ambas a 1 de manera constante rise y fall de sclk
	end process;
	
	
	end behavioural;