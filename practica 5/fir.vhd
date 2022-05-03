--------------------------------------------------------------------------------
--
-- Title       : 	FIR filter
-- Design      :	
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : fir.vhd
-- Generated   : 03 May 2022
--------------------------------------------------------------------------------
-- Description : Problema 2.4 Arbitro prioridad dinamica
-- Enunciado   :
-- FIR 8 bit filter with four stages
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 03/05/22  :| First version

-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
port (
	clk		:in std_logic;
	rst		:in std_logic;
	-- Coeficientes
	beta1	:in std_logic_vector(7 downto 0);
 	beta2	:in std_logic_vector(7 downto 0);
	beta3	:in std_logic_vector(7 downto 0);
	beta4	:in std_logic_vector(7 downto 0);
	-- Data input 8 bit
	i_data 	:in std_logic_vector(7 downto 0);
	-- Filtered data
	o_data 	:out std_logic_vector(9 downto 0)
	);
end fir_filter;

architecture Behavioral of fir_filter is

type t_data_pipe      is array (0 to 3) of signed(7  downto 0); --Array de 4 para 
type t_coeff          is array (0 to 3) of signed(7  downto 0); --Array de 4 para los coeficientes
type t_mult           is array (0 to 3) of signed(15    downto 0); --Array de 4 para las multiplicaciones
type t_add_st0        is array (0 to 1) of signed(15+1  downto 0); --Array de 2 para la suma de los dos datos
--Signals porque los datos van a cambiar todo el rato
signal r_coeff              : t_coeff ;  --Variable para almacenar los coeficientes
signal p_data               : t_data_pipe; --Variable para almacenar los datos de inputs, los xn y x(n-1)
signal r_mult               : t_mult; -- Resultado de la multiplicación
signal r_add_st0            : t_add_st0; --Resultado de las dos primeras sumas
signal r_add_st1            : signed(15+2  downto 0); --Resultado de la ultima suma

begin

p_input : process (rst,clk)
begin

  if(rst='0') then
    p_data       <= (others=>(others=>'0'));
    r_coeff      <= (others=>(others=>'0'));
  elsif(rising_edge(clk)) then --Pasamos a signed los coeficientes para hacer la multiplicación mas sencilla
    p_data      <= signed(i_data)&p_data(0 to p_data'length-2); 
    r_coeff(0)  <= signed(beta1);
    r_coeff(1)  <= signed(beta2);
    r_coeff(2)  <= signed(beta3);
    r_coeff(3)  <= signed(beta4);
  end if;
end process p_input;

p_mult : process (rst,clk) --Proceso para hacer la multiplicación
begin

  if(rst='0') then
    r_mult <= (others=>(others=>'0'));
  elsif(rising_edge(clk)) then
    for k in 0 to 3 loop
      r_mult(k) <= p_data(k) * r_coeff(k); --Multiplicación de cada input por su correspondiente beta
    end loop;
  end if;
end process p_mult;

p_add_st0 : process (rst,clk) --Proceso para sumar (xn b1 y x[n-1] b2) y (x[n-2] b3 y x[n-3] b4)
begin

  if(rst='0') then
    r_add_st0     <= (others=>(others=>'0'));
  elsif(rising_edge(clk)) then --loop que suma las salidas (1 y 2) y (3 y 4)
    for k in 0 to 1 loop
      r_add_st0(k)     <= resize(r_mult(2*k),17)  + resize(r_mult(2*k+1),17);
    end loop;
  end if;
end process p_add_st0;

p_add_st1 : process (rst,clk) --Proceso para sumar los dos operandos que quedan
begin

  if(rst='0') then
    r_add_st1     <= (others=>'0');
  elsif(rising_edge(clk)) then
    r_add_st1     <= resize(r_add_st0(0),18)  + resize(r_add_st0(1),18); --Suma los resultados anteriores
  end if;
end process p_add_st1;

p_output : process (rst,clk) --Proceso para igualar el output
begin

  if(rst='0') then
    o_data     <= (others=>'0');
  elsif(rising_edge(clk)) then
    o_data     <= std_logic_vector(r_add_st1(17 downto 8)); --Cojemos los 10 primeros bits del resultado
  end if;
end process p_output;

end Behavioral;


