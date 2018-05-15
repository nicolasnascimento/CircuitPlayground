-- IMPORTANT: Any Update to this file should be propagated to the Token Test Case
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

begin

	-- Perform 'OR' of 'A' and 'B'
	B <= A and '1';

end architecture ; -- ExampleArchitecture
