library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity ALU is 
	port(
		clk : in std_logic;
		A2 : in std_logic_vector(7 downto 0);
		B2 : in std_logic_vector(7 downto 0);
		op : in std_logic_vector(3 downto 0);
		am2 : in std_logic_vector(1 downto 0);
		res : out std_logic_vector(3 downto 0);
		tm_addres : in std_logic_vector(7 downto 0);
		tile : out std_logic_vector(1 downto 0)); 

end ALU;

architecture Behaviourial of ALU is

			----tile memory----
			--tm is arranged as: highest 4 bits denote column, 
			--lowest 4 denote row. "1-" denotes ground, "01" 
			--denotes rock, "00" denotes ice.
	type tm_t is array(0 to 255) of
		std_logic_vector(7 downto 0);
	signal tm : tm_t := (others => (others => '0'));

			----flags----
	signal z : std_logic := '0';
	signal n : std_logic := '0';	
	
begin

	process(clk)
	begin 
		if (rising_edge(clk)) then
			if (op = "0001") then	-- Move
				res <= B2;
			end if;
			
			if (op = "0011") then	--Add
				res <= A2 + B2;
			end if;
			
			if (op = "0100" || op = "1000") then   --Sub or Comp; differed by whether register stores value
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

			if (op = "0101") then   --Mult
				res <= A2 * B2;
			end if;
			
			if (op = "0110") then   --Shift
				if (am2(1) = '1') then 	-- Right Shift
					res(6 downto 0) <= A2(7 downto 1);
					if (am2(0) = '1')then --arithmethric shift
						res(7) <= A2(7);
					else 
						res(7) <= '0';
					end if;
				else 
					res(7 downto 1) <= A2(6 downto 0);
					res(0 <= '0');
				end if;
			end if;
			
			if (op = "0111") then   --Collision detector
				case B2(1 downto 0) is	-- detect rocks
					when "00" => z <= tm(A2 - 1)(0);
					when "01" => z <= tm(A2 + 1)(0);
					when "10" => z <= tm(A2 - 16)(0);
					when "11" => z <= tm(A2 + 16)(0);
				end case;
				n <= tm(A2)(1); --detect ground
			end if;

			if (op = "1001") then   --set flag
				if(am2(1) = '1') then
					z <= am2(0);
				else 
					n z= am2(0);
				end if;
			end if;
			--branch, branch on flag, nop and halt does not affect alu
			
			tile <= tm(tm_addres);	--outputs requested pixel to pixel selector
		end if;
	end process;