LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Main IS
    PORT (
        -- Detik
        CLK : IN STD_LOGIC;
        time_counter : INOUT INTEGER RANGE 0 TO 23 := 0;

        -- Input untuk CAHAYA
        sensor_cahaya : IN STD_LOGIC;
        toilet_infrared : IN STD_LOGIC; --Sensor yg menandakan pergerakan pada toilet
        livingroom_infrared : IN STD_LOGIC; --Sensor yg menandakan pergerakan pada pintu masuk rumah
        bedroom_infrared : IN STD_LOGIC;

        -- Ouput untuk CAHAYA
        toilet_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada toilet
        livingroom_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada livingroom
        bedroom_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada bedroom
        bedroom_lampu_dim : OUT STD_LOGIC;

        -- Input untuk AC
        on_time : IN INTEGER RANGE 0 TO 23; -- Timer untuk otomatis menyalakan AC
        humidity_sensor : IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- Sensor untuk Kelembaban
        ac_temp_sensor : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- Sensor untuk Temperature

        -- Output untuk AC
        compressor : INOUT STD_LOGIC; -- Kontrol untuk kompresor
        fan : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- Kontrol untuk Kipas

        -- Input untuk WATER PUMPER
        water_temperature : IN INTEGER RANGE 0 TO 50; -- Suhu air dalam derajat Celsius
        water_volume : IN INTEGER RANGE 0 TO 100;

        -- Output untuk WATER PUMPER
        pumper_water_pump : OUT STD_LOGIC; -- Menandakan hidup/matinya pompa air bak mandi
        increased_temperature : OUT INTEGER RANGE 0 TO 50; -- Menandakan suhu air yang dinaikkan oleh sistem
        increased_water_volume : OUT INTEGER RANGE 0 TO 100;

        -- Input untuk PLANT WATERER
        enable_plant_waterer : IN STD_LOGIC;
        is_raining : IN STD_LOGIC;

        -- Input untuk PLANT WATERER
        plant_water_pump : OUT STD_LOGIC
    );
END ENTITY Main;
ARCHITECTURE rtl OF Main IS
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

    SIGNAL dtk : INTEGER := 0;
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
            IF (dtk = 2599) THEN
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
END ARCHITECTURE rtl;