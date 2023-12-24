LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY main_tb IS
END ENTITY main_tb;

ARCHITECTURE rtl OF main_tb IS
    COMPONENT Lampu IS
    PORT (
        time_counter : IN INTEGER RANGE 0 TO 23 := 0; --Sebagai clock pada rangkaian

        sensor_cahaya : IN STD_LOGIC; --Menandakan siang/malam
        toilet_infrared : IN STD_LOGIC; --Sensor yg menandakan pergerakan pada toilet
        livingroom_infrared : IN STD_LOGIC; --Sensor yg menandakan pergerakan pada pintu masuk rumah
        bedroom_infrared : IN STD_LOGIC; --Sensor yg menandakan pergerakan pada bedroom

        toilet_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada toilet
        livingroom_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada livingroom
        bedroom_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada bedroom
        bedroom_lampu_dim : OUT STD_LOGIC); --Menandakan redup/tidaknya lampu pada bedroom sesuai sensor cahaya (malam = hidup / siang = mati)
    END COMPONENT Lampu;

    COMPONENT AirConditioner IS
    PORT (
        time_counter : IN INTEGER RANGE 0 TO 23; -- Clock untuk waktu
        on_time : IN INTEGER RANGE 0 TO 23; -- Timer untuk otomatis menyalakan AC

        temp_sensor : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- Sensor untuk Temperature
        humidity_sensor : IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- Sensor untuk Kelembaban

        compressor : INOUT STD_LOGIC; -- Kontrol untuk kompresor
        fan : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0) -- Kontrol untuk Kipas
    );
    END COMPONENT AirConditioner;

    COMPONENT Water_Pumper IS
    PORT (
        time_counter : IN INTEGER RANGE 0 TO 23 := 0; -- Sebagai clock pada rangkaian

        current_temperature : IN INTEGER RANGE 0 TO 50; -- Suhu air dalam derajat Celsius
        current_water_volume : IN INTEGER RANGE 0 TO 100; -- Volume air dalam persentase (0-100)

        water_pump : OUT STD_LOGIC; -- Menandakan hidup/matinya pompa air bak mandi
        increased_temperature : OUT INTEGER RANGE 0 TO 50; -- Menandakan suhu air yang dinaikkan oleh sistem
        increased_water_volume : OUT INTEGER RANGE 0 TO 100); -- Menandakan volume air yang ditambahkan oleh sistem
    END COMPONENT Water_Pumper;

    COMPONENT PlantWateringSystem IS
    PORT (
        time_counter : IN INTEGER RANGE 0 TO 23 := 0;

        enable : IN STD_LOGIC;
        is_raining : IN STD_LOGIC; -- Input for rain indicator

        water_pump : OUT STD_LOGIC);
    END COMPONENT PlantWateringSystem;

    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL time_counter : INTEGER RANGE 0 TO 23 := 0;
    SIGNAL sensor_cahaya : STD_LOGIC;
    SIGNAL toilet_infrared : STD_LOGIC;
    SIGNAL livingroom_infrared : STD_LOGIC;
    SIGNAL bedroom_infrared : STD_LOGIC;
    SIGNAL on_time : INTEGER RANGE 0 TO 23;
    SIGNAL humidity_sensor : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL ac_temp_sensor : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL compressor : STD_LOGIC;
    SIGNAL fan : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL water_temperature : INTEGER RANGE 0 TO 50;
    SIGNAL water_volume : INTEGER RANGE 0 TO 100;
    SIGNAL enable_plant_waterer : STD_LOGIC;
    SIGNAL is_raining : STD_LOGIC;

    signal toilet_lampu : STD_LOGIC;
    signal livingroom_lampu : STD_LOGIC;
    signal bedroom_lampu : STD_LOGIC;
    signal bedroom_lampu_dim : STD_LOGIC;
    signal pumper_water_pump : STD_LOGIC;
    signal increased_temperature : INTEGER RANGE 0 TO 50;
    signal increased_water_volume : INTEGER RANGE 0 TO 100;
    signal plant_water_pump : STD_LOGIC;

    SIGNAL dtk : INTEGER := 0;
    signal ac_celcius : INTEGER;
BEGIN

    lampuPort : Lampu PORT MAP(
        time_counter => time_counter,
        sensor_cahaya => sensor_cahaya,
        toilet_infrared => toilet_infrared,
        livingroom_infrared => livingroom_infrared,
        bedroom_infrared => bedroom_infrared,
        toilet_lampu => toilet_lampu,
        livingroom_lampu => livingroom_lampu,
        bedroom_lampu => bedroom_lampu,
        bedroom_lampu_dim => bedroom_lampu_dim
    );

    ACPort : AirConditioner PORT MAP(
        time_counter => time_counter,
        on_time => on_time,
        temp_sensor => ac_temp_sensor,
        humidity_sensor => humidity_sensor,
        compressor => compressor,
        fan => fan
    );

    waterPumpPort : Water_Pumper PORT MAP(
        time_counter => time_counter,
        current_temperature => water_temperature,
        current_water_volume => water_volume,
        water_pump => pumper_water_pump,
        increased_temperature => increased_temperature,
        increased_water_volume => increased_water_volume
    );

    plantWatererPort : PlantWateringSystem PORT MAP(
        time_counter => time_counter,
        enable => enable_plant_waterer,
        is_raining => is_raining,
        water_pump => plant_water_pump
    );

    hitungDetik : PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            IF (dtk = 2) THEN
                dtk <= 0;

                IF (time_counter = 23) THEN
                    time_counter <= 0;
                ELSE
                    time_counter <= time_counter + 1;
                END IF;
            ELSE
                dtk <= dtk + 1;
            END IF;
        END IF;
    END PROCESS hitungDetik;

    clockSimulate : PROCESS
        CONSTANT period : TIME := 50 ps;
    BEGIN
        wait for period;

        IF (CLK = '0') THEN
            CLK <= '1';
        ELSE
            CLK <= '0';
        END IF;
    END PROCESS clockSimulate;

    -- Simulasi Temperature
    simulate_ac_temp : PROCESS (time_counter)
        VARIABLE seed1, seed2 : POSITIVE;
        VARIABLE tempT : INTEGER;

        IMPURE FUNCTION GenerateRandomCelcius RETURN INTEGER IS
            VARIABLE riil : real;
        BEGIN
            uniform(seed1, seed2, riil);

            RETURN INTEGER(round(riil * (48.0 - 12.0) + 12.0));
        END GenerateRandomCelcius;
    BEGIN
        tempT := GenerateRandomCelcius;

        ac_celcius <= tempT;
        ac_temp_sensor <= STD_LOGIC_VECTOR(to_unsigned(tempT, 8));
    END PROCESS;
    
    simulate_water_temp : PROCESS (time_counter)
        VARIABLE seed1, seed2 : POSITIVE;
        VARIABLE tempT : INTEGER;

        IMPURE FUNCTION GenerateRandomCelcius RETURN INTEGER IS
            VARIABLE riil : real;
        BEGIN
            uniform(seed1, seed2, riil);

            RETURN INTEGER(round(riil * 50.0));
        END GenerateRandomCelcius;
    BEGIN
        water_temperature <= GenerateRandomCelcius;
    END PROCESS;

END ARCHITECTURE rtl;