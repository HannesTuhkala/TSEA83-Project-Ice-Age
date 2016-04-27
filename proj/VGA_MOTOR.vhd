--------------------------------------------------------------------------------
-- VGA MOTOR


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity VGA_MOTOR is
  port ( clk			: in std_logic;
	 addr			: out unsigned(10 downto 0);
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
		
  signal 	tilePixel       : std_logic_vector(7 downto 0);	-- Tile pixel data
  signal	tileAddr	: unsigned(10 downto 0);	-- Tile address

  signal        blank           : std_logic;                    -- blanking signal
	

  -- Tile memory type
  type ram_t is array (0 to 2047) of std_logic_vector(7 downto 0);

-- Tile memory
  signal tileMem : ram_t := 
		( x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",      -- space
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
                  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",	-- A
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"00",x"00",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",

		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",      -- B
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",      -- B
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  

		  x"FF",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",      -- C
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",      -- B
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"FF",x"FF",x"FF",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"00",x"00",x"00",x"00",x"00",x"00",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
		  x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",

                  );
		  
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

  
  -- Tile memory
  process(clk)
  begin
    if rising_edge(clk) then
      if (blank = '0') then
        tilePixel <= tileMem(to_integer(tileAddr));
      else
        tilePixel <= (others => '0');
      end if;
    end if;
  end process;
	


  -- Tile memory address composite
  tileAddr <= unsigned(data(4 downto 0)) & Ypixel(4 downto 2) & Xpixel(4 downto 2);


  -- Picture memory address composite
  addr <= to_unsigned(16, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5);


  -- VGA generation
  vgaRed(2) 	<= tilePixel(7);
  vgaRed(1) 	<= tilePixel(6);
  vgaRed(0) 	<= tilePixel(5);
  vgaGreen(2)   <= tilePixel(4);
  vgaGreen(1)   <= tilePixel(3);
  vgaGreen(0)   <= tilePixel(2);
  vgaBlue(2) 	<= tilePixel(1);
  vgaBlue(1) 	<= tilePixel(0);


end Behavioral;

