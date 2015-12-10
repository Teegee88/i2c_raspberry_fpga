library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ROM is
	generic(
		DATA_SIZE = integer := 8;
		ADDRESS_SIZE = integer := 2
	);
	port (
		clk: in std_logic;
		-- Pour l'instant on va considérer que 8 adresses contenant les différentes informations
		adr: in STD_LOGIC_VECTOR(ADDRESS_SIZE downto 0);
		-- Data to be read or written at the adress
		datain: in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
		dataout: out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0));
end;

architecture rtl_ROM of ROM is
begin
	process (clk, adr) begin
		if rising_edge(clk) then
			
-- Premier essay pas bon	
--		case adr is
--			when "00" => dout <= "011";
--			when "01" => dout <= "110";
--			when "10" => dout <= "100";
--			when "11" => dout <= "010";
--		end case;
	end process;
end;