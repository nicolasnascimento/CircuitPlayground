-- Import IEEE defined STD_LOGIC types
library ieee;
use ieee.std_logic_1164.all;

-- Define the basic entity
entity ExampleEntity is
	port(
		A: in std_logic;
		B: in std_logic;
		C: in std_logic;
        D: in std_logic;
        E: out std_logic
	);
end ExampleEntity;

-- Define the basic architecture
architecture ExampleArchitecture of ExampleEntity is
begin

	-- Describe Logic
	E <= A when C = '1' else
         B when C = '0' else
         D;

end architecture ; -- ExampleArchitecture
