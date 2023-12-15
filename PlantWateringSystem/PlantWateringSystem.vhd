library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PlantWateringSystem is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           is_raining : in STD_LOGIC; -- Input for rain indicator
           water_pump : out STD_LOGIC);
end PlantWateringSystem;

architecture Behavioral of PlantWateringSystem is
    type state_type is (IDLE, WATERING);
    signal state, next_state : state_type;
    signal time_counter : integer range 0 to 24 := 0; -- 24 hour format
begin

    -- State machine
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                state <= next_state;
                if time_counter = 24 then
                    time_counter <= 0;
                else
                    time_counter <= time_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- State logic with rain check
    process(state, time_counter, is_raining)
    begin
        case state is
            when IDLE =>
                water_pump <= '0';
                if (time_counter = 7 or time_counter = 17) and is_raining = '0' then -- Check for rain
                    next_state <= WATERING;
                else
                    next_state <= IDLE;
                end if;
            when WATERING =>
                water_pump <= '1';
                if (time_counter = 8 or time_counter = 18) or is_raining = '1' then -- Stop watering if it's raining or after 1 hour
                    next_state <= IDLE;
                else
                    next_state <= WATERING;
                end if;
        end case;
    end process;

end Behavioral;
