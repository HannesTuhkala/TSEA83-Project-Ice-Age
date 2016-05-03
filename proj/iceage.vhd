entity iceage
	port (
		clk : in std_logic;
		joystick: in std_logic_vector(7 downto 0);
		rst : out unsigned(10 downto 0);
		vgaRed: out std_logic_vector(2 downto 0);
		vgaGreen : out std_logic_vector(2 downto 0);
		vgaBlue : out std_logic_vector(2 downto 1);
		Hsync : out std_logic;
		Vsync : out std_logic);
end iceage;

architecture behavioral of iceage is

	component cpu
		port (
			clk : in std_logic;
			playerXYD: out std_logic_vector(7 downto 0); --TRANSISTION
			playerXYR: out std_logic_vector(7 downto 0);
			joystick : in std_logic_vector(7 downto 0);
			mapm_address : in std_logic_vector(7 downto 0);
			tile : out std_logic_vector(1 downto 0));
	end component cpu;
	
	component VGA_MOTOR
		port (
			clk : in std_logic;
			playerCoordRough in : std_logic_vector(7 downto 0);
			playerCoordDetailed in : std_logic_vector(7 downto 0);
			tileSlot: out std_logic_vector(7 downto 0);
			addr : out unsigned(10 downto 0);
			vgaRed : out std_logic_vector(2 downto 0);
			vgaGreen : out std_logic_vector(2 downto 0);
			vgaBlue : out std_logic_vector(2 downto 1);
			Hsync : out std_logic;
			Vsync : out std_logic);
			tileType : in std_logic_vector(1 downto 0);
	end component graphic;
	
	signal  mapLink: std_logic_vector(7 downto 0); -- mapmlinks with tileslot
	signal playerDlink : std_logic_vector(7 downto 0);
	signal playerRlink : std_logic_vector(7 downto 0);
	signal tileLink : std_logic_vector(1 downto 0);
	
begin
	MAP1 : cpu port map(clk=>clk, joystick=>joystick, mapm_address => mapLink, playerXYD => playerDlink, playerXYR => playerRlink, tile=>tileLink);
	MAP2 : VGA_MOTOR port map(clk=>clk,Hsync=>Hsync, Vsync=>Vsync, vgaRed=>vgaRed, vgaGreen => vgaGreen, vgaBlue=>vgaBlue, tileSlot => mapLink, playerCoordRough=> playerRlink,playerCoordDetailed=>playerDlink, tileType=>tileLink);

end behavioral;
