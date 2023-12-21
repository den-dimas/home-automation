LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY PlantWateringSystem IS
    PORT (
        time_counter : INTEGER RANGE 0 TO 24 := 0; -- 24 hour format
        enable : IN STD_LOGIC;
        is_raining : IN STD_LOGIC; -- Input for rain indicator

        water_pump : OUT STD_LOGIC);
END PlantWateringSystem;

ARCHITECTURE Behavioral OF PlantWateringSystem IS
    TYPE state_type IS (IDLE, WATERING);
    SIGNAL state, next_state : state_type;
BEGIN

    -- State machine
    PROCESS (time_counter)
    BEGIN
        state <= next_state;
    END PROCESS;

    -- State logic with rain check
    PROCESS (state, is_raining)
    BEGIN
        CASE state IS
            WHEN IDLE =>
                water_pump <= '0';
                IF (time_counter = 7 OR time_counter = 17) AND is_raining = '0' THEN -- Check for rain
                    next_state <= WATERING;
                ELSE
                    next_state <= IDLE;
                END IF;
            WHEN WATERING =>
                water_pump <= '1';
                IF (time_counter = 8 OR time_counter = 18) OR is_raining = '1' THEN -- Stop watering if it's raining or after 1 hour
                    next_state <= IDLE;
                ELSE
                    next_state <= WATERING;
                END IF;
        END CASE;
    END PROCESS;

END Behavioral;