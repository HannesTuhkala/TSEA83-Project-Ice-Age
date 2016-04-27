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
			playerXY : out std_logic_vector(7 downto 0);
			playerTransition : out std_logic_vector(7 downto 0);
			joystick : in std_logic_vector(7 downto 0);
			tile : out std_logic_vector(1 downto 0);
			 : out ???);
	end component cpu;
	
	component VGA_MOTOR
		port (
			clk : in std_logic;
			addr : out unsigned(10 downto 0);
			vgaRed : out std_logic_vector(2 downto 0);
			vgaGreen : out std_logic_vector(2 downto 0);
			vgaBlue : out std_logic_vector(2 downto 1);
			Hsync : out std_logic;
			Vsync : out std_logic);
	end component graphic;
	
	signal x : ???;
	
begin
	U0 : cpu port map(clk=>clk, a2=>x);
	U1 : graphic port map(b1=>x, b2=>c2, b3=>c3);

end behavioral;
