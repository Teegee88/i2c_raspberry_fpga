-- Plus gros test bench qui au lieu d'instancier seulement un composants
-- I2C_slave, va instancier un composant TOP, qui contient ce dernier 
-- ainsi qu'un composant RAM
-- Je vais donc reprendre tout le test bench initial, mais lui rajouter
-- la fonction de lire et/ou écrire dans la RAM
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
------------------------------------------------------------------------
entity TOP_TB is
end TOP_TB;
------------------------------------------------------------------------

architecture top_bench of TOP_TB is

begin
------------------------------------------------------------------------
-- DUT ou association composants
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Initialisation et process
------------------------------------------------------------------------

end architecture;

