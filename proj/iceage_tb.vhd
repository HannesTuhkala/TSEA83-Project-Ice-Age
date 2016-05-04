library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity iceage_tb is
end iceage_tb;

architecture Behavioral of iceage_tb is

  component iceage
      Port (
  		clk : in STD_LOGIC;
		rst : in std_logic;
		joystick: in std_logic_vector(7 downto 0));
  end component;

  -- Testsignaler
  signal rst : std_logic := '0';
  signal clk : STD_LOGIC := '0';
  signal joystick : std_logic_vector(7 downto 0) := (others=> '0');
begin

  uut: iceage PORT MAP(
    clk => clk,
    joystick => joystick,rst=>rst);
  -- Klocksignal 100MHz
  clk <= not clk after 5 ns;

end;
