-- registre contenant les commandes pour les peripheriques 
-- author : De Ryck & Marinx
-- update : 31.01.2013 : ajout des odomètres
-- update : 01.02.2013 : ajout sens de rotation des moteurs 
-- update : 01.02.2013 : stock les signaux de commande moteurs sur 1 bit (98)
-- update : 15.03.2013 : ajout des capteurs ultrasons
-- update : 22.03.2013 : changement de l'assignation des adresses pour une meilleure structure
--
-- liste des adresses :
-- 	Registre Global [0 -> 9]
-- 	0		: adresse test, reponse => x"AA"
-- 	1     : adresse start
--		2 		: adresse reset
--		3		: adrFunnyParty   [!!]
--    4     : startRobot
--
-------------------------------------------
--		Registres Odomètres [10 -> 19]
--
--		10,11,12 : Odocounter1
--		13,14,15 : Odocounter2
--		16,17,18 : erreurDiffOdometre
--
-------------------------------------------
--		Registres IR [20 -> 29]
--
--
-------------------------------------------
--		Registres US [30 -> 39]
--		30				: detect1
--    31				: detect2   
--		32				: detect3	
--		33				: detect4
--		34				: trigger1
--		35				: trigger2
-- 	36				: trigger3
-- 	37				: trigger4
--		38				: ResetUS
--
-------------------------------------------
--		Registres Moteurs [50 -> 69]
--		50 		: sense Gauche
--		51 		: sense Droit 
--		52-53-54 : distance
-- 	55			: startMoteur
--		56			: readyMoteur1
--    57			: readyMoteur2
--		58			: DutyCycleEn
--		59			: Movement
-- 
-------------------------------------------
--		Registres Servomoteurs [70 -> 89]
--		70			: SequenceServo
--		71			: EnCoursServo
-- 	72			: ResetServo
--
-------------------------------------------
--		Registres Switch [90 -> 99]
--		90			: Switch1   gauche
--		91			: Switch2	droite
--		92			: Switch3	arrière
--
-------------------------------------------
--		Registres Capteur IR [100 -> 109]
--		100			: CapteurIR1   
--		101			: CapteurIR2	
--
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is 
	port (
		i_clk          : in  std_logic;
		i_rst          : in  std_logic;
		i_reg_address  : in  std_logic_vector(6 downto 0);
		o_reg_data_rd  : buffer std_logic_vector(7 downto 0);
		i_reg_data_wr  : in  std_logic_vector(7 downto 0);
		i_reg_rd_en    : in  std_logic;
		i_reg_wr_en    : in  std_logic;
		
		--commande driver
		o_cs_pwm1		: buffer  std_logic;
		duty_pwm1		: buffer  std_logic_vector(7 downto 0);
		o_cs_pwm2		: buffer  std_logic;
		duty_pwm2		: buffer  std_logic_vector(7 downto 0);
		
		--save odomètres
		Odocounter1, Odocounter2 : in signed(23 downto 0);
		erreurDiffOdometre 		 : in std_logic_vector(23 downto 0);
		
		reset_RPI : buffer std_logic;
		rotation  : buffer std_logic;
		
		-- Sens de rotation des moteurs 1 et 2 
		sense1,sense2 : buffer std_logic;
		distance      : buffer signed(23 downto 0);
		startMoteur   : buffer std_logic;
		readyMoteur1  : in std_logic;
		readyMoteur2  : in std_logic;
		DutyCycleEn   : buffer std_logic;
		Movement		  : buffer unsigned(1 downto 0);
		
		-- sauve la valeur de l'utrason
		detect1  	  : in std_logic_vector(1 downto 0);
		detect2  	  : in std_logic_vector(1 downto 0);
		detect3  	  : in std_logic_vector(1 downto 0);
		detect4  	  : in std_logic_vector(1 downto 0);
      trigger1  	  : in std_logic;
		trigger2  	  : in std_logic;
		trigger3  	  : in std_logic;
		trigger4  	  : in std_logic;
		ResetUS		  : buffer std_logic;
		
		--Capteurs IR
		CapteurIR1 	  : in std_logic;
		CapteurIR2    : in std_logic;
		
		--Servomoteurs
		SequenceServo : buffer std_logic_vector(2 downto 0);
		EnCoursServo  : in std_logic;
		ResetServo	  : buffer std_logic;
		
		--Switchs
		Switch1		  : buffer std_logic;
		Switch2		  : buffer std_logic;
		Switch3		  : buffer std_logic;
		
		--Timer
		startRobot    : buffer std_logic
		);
