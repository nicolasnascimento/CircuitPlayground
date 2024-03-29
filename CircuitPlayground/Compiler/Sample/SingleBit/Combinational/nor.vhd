-- IMPORTANT: Any Update to this file should be propagated to the Token Test Case
-- Import IEEE defined STD_LOGIC types
library ieee;
use ieee.std_logic_1164.all;

-- Define the basic entity
entity ExampleEntity is
	port(
		A: in std_logic;
		B: in std_logic;
		C: out std_logic
	);
end ExampleEntity;


-- Define the basic architecture
architecture ExampleArchitecture of ExampleEntity is

begin

	-- Perform 'NOR' of 'A' and 'B'
	C <= A nor B;

end architecture ; -- ExampleArchitecture
