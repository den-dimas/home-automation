LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

--Title   : Air Conditioner
--Author  : Dimas Dermawan

ENTITY AirConditioner IS
    PORT (
        CLK : IN STD_LOGIC;

        time_counter : IN INTEGER RANGE 1 TO 24; -- Clock untuk waktu
        on_time : IN INTEGER RANGE 1 TO 24; -- Timer untuk otomatis menyalakan AC

        temp_sensor : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- Sensor untuk Temperature
        humidity_sensor : IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- Sensor untuk Kelembaban

        compressor : INOUT STD_LOGIC; -- Kontrol untuk kompresor
        fan : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- Kontrol untuk Kipas

        celcius : OUT INTEGER
    );
END AirConditioner;

ARCHITECTURE Behavioral OF AirConditioner IS
    SIGNAL is_on : STD_LOGIC;
    SIGNAL fan_speed : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN

    -- Process untuk menyalakan AC sesuai Timer
    timer : PROCESS (time_counter)
    BEGIN
        IF time_counter = on_time THEN
            is_on <= '1';
        ELSE
            is_on <= '0';
        END IF;
    END PROCESS;

    -- Kontrol untuk kompresor untuk nyala atau tidak
    compressor <= is_on;

    -- Kontrol kecepatan Kipas
    fan_control : PROCESS (temp_sensor, humidity_sensor, is_on)
    BEGIN
        IF is_on = '1' THEN
            IF (temp_sensor > "00011110") OR -- Jika temperature > 30 C
                (humidity_sensor > "01010000") THEN -- Jika nilai kelembaban > 80
                fan_speed <= "10"; -- Kecepatan tinggi
            ELSE
                fan_speed <= "01"; -- Kecepatan sedang
            END IF;
        ELSE
            fan_speed <= "00"; -- Matikan kipas
        END IF;

        fan <= fan_speed;
    END PROCESS;

    simulate_temp : PROCESS (CLK)
        VARIABLE seed1, seed2 : POSITIVE;
        VARIABLE tempT : INTEGER;

        IMPURE FUNCTION GenerateRandomCelcius RETURN INTEGER IS
            VARIABLE riil : real;
        BEGIN
            uniform(seed1, seed2, riil);

            RETURN INTEGER(round(riil * 85.0));
        END GenerateRandomCelcius;
    BEGIN
        IF rising_edge(CLK) THEN
            tempT := GenerateRandomCelcius;

            celcius <= tempT;
            temp_sensor <= STD_LOGIC_VECTOR(to_unsigned(tempT, 8));
        END IF;
    END PROCESS;
END Behavioral;