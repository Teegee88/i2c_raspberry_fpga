-- Code tiré de
-- http://www.deathbylogic.com/2013/02/vhdl-ram/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
entity RAM is
	Generic (
		-- Je change les valeurs en fonction du code de I2C_slave
		-- pour matcher les données
		DATA_WIDTH		: integer := 8;
		ADDRESS_WIDTH	: integer := 7
	);
	Port ( 
		Clock 	: in  STD_LOGIC;
      Reset 	: in  STD_LOGIC;
		DataIn 	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Address	: in  STD_LOGIC_VECTOR (ADDRESS_WIDTH - 1 downto 0);
		WriteEn	: in  STD_LOGIC;
		Enable 	: in  STD_LOGIC;
		DataOut 	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
	);
end RAM;
 
architecture Behavioral of RAM is
	-- Enumeration sous forme de tableau de taille (2 ** ADDRESS_WIDTH)X1 (mais on peut mettre dans chaque ligne 
	-- un vecteur de taille (DATA_WIDTH - 1)
	type Memory_Array is array ((2 ** ADDRESS_WIDTH) - 1 downto 0) of STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
	signal Memory : Memory_Array;
begin
 
	-- Read process
	process (Clock)
	begin
		if rising_edge(Clock) then
			if Reset = '1' then
				-- Clear DataOut on Reset
				DataOut <= (others => '0');
			elsif Enable = '1' then
				if WriteEn = '1' then
					-- If WriteEn then pass through DIn
					DataOut <= DataIn;
				else
					-- Otherwise Read Memory
					DataOut <= Memory(to_integer(unsigned(Address)));
				end if;
			end if;
		end if;
	end process;
 
	-- Write process
	process (Clock)
	begin
		if rising_edge(Clock) then
			if Reset = '1' then
				-- Clear Memory on Reset
				for i in Memory'Range loop
					Memory(i) <= (others => '0');
				end loop;
			elsif Enable = '1' then
				if WriteEn = '1' then
					-- Store DataIn to Current Memory Address
					Memory(to_integer(unsigned(Address))) <= DataIn;
				end if;
			end if;
		end if;
	end process;
 
end Behavioral;