library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Decoder is
end Decoder;

architecture Behavioral of VGA_MOTOR_tb is

  component lab
      Port (
  	    clk : in STD_LOGIC;
	    joystick: in std_logic_vector(7 downto 0);
           );
  end component;
  
  type map_t is array(255 downto 0) of std_logic_vector(1 downto 0);
  -- Testsignaler
  signal clk : STD_LOGIC := '0';
  signal joystick : std_logic_vector(7 downto 0) := others '0';
begin

  uut: lab PORT MAP(
    clk => clk,
    joystick => joystick);
  -- Klocksignal 100MHz
  clk <= not clk after 5 ns;


end;
