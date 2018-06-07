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

    signal temp2: std_logic;
	signal temp: std_logic;

begin

	-- Perform 'AND' of 'A' and 'B'
	temp <= A or B;

	-- connect 'temp' to 'C
	-- temp2 <= temp and A;
    temp2 <= A and B;

    C <= temp2 xor temp;

end architecture ; -- ExampleArchitecture
