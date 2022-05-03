library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_rx is
    generic(
        g_baudrate : integer := 10000;
        g_parity_type : std_logic := '0' -- '0' for even '1' for odd
    );
    port(
        rx, clk, rst : in std_logic;
        valid : out std_logic;
        word : out std_logic_vector(7 downto 0)
    );
end UART_rx;

architecture Structural of UART_rx is

component parity_checker
generic(
		g_size_word		: integer := 8; --Number of bytes to check parity
		g_parity_type	: std_logic := '0' -- '0' for even '1' for odd
	);
port(
    input_bits 	: in std_logic_vector(g_size_word-1 downto 0);
    parity 		: out std_logic
);
end component;

component shift_register

end component;

begin
p1:parity_checker
port map (
);

s1:shift_register
port map(
);



end Structural;