-- Top est mon entity qui va comprendre à la fois une RAM et un
-- composant I2C_slave
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
------------------------------------------------------------------------
entity TOP is
	generic (
			DATA_WIDTH		: integer := 8;
			ADDRESS_WIDTH	: integer := 7
	);
	port(
		clkTop 	: in  STD_LOGIC
	);
end TOP;
------------------------------------------------------------------------

architecture toparch of TOP is
	--composant RAM
	component RAM
		generic (
			DATA_WIDTH		: integer := 8;
			ADDRESS_WIDTH	: integer := 7
		);
		port ( 
			Clock 	: in  STD_LOGIC;
			Reset 	: in  STD_LOGIC;
			DataIn 	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
			Address	: in  STD_LOGIC_VECTOR (ADDRESS_WIDTH - 1 downto 0);
			WriteEn	: in  STD_LOGIC;
			Enable 	: in  STD_LOGIC;
			DataOut 	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
		);
	end component;
	--composant I2C_slave
	component I2C_slave
		generic (	
			 SLAVE_ADDR : std_logic_vector(6 downto 0):= "0000000");
		port (
			 scl              : inout std_logic;
			 sda              : inout std_logic;
			 clk              : in    std_logic;
			 rst              : in    std_logic;
			 -- User interface
			 read_req         : out   std_logic;
			 data_to_master   : in    std_logic_vector(7 downto 0);
			 data_valid       : out   std_logic;
			 data_from_master : out   std_logic_vector(7 downto 0)
		);
	end component;
------------------------------------------------------------------------
-- Signaux
------------------------------------------------------------------------
	type Memory_Array is array ((2 ** ADDRESS_WIDTH) - 1 downto 0) of STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
	signal memoryTop : Memory_Array;
-- Address and data received from master
	signal addr_reg : std_logic_vector(6 downto 0) := (others => '0');
	signal data_reg : std_logic_vector(7 downto 0) := (others => '0');
--
	signal read_req : std_logic;
	signal DataOut : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
------------------------------------------------------------------------
begin
------------------------------------------------------------------------
-- DUT ou association composants
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Initialisation et process
------------------------------------------------------------------------
	-- Process qui utilise la méthode de RAM pour aller lire ce qui se 
	-- trouve à l'adresse donnée par le master (ici la Raspberry)
	process (clkTop) is
	begin
		if rising_edge(clkTop) then
			if read_req = '1' then
				DataOut <= memoryTop(to_integer(unsigned(addr_reg)));
			end if;
		end if;
	end process;
	
	
end architecture;