end registers;

architecture rtl of registers  is

	signal s_test_reg : std_logic_vector(7 downto 0);
	
	signal cs_pwm1_sign : std_logic;
	signal duty_pwm1_sign : std_logic_vector(7 downto 0);
	signal cs_pwm2_sign : std_logic;
	signal duty_pwm2_sign : std_logic_vector(7 downto 0);
	
	signal rotation_signal : std_logic; 
	signal start : std_logic;
	signal funyParty : std_logic;
	signal reset_RPI_signal : std_logic;
	signal sense1_sign : std_logic;
	signal sense2_sign : std_logic;
	signal startMoteur_sign : std_logic;
	signal DutyCycleEn_sign : std_logic;
	signal distance_sign : std_logic_vector(23 downto 0);
	signal SequenceServo_signal : std_logic_vector(2 downto 0);
	signal ResetServo_signal : std_logic;
	signal Movement_signal : std_logic_vector(1 downto 0);
	signal Odocounter1_signal : std_logic_vector(23 downto 0);
	signal Odocounter2_signal : std_logic_vector(23 downto 0);
	
	signal startRobot_signal : std_logic;
	
	signal ResetUS_signal : std_logic;
	
begin

	Odocounter1_signal <= std_logic_vector(Odocounter1);
	Odocounter2_signal <= std_logic_vector(Odocounter2);

	process (i_clk, i_rst)
	begin
		if (i_rst='1') then   --gestion du reset
			o_reg_data_rd <= (others=>'0');
			s_test_reg    <= (others=>'0');
			duty_pwm1_sign <= (others=>'0');
			duty_pwm2_sign <= (others=>'0');
			cs_pwm1_sign <= '0';
			cs_pwm2_sign <= '0';
			funyParty <= '0';
			start <= '0';
			sense1_sign <='0';
			sense2_sign <= '0';
			startMoteur_sign <= '0';
			DutyCycleEn_sign <= '0';
			distance_sign <= (others=>'0');
			reset_RPI_signal <= '0';
			rotation_signal <= '0';
			SequenceServo_signal <= (others=>'0');
			Movement_signal <= (others=>'0');
			startRobot_signal <= '0';
			ResetServo_signal <= '0';
			ResetUS_signal <= '0';
			
			
		elsif (rising_edge(i_clk)) then -- sur chaque flanc montant
			if (i_reg_rd_en='1') then  -- si on veut lire
				case to_integer(unsigned(i_reg_address)) is 
				   --commande générale
					when 0 =>
						o_reg_data_rd <= x"AA";
					when 1 => 
						o_reg_data_rd <= "0000000"&start;
					when 2 =>
						o_reg_data_rd <= "0000000"&reset_RPI_signal;
					when 3 =>
						o_reg_data_rd <= "0000000"&funyParty;		
					when 4 =>
						o_reg_data_rd <= "0000000"&startRobot_signal;
					
					when 10 => 
						o_reg_data_rd <= Odocounter1_signal(23 downto 16);
					when 11 => 
						o_reg_data_rd <= Odocounter1_signal(15 downto 8);
					when 12 =>
						o_reg_data_rd <= Odocounter1_signal(7 downto 0);
					
					when 13 => 
						o_reg_data_rd <= Odocounter2_signal(23 downto 16);
					when 14 => 
						o_reg_data_rd <= Odocounter2_signal(15 downto 8);
					when 15 =>
						o_reg_data_rd <= Odocounter2_signal(7 downto 0);
					when 16 =>
						o_reg_data_rd <= erreurDiffOdometre(23 downto 16);
					when 17 => 
						o_reg_data_rd <= erreurDiffOdometre(15 downto 8);
					when 18 =>
						o_reg_data_rd <= erreurDiffOdometre(7 downto 0);
						
					-- capteur ultrason
					when 30 => 
						o_reg_data_rd <= "000000"&detect1(1 downto 0);
					when 31 => 
						o_reg_data_rd <= "000000"&detect2(1 downto 0);
					when 32 => 
						o_reg_data_rd <= "000000"&detect3(1 downto 0);
					when 33 => 
						o_reg_data_rd <= "000000"&detect4(1 downto 0);
					when 34 => 
						o_reg_data_rd <= "0000000"&trigger1;
					when 35 => 
						o_reg_data_rd <= "0000000"&trigger2;
					when 36 => 
						o_reg_data_rd <= "0000000"&trigger3;
					when 37 => 
						o_reg_data_rd <= "0000000"&trigger4;
					when 38 =>
						o_reg_data_rd <= "0000000"&ResetUS;
						
					--moteurs
					when 50 =>
						o_reg_data_rd <= "0000000"&sense1_sign;
					when 51 =>
						o_reg_data_rd <= "0000000"&sense2_sign;
					when 52 => 
						o_reg_data_rd <= distance_sign(23 downto 16);
					when 53 =>
						o_reg_data_rd <= distance_sign(15 downto 8);
					when 54 =>
						o_reg_data_rd <= distance_sign(7 downto 0);
					when 55 => 
						o_reg_data_rd <= "0000000"&startMoteur_sign;
					when 56 => 
						o_reg_data_rd <= "0000000"&ReadyMoteur1;
					when 57 => 
						o_reg_data_rd <= "0000000"&ReadyMoteur2;
					when 58 =>
						o_reg_data_rd <= "0000000"&DutyCycleEn_sign;
						
					--Servomoteurs
					when 71 =>
						o_reg_data_rd <= "0000000"&EnCoursServo;
						
					--Switchs
					when 90 =>
						o_reg_data_rd <= "0000000"&Switch1;
					when 91 =>
						o_reg_data_rd <= "0000000"&Switch2;
					when 92 =>
						o_reg_data_rd <= "0000000"&Switch3;
						
					--Capteur IR
					when 100 =>
						o_reg_data_rd <= "0000000"&CapteurIR1;
					when 101 =>
						o_reg_data_rd <= "0000000"&CapteurIR2;
						
					--Autres
					when others =>
						o_reg_data_rd <= s_test_reg;  -- lis la valeur a n'importe quelle adresse
				end case;
				
			elsif (i_reg_wr_en='1') then
				case to_integer(unsigned(i_reg_address)) is		
					-- global
					when 1 =>  
							start <= i_reg_data_wr(0);
					when 2 => 
							reset_RPI_signal <= i_reg_data_wr(0);
					when 3 => 
							funyParty <= i_reg_data_wr(0);
					when 4 =>
							startRobot_signal <= i_reg_data_wr(0);
					
					when 38 =>
							ResetUS_signal <= i_reg_data_wr(0);
					
					-- pour moteurs 
					when 50 =>  
						sense1_sign <= i_reg_data_wr(0);
					when 51 => 
						sense2_sign <= i_reg_data_wr(0);
					when 52 => 
						distance_sign(23 downto 16) <= i_reg_data_wr;
					when 53 =>
						distance_sign(15 downto 8) <= i_reg_data_wr;
					when 54 => 
						distance_sign(7 downto 0) <= i_reg_data_wr;
					when 55 =>
						startMoteur_sign <= i_reg_data_wr(0);
					when 58 =>
						DutyCycleEn_sign <= i_reg_data_wr(0);
					when 59 =>
						Movement_signal <= i_reg_data_wr(1 downto 0);
					when 70 =>
						SequenceServo_signal <= i_reg_data_wr(2 downto 0);
					when 72 =>
						ResetServo_signal <= i_reg_data_wr(0);
					when others =>
						s_test_reg <= i_reg_data_wr;
				end case;
			end if;
		end if;
	end process;
	
	sense1 <= sense1_sign;
	sense2 <= sense2_sign;
	distance <= signed(distance_sign);
	startMoteur <= startMoteur_sign;
	DutyCycleEn <= '1';--DutyCycleEn_sign;
	Movement <= unsigned(Movement_signal);
	
	duty_pwm1 <= duty_pwm1_sign;
	o_cs_pwm1 <= cs_pwm1_sign;
	
	duty_pwm2 <= duty_pwm2_sign;
	o_cs_pwm2 <= cs_pwm2_sign;
	
	reset_RPI <= reset_RPI_signal;
	
	SequenceServo <= SequenceServo_signal;
	ResetServo <= ResetServo_signal;
	startRobot <= startRobot_signal;
	
	rotation <= '1';
	
	ResetUS <= ResetUS_signal;
end architecture;
