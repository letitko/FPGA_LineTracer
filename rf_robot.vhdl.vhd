
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity rf_robot is
    Port ( rstb : in std_logic;
			  seg : out  STD_LOGIC_VECTOR (6 downto 0);
           clk_4m : in std_logic;
           rf_data : in std_logic_vector(2 downto 0);
           mtl : out std_logic_vector(3 downto 0);
           mtr : out std_logic_vector(3 downto 0));
   
end rf_robot;

architecture Behavioral of rf_robot is

signal tire : std_logic;
signal tire2 : std_logic;

signal mtl_speed : std_logic_vector(1 downto 0);
signal mtr_speed : std_logic_vector(1 downto 0);
signal speed_l : integer range 0 to 250000;
signal speed_r : integer range 0 to 250000;
signal motor_lcnt : integer range 0 to 250000;
signal phase_lclk : std_logic;
signal motor_rcnt : integer range 0 to 250000;
signal phase_rclk : std_logic;
signal phase_lcnt : std_logic_vector(1 downto 0);
signal phase_lout : std_logic_vector(3 downto 0);
signal phase_rcnt : std_logic_vector(1 downto 0);
signal phase_rout : std_logic_vector(3 downto 0);

begin

	process(rf_data)
  	constant segment1 : std_logic_vector(6 downto 0) := "0000110"; -- 7seg 1표시
	constant segment2 : std_logic_vector(6 downto 0) := "1011011"; -- 7seg 2표시
	constant segment3 : std_logic_vector(6 downto 0) := "1001111"; -- 7seg 3표시
	constant segment4 : std_logic_vector(6 downto 0) := "1100110"; -- 7seg 4표시
	constant segment5 : std_logic_vector(6 downto 0) := "1101101"; -- 7seg 5표시
	constant segment6 : std_logic_vector(6 downto 0) := "1111101"; -- 7seg 6표시
	constant segment7 : std_logic_vector(6 downto 0) := "0100111"; -- 7seg 7표시
	constant segment8 : std_logic_vector(6 downto 0) := "1111111"; -- 7seg 8표시

	begin

			case rf_data is
				when "001" => -- 후진
					tire <= '0';
					tire2 <= '0';
 					mtl_speed <= "11";
					mtr_speed <= "11";
					seg	<= segment2;
				when "010" => -- 좌제자리
					tire2 <= '1';
					tire  <= '0';
					mtl_speed <= "11";
					mtr_speed <= "11";
					seg	<= segment3;
				when "011" => -- 좌원
					tire2 <= '1';
					tire  <= '1';
					mtr_speed <= "11";
					mtl_speed <= "10";
					seg	<= segment4;
				when "100" => -- 우제자리
					tire2 <= '0';
					tire  <= '1';
					mtl_speed <= "11";
					mtr_speed <= "11";
					seg	<= segment5;
				when "101" => -- 우원
					tire2 <= '1';
					tire  <= '1';
					mtl_speed <= "11";
					mtr_speed <= "10";
					seg	<= segment6;
				when "110" => -- 전진느리게
					tire2 <= '1';
					tire  <= '1';
					mtl_speed <= "01";
					mtr_speed <= "01";
					seg	<= segment7;
				when "111" => -- 후진느리게
					tire2 <= '0';
					tire  <= '0';
					mtl_speed <= "01";
					mtr_speed <= "01";
					seg	<= segment8;
				when others => -- 직진
					tire2 <= '1';
					tire  <= '1';
					mtl_speed <= "11";
					mtr_speed <= "11";
					seg	<= segment1;
			end case;

	end process;

	process(mtl_speed)

	begin
	
		case mtl_speed is
			when "00" =>
				speed_l <= 1;
			when "01" =>
				speed_l <= 124999;
			when "10" =>
				speed_l <= 62500;
			when "11" =>
				speed_l <= 50000;
			when others =>
				speed_l <= 50000;
		end case;
	
	end process;

	process(mtr_speed)

	begin
	
		case mtr_speed is
			when "00" =>
				speed_r <= 1;
			when "01" =>
				speed_r <= 124999;
			when "10" =>
				speed_r <= 62500;
			when "11" =>
				speed_r <= 50000;
			when others =>
				speed_r <= 50000;
		end case;
	
	end process;

	process(rstb, speed_l, clk_4m, motor_lcnt)

	begin
	
		if rstb = '0' or speed_l = 0 then
			motor_lcnt <= 0;
			phase_lclk <= '0';
		elsif rising_edge(clk_4m) then
			if motor_lcnt >= speed_l then
				motor_lcnt <= 0;
				phase_lclk <= not phase_lclk;
			else
				motor_lcnt <= motor_lcnt + 1;
			end if;
		end if;

	end process;

	process(rstb, speed_r, clk_4m, motor_rcnt)

	begin
	
		if rstb = '0' or speed_r = 0 then
			motor_rcnt <= 0;
			phase_rclk <= '0';
		elsif rising_edge(clk_4m) then
			if motor_rcnt >= speed_r then
				motor_rcnt <= 0;
				phase_rclk <= not phase_rclk;
			else
				motor_rcnt <= motor_rcnt + 1;
			end if;
		end if;

	end process;

	process(rstb, phase_lclk, phase_lcnt)

	begin

		if rstb = '0' then
			phase_lcnt <= (others => '0');
		elsif rising_edge(phase_lclk) then
			phase_lcnt <= phase_lcnt + 1;
		end if;

	end process;

	process(rstb, phase_lcnt)

	begin

		if rstb = '0' then
			phase_lout <= (others => '0');
		else
			case phase_lcnt is
				when "00" => phase_lout <= "1000";
				when "01" => phase_lout <= "0100";
				when "10" => phase_lout <= "0010";
				when "11" => phase_lout <= "0001";
				when others => phase_lout <= "0000";
			end case;
		end if;

	end process;

	process(rstb, phase_rclk, phase_rcnt)

	begin

		if rstb = '0' then
			phase_rcnt <= (others => '0');
		elsif rising_edge(phase_rclk) then
			phase_rcnt <= phase_rcnt + 1;
		end if;

	end process;
	
	process(rstb, phase_rcnt)

	begin

		if rstb = '0' then
			phase_rout <= (others => '0');
		else
			case phase_rcnt is
				when "00" => phase_rout <= "1000";
				when "01" => phase_rout <= "0100";
				when "10" => phase_rout <= "0010";
				when "11" => phase_rout <= "0001";
				when others => phase_rout <= "0000";
			end case;
		end if;

	end process;

	mtl(0) <= phase_lout(0) when tire = '1' else phase_lout(3);
	mtl(1) <= phase_lout(1) when tire = '1' else phase_lout(2);
	mtl(2) <= phase_lout(2) when tire = '1' else phase_lout(1);
	mtl(3) <= phase_lout(3) when tire = '1' else phase_lout(0);

	mtr(0) <= phase_rout(3) when tire2 = '1' else phase_rout(0);
	mtr(1) <= phase_rout(2) when tire2 = '1' else phase_rout(1);
	mtr(2) <= phase_rout(1) when tire2 = '1' else phase_rout(2);
	mtr(3) <= phase_rout(0) when tire2 = '1' else phase_rout(3);

end Behavioral;
