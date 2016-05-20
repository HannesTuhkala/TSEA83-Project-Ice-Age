library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
entity cpu is
	port (
		clk: in std_logic;
		playerXYR : out std_logic_vector(7 downto 0);-- Player coordinate high (each worth 16 pixels)
		playerXYD : out std_logic_vector(7 downto 0);-- Player coordinate low (used for transitions between tiles)
		joystick: in std_logic_vector(7 downto 0);
		mapm_address : in std_logic_vector(7 downto 0);		--Address by which graphics component can select type of tile in tilemem
		tile : out std_logic_vector(1 downto 0) 		--Tile type at mapm_addres
	);
end cpu;

architecture behavioral of cpu is
	
	----------------------------------------------------
	-------------------PROGRAM_MEMORY-------------------
	----------------------------------------------------
	-- Declaration of a block-RAM
	-- with 512 addresses of 32 bits width. -2KB
	type pm_t is array(0 to 201) of
		std_logic_vector(31 downto 0);
	-- Reset all bits on all addresses
	signal pm : pm_t := (
"10000001000010000000000000000000",
"00110001000010000000000000000100",
"00000000000000000000000000000000",
"10100000000000000000000000000000",
"10000000000100000000011100000000",
"00000000000000000000000000000000",
"10100000010000000000000000000000",
"10000000000100000000011000000000",
"00000000000000000000000000000000",
"10100000011101000000000000000000",
"10000000000100000000010100000000",
"00000000000000000000000000000000",
"10100000110111000000000000000000",
"00000000000000000000000000000000",
"10110000101010010000000000000000",
"00000000000000000000000000000000",
"01000001000000000001000000000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000",
"01110000000000000000000000000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000",
"10000000000000000000000100000000",
"00000000000000000000000000000000",
"10100000000000000000000000000000",
"00000000000000000000000000000000",
"01000001000000000001000001000000",
"10110001000100010000000000000000",
"00000000000000000000000000000000",
"00110001000000000001000000000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000",
"01110000000000000000000000000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000",
"10000000000000000000000100000000",
"00000000000000000000000000000000",
"10100000000000000000000000000000",
"00000000000000000000000000000000",
"00110001000000000001000001000000",
"10110001000100010000000000000000",
"00000000000000000000000000000000",
"01000001000000000000000100000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000",
"01110000000000000000000000000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000",
"10000000000000000000000100000000",
"00000000000000000000000000000000",
"10100000000000000000000000000000",
"00000000000000000000000000000000",
"01000001000000000000000101000000",
"10110001000100010000000000000000",
"00000000000000000000000000000000",
"00110001000000000000000100000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000",
"01110000000000000000000000000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000",
"10000000000000000000000100000000",
"00000000000000000000000000000000",
"10100000000000000000000000000000",
"00000000000000000000000000000000",
"00110001000000000000000101000000",
"10110001000100010000000000000000",
"00000000000000000000000000000000",
"10000001000010000000000000000000",
"00000000000000000000000000000000",
"10100000000000000000000000000000",
"00000000000000000000000000000000",
"10110001000100010000000000000000",
"00000000000000000000000000000000");
	--------------END OF PROGRAM MEMORY---------------
	--------------------------------------------------
	
	--------------------------------------------------
	---------------------ALU--------------------------
	--------------------------------------------------
		        ----Map layout Memory----
        	--mapm is arranged as: highest 4 bits denote column,
        	--lowest 4 denote row. "10" denotes ground, "01" 
		--denotes rock, "00" denotes ice. Don't use "11" or you'll draw sprites
    type mapm_t is array(0 to 255) of 
			std_logic_vector(1 downto 0); 
	signal mapm : mapm_t := (--(others => "10");
	"01", "01", "01", "01", "01", "11", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", 
	"01", "00", "00", "00", "10", "10", "10", "00", "00", "00", "00", "00", "00", "00", "00", "01", 
	"01", "00", "01", "01", "00", "00", "00", "00", "00", "01", "00", "00", "00", "01", "00", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "01", "10", "00", "00", "00", "00", "00", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", 
	"01", "00", "00", "10", "00", "00", "00", "00", "00", "00", "01", "00", "00", "00", "00", "01", 
	"01", "00", "01", "10", "00", "00", "00", "00", "00", "01", "00", "00", "00", "00", "00", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", 
	"01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", "00", "01", 
	"01", "00", "00", "00", "00", "00", "01", "00", "10", "10", "10", "00", "00", "00", "00", "01", 
	"01", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01");

	--FLAGS----   
	signal z : std_logic := '0';
	signal n : std_logic := '0';
	--------------------------------------------------
	-------------------END OF ALU---------------------
	--------------------------------------------------
	
	--------------------------------------------------
	---------------PROGRAM COUNTER--------------------
	--------------------------------------------------
	signal branch : bit := '0'; -- set 1 if IR1_op is branch, else set to 0.
	signal PC : std_logic_vector(8 downto 0) := (others => '0');
	--------------------------------------------------
	------------END OF PROGRAM COUNTER----------------
	--------------------------------------------------

	--------------------------------------------------
	-------------------REGISTER-----------------------
	--------------------------------------------------
	type reg_t is array(0 to 63) of 
		std_logic_vector(7 downto 0);	

	signal reg : reg_t := (others => (others => '0'));
	signal tmpB2 : std_logic_vector(1 downto 0);	--deprecated


	signal specialRegXYR : std_logic_vector(7 downto 0):= "10001000";	-- Position the pinguin spawns on
	signal specialRegXYD : std_logic_vector(7 downto 0):=(others => '0');
	signal specialRegJoy : std_logic_vector(7 downto 0):=(others => '0');


	signal A2 : std_logic_vector(7 downto 0) := (others => '0');
	signal B2 : std_logic_vector(7 downto 0) := (others => '0');
	-------------------------------------------------
	----------------End of register------------------
	-------------------------------------------------

	-------------------------------------------------
	--------------Internal registers-----------------
	-------------------------------------------------
	signal ir1 : std_logic_vector(31 downto 0) := (others => '0');
	signal ir2 : std_logic_vector(31 downto 0) := (others => '0');
	signal ir3 : std_logic_vector(31 downto 0) := (others => '0');
	
	-------------------ALIAS IR-------------------------
	alias IR1_op : std_logic_vector(3 downto 0) is IR1(31 downto 28);
	alias IR2_op : std_logic_vector(3 downto 0) is IR2(31 downto 28);
	alias IR3_op : std_logic_vector(3 downto 0) is IR3(31 downto 28);
	
	
	alias IR1_term1 : std_logic_vector(7 downto 0) is IR1(25 downto 18);

	alias IR1_am2 : std_logic_vector(1 downto 0) is IR1(17 downto 16);
	alias IR2_am2 : std_logic_vector(1 downto 0) is IR2(17 downto 16);
	alias IR3_am2 : std_logic_vector(1 downto 0) is IR3(17 downto 16);

	alias IR1_term2 : std_logic_vector(7 downto 0) is IR1(15 downto 8);

	alias IR2_fA : std_logic_vector(7 downto 0) is IR2(7 downto 0);
	alias IR3_fA : std_logic_vector(7 downto 0) is IR3(7 downto 0);

	-------------------------------------------------
	------------END OF INTERNAL REGISTERS------------
	-------------------------------------------------

	-------------------------------------------------
	--------------------ALU--------------------------
	-------------------------------------------------
	signal res : std_logic_vector(7 downto 0) := (others => '0');
	-------------------------------------------------
	-------------------END OF ALU--------------------
	-------------------------------------------------

begin
	-------------- REGISTER -----------------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			
			if to_integer(unsigned(IR1_term1)) < 64 then
			      A2 <= reg(to_integer(unsigned(IR1_term1(5 downto 0))));
			else 
			     case IR1_term1(1 downto 0) is 
			     	when "00" => A2 <= specialRegXYR;
			     	when "01" => A2 <= specialRegXYD;
			     	when "10" => A2 <= specialRegJoy;
			     	when others => A2 <= (others => '0');
			     end case;
			end if;

			
			if ir1_am2 = "01" then
				if to_integer(unsigned(IR1_term2)) < 64 then
				      B2 <= reg(to_integer(unsigned(IR1_term2(5 downto 0))));
				else case IR1_term2(1 downto 0) is 
					when	"00" => B2 <= specialRegXYR;
					when	"01" => B2 <= specialRegXYD;
					when	"10" => B2 <= specialRegJoy;
					when others => B2 <= (others => '0');
				end case;
				end if;
			else 
				b2 <= ir1_term2;
			end if;
			playerXYR <= specialRegXYR;	-- Player Y and X position are stored in register 64 and 65.
			playerXYD <= specialRegXYD;
			specialRegJoy <= joystick;		-- We store the joystick value in register 66.

			if (IR3_op = "0001" or IR3_op = "0011" or IR3_op = "0100" or IR3_op = "0101" or IR3_op = "0110" or IR3_op = "0111") then
				if to_integer(unsigned(IR3_fa)) < 64 then
			     		 reg(to_integer(unsigned(IR3_fA))) <= res;
				else
					 case IR3_fa(1 downto 0) is
					when "00" => specialRegXYR <= res;
					when "01" => specialRegXYD <= res;
					when others => null;
				end case;
				end if;
			end if;
		end if;
	END PROCESS;

	------------- END Register --------------

	--------- Internal Registers -------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			IR3 <= IR2;
			IR2 <= IR1;
			IR1 <= pm(to_integer(unsigned(PC))); 
		end if;
	END PROCESS;
	------- END Internal Registers -------	

	-------- Program Counter --------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			if (IR1_op = "1011" or (IR1_op = "1010" and ((IR1_am2(0) = '0' and z = '1') or (IR1_am2(0) = '1' and n = '1')))) then	
				PC <= '0' & IR1_term1;
			else
				PC <= PC + 1;
			end if;
		end if;
	END PROCESS;
	-------- END Program Counter ------


	tmpB2 <= B2(1 downto 0);
	--------------- ALU ------------------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			if (IR2_op = "0001") then	-- Move
				res <= B2;
			end if;
			
			if (IR2_op = "0010") then  --map editor
				mapm(to_integer(unsigned(IR2_fA))) <= tmpB2;
			elsif (IR2_op = "0111") then   --collision detector
				res(7 downto 2) <= (others => '0');
				res(1 downto 0) <= mapm(to_integer(unsigned(B2)));
			end if;

			if (IR2_op = "0011") then	--Add
				res <= A2 + B2;
				if (to_integer(unsigned(A2)) + to_integer(unsigned(B2)) > 256)then 
					n <= '1';
				else
					n <= '0';
				end if;
			end if;
			
			if (IR2_op = "0100" or IR2_op = "1000") then   -- Sub or Comp; differed by whether register stores value
				res <= A2 - B2;
				
				if(A2 < B2) then 
					n <= '1';
				else 
					n <= '0';
				end if;

				if(A2 = B2) then
					z <= '1';
				else 
					z <= '0';
				end if; 
			end if;

			if (IR2_op = "0101") then   --Mult
				res <= "00000000"; --A2 * B2;
			end if;
			
			if (IR2_op = "0110") then   -- Shift
				res(7 downto 4) <= A2(3 downto 0);
				res(3 downto 0) <= (others => '0');
			end if;
						
			if (IR2_op = "1001") then   -- set flag
				if (IR2_am2(1) = '1') then
					z <= IR2_am2(0);
				else 
					n <= IR2_am2(0);
				end if;
			end if;
			-- branch, branch on flag, nop and halt does not affect alu
			
			tile <= mapm(to_integer(unsigned(mapm_address)));	-- outputs requested pixel to pixel selector
		end if;
	end PROCESS;
	
end behavioral;
