------------------------------------------------------------------------------
-- VGA MOTOR


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity VGA_MOTOR is
  port ( clk			: in std_logic;
	 playerCoordRough	: in std_logic_vector(7 downto 0);
	 playerCoordDetailed	: in std_logic_vector(7 downto 0);
	 tileSlot		: out std_logic_vector(7 downto 0);
	 tileType		: in std_logic_vector(1 downto 0);

	 vgaRed		        : out std_logic_vector(2 downto 0);
	 vgaGreen	        : out std_logic_vector(2 downto 0);
	 vgaBlue		: out std_logic_vector(2 downto 1);
	 Hsync		        : out std_logic;
	 Vsync		        : out std_logic);
end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

  signal	Xpixel	        : unsigned(15 downto 0);         -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(15 downto 0);		-- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal
		
  signal 	tilePixel       : std_logic_vector(7 downto 0);	-- Tile pixel data
	
	--Sprite memory type
	type sprite_mt is array (0 to 255) of std_logic_vector(7 downto 0);

  signal sprite_mem : sprite_mt := (
		x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"ff", x"ff", x"ff", x"ff", x"ff",
		x"ff", x"ff", x"ff", x"ff", x"00", x"00", x"fe", x"fe", x"fe", x"fe", x"00", x"00", x"ff", x"ff", x"ff", x"ff",
		x"ff", x"ff", x"ff", x"00", x"fe", x"fe", x"fe", x"fe", x"fe", x"fe", x"fe", x"fe", x"00", x"ff", x"ff", x"ff",
		x"ff", x"ff", x"ff", x"00", x"fe", x"00", x"fe", x"fe", x"fe", x"fe", x"00", x"fe", x"00", x"ff", x"ff", x"ff",
		x"ff", x"ff", x"ff", x"fe", x"fe", x"fe", x"fe", x"f0", x"f0", x"fe", x"fe", x"fe", x"fe", x"ff", x"ff", x"ff",
		x"ff", x"ff", x"ff", x"00", x"fe", x"fe", x"f0", x"f0", x"f0", x"f0", x"fe", x"fe", x"00", x"ff", x"ff", x"ff",
		x"ff", x"ff", x"ff", x"ff", x"00", x"fe", x"fe", x"00", x"00", x"fe", x"fe", x"00", x"ff", x"ff", x"ff", x"ff",
		x"ff", x"ff", x"ff", x"00", x"00", x"00", x"fe", x"f0", x"f0", x"fe", x"00", x"00", x"00", x"ff", x"ff", x"ff",
		x"ff", x"ff", x"00", x"00", x"00", x"00", x"fe", x"fe", x"fe", x"fe", x"00", x"00", x"00", x"00", x"ff", x"ff",
		x"ff", x"ff", x"00", x"00", x"00", x"00", x"fe", x"fe", x"fe", x"fe", x"00", x"00", x"00", x"00", x"ff", x"ff",
		x"ff", x"ff", x"00", x"00", x"00", x"00", x"fe", x"fe", x"fe", x"fe", x"00", x"00", x"00", x"00", x"ff", x"ff",
		x"ff", x"ff", x"00", x"00", x"00", x"00", x"fe", x"fe", x"fe", x"fe", x"00", x"00", x"00", x"00", x"ff", x"ff",
		x"ff", x"ff", x"00", x"00", x"00", x"00", x"00", x"fe", x"fe", x"00", x"00", x"00", x"00", x"00", x"ff", x"ff",
		x"ff", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"ff", x"ff",
		x"ff", x"ff", x"ff", x"00", x"00", x"00", x"00", x"ff", x"ff", x"00", x"00", x"00", x"00", x"ff", x"ff", x"ff",
		x"ff", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"ff", x"ff", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"ff"
		);

  -- Tile memory type
  type ram_t is array (0 to 1023) of std_logic_vector(7 downto 0);

