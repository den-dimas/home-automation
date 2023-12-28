--Kelompok PSD AP01
--Title - Project : Home Automation System
--Part of project : Water_Pumper
--Authors : Beres Bakti Parsaoran Siagian
--Version : 1

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Water_Pumper IS
    PORT (
        clk : IN STD_LOGIC; -- Sebagai clock pada rangkaian
        time_counter : IN INTEGER RANGE 0 TO 23;
        current_temperature : IN INTEGER RANGE 0 TO 50; -- Suhu air dalam derajat Celsius
        current_water_volume : IN INTEGER RANGE 0 TO 100; -- Volume air dalam persentase (0-100)
        water_pump : OUT STD_LOGIC; -- Menandakan hidup/matinya pompa air bak mandi
        increased_temperature : OUT INTEGER RANGE 0 TO 50; -- Menandakan suhu air yang dinaikkan oleh sistem
        increased_water_volume : OUT INTEGER RANGE 0 TO 100); -- Menandakan volume air yang ditambahkan oleh sistem
END Water_Pumper;

ARCHITECTURE arch OF Water_Pumper IS
    -- State pada Water Pumper
    TYPE StateWaterPumper IS (IDLE, PUMPING);

    -- State untuk Water Pumper
    SIGNAL state_water_pumper, next_state_water_pumper : StateWaterPumper;

    -- Counter untuk delay
    SIGNAL counter : INTEGER := 0;
    SIGNAL is_morning : STD_LOGIC;
    SIGNAL is_night : STD_LOGIC;
BEGIN
    PROCESS (time_counter)
    BEGIN
        IF (time_counter = 7) THEN
            is_morning <= '1';
            is_night <= '0';

        ELSIF (time_counter = 20) THEN
            is_night <= '1';
            is_morning <= '0';

        ELSE
            is_night <= '0';
            is_morning <= '0';
        END IF;
    END PROCESS;
    -- Proses untuk mengendalikan Water Pumper
    PROCESS (clk)
        VARIABLE delay_count : INTEGER := 5; -- Nilai delay, bisa diubah sesuai kebutuhan
    BEGIN
        IF rising_edge(clk) THEN
            -- Untuk menentukan nextstate pada Water Pumper
            CASE state_water_pumper IS
                WHEN IDLE =>
                    -- Sistem akan beralih ke state PUMPING saat pagi atau malam hari,
                    -- suhu air kurang dari 50, dan volume air kurang dari 100
                    IF (is_morning = '1' OR is_night = '1') AND current_temperature < 50 AND current_water_volume < 100 THEN
                        next_state_water_pumper <= PUMPING;
                        counter <= 0;
                    ELSE
                        next_state_water_pumper <= IDLE;
                    END IF;

                WHEN PUMPING =>
                    IF counter < delay_count THEN
                        counter <= counter + 1;
                        next_state_water_pumper <= PUMPING;
                    ELSE
                        next_state_water_pumper <= IDLE;
                    END IF;
            END CASE;

            -- Update keadaan Water Pumper
            state_water_pumper <= next_state_water_pumper;

            -- Mengupdate kondisi Water Pumper sesuai statenya
            IF state_water_pumper = PUMPING THEN
                water_pump <= '1';

                -- Perubahan saat delay_counter sudah mencapai 5
                IF counter = delay_count THEN
                    increased_temperature <= 50 - current_temperature;
                    increased_water_volume <= 100 - current_water_volume;
                ELSE
                    increased_temperature <= 0;
                    increased_water_volume <= 0;
                END IF;
            ELSE
                water_pump <= '0';
                increased_temperature <= 0;
                increased_water_volume <= 0;
            END IF;
        END IF;
    END PROCESS;
END arch;
