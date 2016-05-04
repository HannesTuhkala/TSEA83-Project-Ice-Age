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
	 rst			: in std_logic;
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
  signal 	comp1		: unsigned(3 downto 0);
  signal 	comp2		: unsigned(3 downto 0);
  signal 	comp3		: unsigned(3 downto 0);
  signal 	comp4		: unsigned(3 downto 0);
		
  signal 	tilePixel       : std_logic_vector(7 downto 0);	-- Tile pixel data'''''

  signal        blank           : std_logic;                    -- blanking signal
	

  -- Tile memory type
  type ram_t is array (0 to 2047) of std_logic_vector(7 downto 0);

-- Tile memory
  signal tileMem : ram_t := 
		(--Ice		code: 00

		x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"5b",x"37",x"37",x"37",x"37",x"37",x"37",
		x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",
		x"37",x"37",x"13",x"37",x"17",x"37",x"13",x"37",x"37",x"5b",x"37",x"17",x"37",x"17",x"5b",x"37",
		x"37",x"37",x"5b",x"37",x"37",x"37",x"37",x"5b",x"37",x"17",x"37",x"5b",x"13",x"37",x"37",x"37",
		x"5b",x"37",x"37",x"37",x"37",x"17",x"37",x"37",x"17",x"37",x"37",x"17",x"37",x"37",x"37",x"37",
		x"37",x"37",x"17",x"37",x"13",x"37",x"37",x"5b",x"37",x"13",x"37",x"37",x"37",x"13",x"37",x"5b",
		x"37",x"13",x"37",x"37",x"5b",x"37",x"37",x"37",x"37",x"37",x"5b",x"37",x"37",x"37",x"37",x"37",
		x"37",x"37",x"37",x"13",x"37",x"37",x"37",x"13",x"37",x"37",x"37",x"37",x"17",x"37",x"17",x"37",
		x"37",x"5b",x"37",x"37",x"37",x"37",x"17",x"37",x"37",x"37",x"17",x"37",x"37",x"13",x"37",x"37",
		x"37",x"13",x"17",x"37",x"5b",x"17",x"37",x"37",x"5b",x"37",x"37",x"37",x"5b",x"37",x"37",x"17",
		x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"17",x"37",x"13",x"37",x"37",x"37",x"37",x"37",
		x"37",x"5b",x"37",x"37",x"13",x"37",x"37",x"17",x"37",x"37",x"37",x"37",x"13",x"37",x"5b",x"37",
		x"37",x"37",x"37",x"17",x"37",x"17",x"5b",x"37",x"37",x"37",x"37",x"5b",x"37",x"37",x"37",x"37",
		x"37",x"13",x"37",x"37",x"5b",x"37",x"37",x"37",x"17",x"37",x"13",x"37",x"17",x"17",x"13",x"37",
		x"37",x"37",x"17",x"37",x"37",x"37",x"37",x"17",x"37",x"37",x"37",x"37",x"13",x"37",x"37",x"37",
		x"37",x"37",x"37",x"37",x"37",x"13",x"37",x"37",x"37",x"37",x"17",x"37",x"37",x"37",x"37",x"37",


		--Rock		code: 01
		
		x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"37",x"5b",x"37",x"37",x"37",x"37",x"37",x"37",
		x"37",x"37",x"37",x"37",x"37",x"37",x"49",x"49",x"49",x"37",x"37",x"37",x"37",x"37",x"37",x"37",
		x"37",x"37",x"13",x"37",x"5b",x"49",x"49",x"92",x"49",x"49",x"37",x"37",x"37",x"37",x"5b",x"37",
		x"37",x"5b",x"37",x"37",x"37",x"49",x"92",x"92",x"92",x"49",x"49",x"5b",x"13",x"37",x"37",x"37",
		x"5b",x"37",x"5b",x"37",x"49",x"49",x"92",x"68",x"92",x"92",x"49",x"37",x"37",x"37",x"37",x"37",
		x"37",x"37",x"37",x"49",x"49",x"92",x"92",x"92",x"49",x"92",x"49",x"49",x"37",x"13",x"37",x"5b",
		x"37",x"37",x"49",x"49",x"92",x"92",x"92",x"44",x"92",x"92",x"92",x"49",x"49",x"49",x"37",x"37",
		x"37",x"37",x"49",x"68",x"92",x"92",x"92",x"92",x"92",x"49",x"49",x"49",x"92",x"49",x"49",x"37",
		x"37",x"49",x"92",x"92",x"92",x"49",x"92",x"92",x"49",x"49",x"68",x"92",x"44",x"92",x"49",x"37",
		x"49",x"49",x"92",x"92",x"92",x"44",x"92",x"49",x"49",x"92",x"92",x"92",x"49",x"92",x"49",x"37",
		x"49",x"92",x"49",x"92",x"92",x"92",x"92",x"49",x"49",x"92",x"44",x"92",x"92",x"92",x"49",x"49",
		x"49",x"92",x"92",x"49",x"49",x"92",x"92",x"49",x"49",x"49",x"92",x"49",x"49",x"49",x"49",x"49",
		x"37",x"49",x"92",x"92",x"49",x"49",x"49",x"92",x"92",x"49",x"49",x"49",x"68",x"92",x"92",x"49",
		x"37",x"49",x"49",x"92",x"68",x"44",x"92",x"92",x"92",x"92",x"49",x"92",x"92",x"92",x"92",x"49",
		x"13",x"37",x"49",x"49",x"49",x"92",x"92",x"49",x"49",x"49",x"49",x"92",x"92",x"44",x"92",x"49",
		x"37",x"37",x"37",x"37",x"49",x"49",x"49",x"49",x"37",x"37",x"49",x"49",x"49",x"49",x"49",x"37",
		  
		--Ground	code: 10

		x"37",x"13",x"37",x"37",x"37",x"37",x"91",x"91",x"37",x"5b",x"91",x"91",x"91",x"37",x"37",x"13",
		x"37",x"5b",x"91",x"6d",x"69",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"5b",x"37",x"37",
		x"37",x"5b",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"6d",x"91",x"91",x"91",x"5b",x"37",
		x"37",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"69",x"91",x"91",x"91",x"91",x"91",x"91",x"5b",
		x"37",x"6d",x"69",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"6d",x"91",x"91",x"91",x"91",x"91",
		x"37",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"69",x"91",x"91",x"91",x"91",
		x"37",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",
		x"91",x"91",x"91",x"69",x"91",x"91",x"6d",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",
		x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",
		x"91",x"6d",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"69",x"91",x"91",x"91",x"91",
		x"37",x"91",x"91",x"91",x"91",x"91",x"6d",x"69",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"6d",
		x"37",x"91",x"6d",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",
		x"91",x"91",x"91",x"69",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"5b",
		x"37",x"91",x"91",x"91",x"6d",x"91",x"91",x"91",x"91",x"91",x"6d",x"91",x"91",x"91",x"91",x"37",
		x"37",x"5b",x"91",x"91",x"91",x"91",x"91",x"91",x"69",x"91",x"91",x"91",x"91",x"5b",x"37",x"37",
		x"37",x"37",x"5b",x"91",x"91",x"91",x"6d",x"91",x"91",x"91",x"91",x"91",x"5b",x"37",x"37",x"13",


		  --sprite	code: 11 (hard code 11 into any tile address, or a sprite will be drawn there with white background)

		x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"00",x"00",x"00",x"00",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"ff",x"ff",x"ff",x"00",x"00",x"00",x"00",x"00",x"00",x"ff",x"ff",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"ff",x"ff",x"00",x"00",x"71",x"00",x"00",x"71",x"00",x"00",x"ff",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"ff",x"ff",x"ff",x"00",x"da",x"da",x"da",x"da",x"00",x"ff",x"ff",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"ff",x"ff",x"ff",x"00",x"00",x"da",x"da",x"00",x"00",x"ff",x"ff",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"ff",x"ff",x"ff",x"00",x"00",x"00",x"00",x"00",x"00",x"ff",x"00",x"00",x"ff",x"ff",
		x"ff",x"ff",x"ff",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"00",x"00",x"ff",x"00",x"00",x"00",x"00",x"00",x"00",x"ff",x"ff",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"ff",x"ff",x"ff",x"00",x"00",x"00",x"00",x"00",x"00",x"ff",x"ff",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"ff",x"ff",x"ff",x"00",x"00",x"00",x"00",x"00",x"00",x"ff",x"ff",x"ff",x"ff",x"ff",
		x"ff",x"ff",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"ff",x"ff",
		x"ff",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"ff",
		x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
		x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
		x"ff",x"00",x"00",x"20",x"00",x"00",x"00",x"ff",x"ff",x"00",x"00",x"00",x"20",x"00",x"00",x"ff",
		x"ff",x"b2",x"b6",x"b2",x"b2",x"b6",x"ff",x"ff",x"ff",x"ff",x"b6",x"b2",x"b2",x"b6",x"b2",x"ff");
		  
begin

  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	ClkDiv <= (others => '0');
      else
	ClkDiv <= ClkDiv + 1;
      end if;
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
			if rst = '1' then
				Xpixel <= (others => '0');
			end if;

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
			if rst = '1' then
				Ypixel <= (others => '0');
			end if;

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
  
  -- Video blanking signal

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Blank                          *
  -- *                                 *
  -- ***********************************
  
	blank <= '1' when (Xpixel > 255) or (Ypixel > 255) else '0';	

  
  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  pixel selection                *
  -- *                                 *
  -- ***********************************
  process(clk)
  begin
    if rising_edge(clk) then
    
      tileSlot(7 downto 4) <= std_logic_vector(Ypixel(7 downto 4));		-- find tile over which pixel rests
      tileSlot(3 downto 0) <= std_logic_vector(Xpixel(7 downto 4));		--
    
      if (blank = '0') then
	if ((playerCoordRough(7 downto 4) < (Ypixel(7 downto 4))    ) or ((playerCoordRough(7 downto 4) = (Ypixel(7 downto 4))   and  (playerCoordDetailed(7 downto 4)) <= (Ypixel(3 downto 0))     ))) 
		and ((playerCoordRough(7 downto 4) > (Ypixel(7 downto 4)) - 1) and ( (playerCoordRough(7 downto 4) = (Ypixel(7 downto 4)) - 1 and  (playerCoordDetailed(7 downto 4)) >= (Ypixel(3 downto 0)) - 1 )))	--Forgive me/Olav
		and ((playerCoordRough(3 downto 0) < (Xpixel(3 downto 0))    ) and ((playerCoordRough(3 downto 0) = (Xpixel(7 downto 4)) and (playerCoordDetailed(3 downto 0)) <= (Xpixel(3 downto 0))))) 
		and ((playerCoordRough(3 downto 0) > (Xpixel(3 downto 0)) - 1) and ((playerCoordRough(3 downto 0) = (Xpixel(7 downto 4)) - 1 and (playerCoordDetailed(3 downto 0)) >= (Xpixel(3 downto 0)) - 1 )))
		and tileMem(768 + (16 *(Ypixel(3 downto 0))) + Xpixel(3 downto 0)  - (playerCoordDetailed)) != 255 then

	  tilePixel <= tileMem(("11" & Ypixel(3 downto 0) & Xpixel(3 downto 0)) - playerCoordDetailed);	--Very tired when wrote this; check for errors/Olav
	else
	  tilePixel <= tileMem(to_integer(unsigned(tileType & Ypixel(3 downto 0) & Xpixel(3 downto 0))));
	end if;
      else
        tilePixel <= (others => '0');
      end if;
    end if;
  end process;

  -- Picture memory address composite
  addr <= to_unsigned(16, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5); --to whoever wrote this, please explain or comment /Olav

  -- VGA generation
  vgaRed(2 downto 0) 	<= tilePixel(7 downto 5);
  vgaGreen(2 donwto 0)	<= tilePixel(4 downto 2);
  vgaBlue(2 downto 1)	<= tilePixel(1 downto 0);

end Behavioral;
