Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity iceage is
	port (
		clk : in std_logic;
		Led : out std_logic_vector(7 downto 0);
		rst : in std_logic;
		vgaRed: out std_logic_vector(2 downto 0);
		vgaGreen : out std_logic_vector(2 downto 0);
		vgaBlue : out std_logic_vector(2 downto 1);
		Hsync : out std_logic;
		Vsync : out std_logic);
end iceage;

architecture behavioral of iceage is

	component cpu is
		port (
			clk : in std_logic;
			playerXYD: out std_logic_vector(7 downto 0); --TRANSISTION
			playerXYR: out std_logic_vector(7 downto 0);
			joystick : in std_logic_vector(7 downto 0);
			mapm_address : in std_logic_vector(7 downto 0);
			tile : out std_logic_vector(1 downto 0));
	end component cpu;
	
	component VGA_MOTOR is
		port (
			rst : in std_logic;
			clk : in std_logic;
			playerCoordRough : in std_logic_vector(7 downto 0);
			playerCoordDetailed : in std_logic_vector(7 downto 0);
			tileSlot: out std_logic_vector(7 downto 0);
			vgaRed : out std_logic_vector(2 downto 0);
			vgaGreen : out std_logic_vector(2 downto 0);
			vgaBlue : out std_logic_vector(2 downto 1);
			Hsync : out std_logic;
			Vsync : out std_logic;
			tileType : in std_logic_vector(1 downto 0));
	end component VGA_MOTOR;
	
	signal  mapLink: std_logic_vector(7 downto 0); -- mapmlinks with tileslot
	signal playerDlink : std_logic_vector(7 downto 0);
	signal playerRlink : std_logic_vector(7 downto 0);
	signal tileLink : std_logic_vector(1 downto 0);
	signal tmpCoordD : std_logic_vector(7 downto 0):= "10001000"; 
	signal tmpCoordR : std_logic_vector(7 downto 0):= "00000000";
	signal Joylink : std_logic_vector(7 downto 0):="00000000";
	signal XYBstream : std_logic_vector(3 downto 0):="0000";
	signal counter : std_logic_vector(5 downto 0) := (others => '0');
	
	
begin
	Led<= "11110000";
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			if counter = 39 then
				joylink(3 downto 0) <= XYBstream; 
				counter <= (others => '0');
			elsif counter = 14 then 
			--	XYBstream(3) <= joystickInStream;
			elsif counter = 15 then
			--	XYBstream(2) <= joystickInStream;
			elsif counter = 30 then
			--	XYBstream(1) <= joystickInStream;
			elsif counter = 31 then
			--	XYBstream(0) <= joystickInStream;  
			end if; 	
			counter <= counter + 1;		
		end if;
	END PROCESS;


	MAP1 : cpu port map(clk=>clk, joystick=>joylink, mapm_address => mapLink, playerXYD => playerDlink, playerXYR => playerRlink, tile=>tileLink);
	MAP2 : VGA_MOTOR port map(rst => rst,clk=>clk,Hsync=>Hsync, Vsync=>Vsync, vgaRed=>vgaRed, vgaGreen => vgaGreen, vgaBlue=>vgaBlue, tileSlot => mapLink, playerCoordRough=> tmpCoordR ,playerCoordDetailed=>tmpCoordD, tileType=>tileLink);




end behavioral;
