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
	temp2 <= A and B;

	-- connect 'C' to 'XOR' of result of 'temp2' and 'temp'
  C <= temp2 xor temp;

  -- Perform 'OR' of 'A' and 'B'
  temp <= A or B;

end architecture ; -- ExampleArchitecture
