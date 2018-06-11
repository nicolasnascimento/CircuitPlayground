-- Import IEEE defined STD_LOGIC types
library ieee;
use ieee.std_logic_1164.all;

-- Define the basic entity
entity ExampleEntity is
	port(
		A: in std_logic;
		B: out std_logic
	);
end ExampleEntity;

-- Define the basic architecture
architecture ExampleArchitecture of ExampleEntity is

-- Define Global Signals

begin

	-- Describe Logic
	process(B, A)
	begin
		if A = '1' then
			B <= A;
		else
			B <= '1';
		end if;
	end process;

end architecture ; -- ExampleArchitecture