-- Tile memory
  signal tileMem : ram_t := (
  		--Ice		code: 00

		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"ff",x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"ff",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"bf",x"9f",
		x"9f",x"ff",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"9f",x"9f",x"9f",
		x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"9f",x"9f",x"9f",x"9f",
		x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",


		--Rock		code: 01
		
		
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"ff",x"ff",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"ff",x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"ff",x"9f",x"9f",x"ff",x"ff",x"ff",x"92",x"ff",x"49",x"9f",x"9f",x"9f",x"bf",x"9f",
		x"9f",x"ff",x"9f",x"9f",x"ff",x"ff",x"92",x"ff",x"92",x"92",x"ff",x"9f",x"9f",x"bf",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"ff",x"ff",x"92",x"92",x"92",x"49",x"92",x"49",x"ff",x"bf",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"49",x"49",x"92",x"92",x"92",x"44",x"92",x"92",x"92",x"49",x"49",x"49",x"9f",x"9f",
		x"9f",x"9f",x"49",x"48",x"ff",x"92",x"92",x"92",x"92",x"ff",x"ff",x"ff",x"6d",x"49",x"49",x"9f",
		x"9f",x"49",x"92",x"92",x"92",x"49",x"92",x"92",x"ff",x"ff",x"ff",x"6d",x"44",x"6d",x"49",x"9f",
		x"49",x"49",x"92",x"92",x"92",x"44",x"92",x"ff",x"ff",x"ff",x"6d",x"6d",x"49",x"6d",x"49",x"9f",
		x"49",x"92",x"49",x"92",x"92",x"92",x"92",x"49",x"6d",x"6d",x"44",x"6d",x"6d",x"6d",x"49",x"49",
		x"49",x"92",x"92",x"49",x"49",x"92",x"92",x"49",x"49",x"49",x"6d",x"49",x"49",x"49",x"49",x"49",
		x"ff",x"ff",x"92",x"ff",x"ff",x"49",x"49",x"6d",x"6d",x"49",x"49",x"49",x"48",x"6d",x"6d",x"49",
		x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"6d",x"6d",x"6d",x"49",x"6d",x"6d",x"6d",x"6d",x"ff",
		x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"9f",x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",x"9f",x"9f",x"9f",x"9f",  
		--Ground	code: 10

		
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",x"9f",
		x"9f",x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",


		  --goal	code: 11 (hard code 11 into any tile address, or a sprite will be drawn there with white background)

		
		x"9f",x"9f",x"49",x"92",x"92",x"92",x"6d",x"6d",x"6d",x"6d",x"6d",x"92",x"6d",x"49",x"9f",x"9f",
		x"9f",x"49",x"92",x"92",x"92",x"6d",x"6d",x"00",x"00",x"6d",x"6d",x"92",x"92",x"6d",x"49",x"9f",
		x"49",x"92",x"92",x"6d",x"6d",x"6d",x"00",x"00",x"00",x"00",x"6d",x"6d",x"92",x"6d",x"49",x"9f",
		x"92",x"92",x"df",x"6d",x"00",x"00",x"00",x"00",x"00",x"00",x"6d",x"6d",x"92",x"92",x"6d",x"49",
		x"92",x"92",x"6d",x"6d",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"6d",x"6d",x"92",x"92",x"49",
		x"92",x"6d",x"6d",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"6d",x"6d",x"92",x"49",
		x"92",x"6d",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"6d",x"6d",x"92",
		x"92",x"6d",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"6d",x"92",
		x"49",x"6d",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"6d",x"92",
		x"49",x"6d",x"00",x"00",x"04",x"04",x"04",x"04",x"04",x"04",x"04",x"04",x"00",x"00",x"6d",x"49",
		x"6d",x"6d",x"00",x"04",x"04",x"04",x"04",x"04",x"04",x"04",x"04",x"04",x"04",x"00",x"49",x"49",
		x"ff",x"ff",x"ff",x"df",x"df",x"df",x"df",x"df",x"df",x"df",x"df",x"df",x"df",x"ff",x"ff",x"ff",
		x"bf",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",
		x"9f",x"9f",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"9f",x"9f",x"9f",x"9f",x"9f",x"ff",x"ff",x"9f",x"9f",x"9f",
		x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"bf",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f",x"9f");
		  
begin

  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
	ClkDiv <= ClkDiv + 1;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	
  -- Horizontal pixel counter

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Xpixel                         *
  -- *                                 *
  -- ***********************************

	process(clk)
	begin
		if rising_edge(clk) then

			if Clk25 = '1' then
				if (Xpixel < 800) then
					Xpixel <= Xpixel + 1;
				else
					Xpixel <= (others => '0');
				end if;
			end if;
		end if;
	end process;

  -- Horizontal sync

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Hsync                          *
  -- *                                 *
  -- ***********************************
  
	Hsync <= '0' when Xpixel > 655 and Xpixel < 752 else '1'; 
 
  -- Vertical pixel counter

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Ypixel                         *
  -- *                                 *
  -- ***********************************

	process(clk)
	begin
		if rising_edge(clk) then

			if Clk25 = '1' then
				if (Xpixel = 799) then
					Ypixel <= Ypixel + 1;
				elsif (Ypixel = 520) then
					Ypixel <= (others => '0');
				end if;
			end if;
		end if;
	end process;

  -- Vertical sync

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Vsync                          *
  -- *                                 *
  -- ***********************************
	
	Vsync <= '0' when Ypixel > 489 and Ypixel < 492 else '1';

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  pixel selection                *
  -- *                                 *
  -- ***********************************
  process(clk)
  begin
    if rising_edge(clk) then
    
      tileSlot(7 downto 4) <= std_logic_vector(Ypixel(7 downto 4) - 7);		-- find tile over which pixel rests
      tileSlot(3 downto 0) <= std_logic_vector(Xpixel(7 downto 4) - 11);		--

      if (Xpixel < 432 and Ypixel < 368 and Xpixel > 175 and Ypixel > 111) then
	if	((to_integer(unsigned(playerCoordRough)) = to_integer(Ypixel(7 downto 4) - 7) * 16  + to_integer(Xpixel(7 downto 4) - 11) and to_integer(unsigned(playerCoordDetailed(7 downto 4))) <= to_integer(Ypixel(3 downto 0)) and to_integer(unsigned(playerCoordDetailed(3 downto 0))) <= to_integer(Xpixel(3 downto 0)) ) or
		 (to_integer(unsigned(playerCoordRough)) + 16 = to_integer(Ypixel(7 downto 4) - 7) * 16 + to_integer(Xpixel(7 downto 4) - 11)	 and to_integer(unsigned(playerCoordDetailed(7 downto 4))) >  to_integer(Ypixel(3 downto 0)) and to_integer(unsigned(playerCoordDetailed(3 downto 0))) <= to_integer(Xpixel(3 downto 0)))) and
		 (to_integer(unsigned(tileType)) /= 3 or to_integer(Ypixel(3 downto 0)) >= 10 ) and(sprite_mem( 16 * to_integer(Ypixel(3 downto 0)) + to_integer(Xpixel(3 downto 0)) - to_integer(unsigned(playerCoordDetailed)) ) /= x"ff") then 	
		--Checks first that the pixel is in the same tile as the player, or directly beneath it, and within the bounds of where the 
		--sprite may be drawn. Also checks that the pixel is not in the upper section of athe goal tile (tile type 3), and that
		--the the pixel in sprite memory is not full white (our transparency color).
	
		tilePixel <= sprite_mem(16 * to_integer(Ypixel(3 downto 0)) + to_integer(Xpixel(3 downto 0)) - to_integer(unsigned(playerCoordDetailed)) ); --draw pixel from sprite

	elsif (to_integer(unsigned(playerCoordRough)) +  1 = to_integer(Ypixel(7 downto 4) - 7) * 16 + to_integer(Xpixel(7 downto 4) - 11)and to_integer(unsigned(playerCoordDetailed(7 downto 4))) <= to_integer(Ypixel(3 downto 0)) and to_integer(unsigned(playerCoordDetailed(3 downto 0))) >  to_integer(Xpixel(3 downto 0))) and
		(sprite_mem(16 * to_integer(Ypixel(3 downto 0)) + to_integer(Xpixel(3 downto 0)) + 16 - to_integer(unsigned(playerCoordDetailed))) /= x"ff") then
		--Checks if the pixel is in the tile to the immediate right of the player location (PCR is allways in the leftmost of any one 
		--or two tiles the character is in), and if so does the same as above if-statement except for checking if the pixel is in the
		--upper part of the goal tile, and with an offset of 16 (since there is a 16-pixel offset from the pc, which would otherwise 
		--cause the sprite to be drawn with wraparound one pixel down)
		
		tilePixel <= sprite_mem(16 + 16 * to_integer(Ypixel(3 downto 0)) + to_integer(Xpixel(3 downto 0)) - to_integer(unsigned(playerCoordDetailed)) ); --draw pixel from sprite, with an offset of 16 (see above comment)

	else
	    tilePixel <= tileMem((to_integer(unsigned(tileType)) * 256) + (16 * to_integer(Ypixel(3 downto 0))) + to_integer(Xpixel(3 downto 0))); --draw corresponding pixel in corresponding tile
	end if;
		elsif (Xpixel < 608 and Ypixel < 480) then
			tilePixel <= tileMem(256 + (16 * to_integer(Ypixel(3 downto 0))) + to_integer(Xpixel(3 downto 0))); --draw rocks in the surrounding area; constant 256 corresponds to tile type for rock
		else
			tilePixel <= (others => '0'); --black borders
      end if;
    end if;
  end process;

  -- Picture memory address composite

  -- VGA generation
  vgaRed(2 downto 0) 	<= tilePixel(7 downto 5);
  vgaGreen(2 downto 0)	<= tilePixel(4 downto 2);
  vgaBlue(2 downto 1)	<= tilePixel(1 downto 0);

end Behavioral;
