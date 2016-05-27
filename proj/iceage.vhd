Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity iceage is
	port (
		Led : out std_logic_vector(7 downto 0);
		btnu : in std_logic;
		btnd : in std_logic;
		btnl : in std_logic;
		btnr : in std_logic;
		btns : in std_logic;
		clk : in std_logic;
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
			buttons : in std_logic_vector(7 downto 0);
			mapm_address : in std_logic_vector(7 downto 0);
			tile : out std_logic_vector(1 downto 0));
	end component cpu;
	
	component VGA_MOTOR is
		port (
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
	signal Buttonlink : std_logic_vector(7 downto 0):="00000000";
	signal XYBstream : std_logic_vector(3 downto 0):="0000";
	signal counter : std_logic_vector(5 downto 0) := (others => '0');
	
begin
	Led <= Buttonlink;
	PROCESS(clk)
	begin
		if (rising_edge(clk)) then
			if btnl='1' then --UP
				Buttonlink(2 downto 0) <= "111";
			elsif btnr='1' then --DOWN
				Buttonlink(2 downto 0) <= "110";
			elsif btnu='1' then --RIGHT
				Buttonlink(2 downto 0) <= "101";
			elsif btnd='1' then -- LEFT
				Buttonlink(2 downto 0) <= "100";
			elsif btns='1' then -- reset pos
				joylink(2 downto 0) <= "010";
			else		-- no button
				Buttonlink(2 downto 0) <= "000";
			end if;
		end if;
	END PROCESS;	

	MAP1 : cpu port map(clk=>clk, buttons=>joylink, mapm_address => mapLink, playerXYD => playerDlink, playerXYR => playerRlink, tile=>tileLink);
	MAP2 : VGA_MOTOR port map(clk=>clk,Hsync=>Hsync, Vsync=>Vsync, vgaRed=>vgaRed, vgaGreen => vgaGreen, vgaBlue=>vgaBlue, tileSlot => mapLink, playerCoordRough=> playerRlink ,playerCoordDetailed=>playerDlink, tileType=>tileLink);

end behavioral;
