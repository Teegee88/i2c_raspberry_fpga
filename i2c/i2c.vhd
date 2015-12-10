library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use std.textio.all;
   use work.txt_util.all;

entity myI2cEchoTest is
   port (
      scl               : inout std_logic;
      sda               : inout std_logic;
      clk               : in    std_logic;
      rst               : in    std_logic
      );
end myI2cEchoTest;

architecture RTL of myI2cEchoTest is

signal read_req         : std_logic                      := '0';
signal data_to_master   : std_logic_vector (7 downto 0)  := "01010101";
signal data_valid       : std_logic                      := '0';
signal data_from_master : std_logic_vector (7 downto 0)  := (others => '0');
signal data_reg: std_logic_vector (7 downto 0);

component I2C_slave is
  generic (
    SLAVE_ADDR          : std_logic_vector(6 downto 0)   := "0000000"); -- I added := "0000000" to get it to compile
  port (
    scl                 : inout std_logic;
    sda                 : inout std_logic;
    clk                 : in    std_logic;
    rst                 : in    std_logic;
    -- User interface
    read_req            : out   std_logic;
    data_to_master      : in    std_logic_vector(7 downto 0);
    data_valid          : out   std_logic;
    data_from_master    : out   std_logic_vector(7 downto 0));
end component I2C_slave;

begin

i2cSlave: I2C_slave 
   generic map (
      SLAVE_ADDR => "0000011"
      )
   port map(
      scl               => scl,
      sda               => sda,
      clk               => clk,
      rst               => rst,
      -- User interface
      read_req          => read_req,
      data_to_master    => data_to_master,
      data_valid        => data_valid,
      data_from_master  => data_from_master
      );
    
process (clk) 
   
begin
   
if rising_edge(clk) then
   if data_valid = '1' then
      data_to_master <= std_logic_vector(unsigned(data_from_master) + 1);
      end if;
   end if;
      
end process;
    
end architecture rtl;