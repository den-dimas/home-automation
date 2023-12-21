--Kelompok PSD AP01
--Title - Project : Home Automation System
--Part of project : Lamp Autmation
--Authors : Ivan Yuantama Pradipta
--Version : 1

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Lampu IS
    PORT (
        time_counter : INTEGER RANGE 0 TO 23 := 0; --Sebagai clock pada rangkaian
        sensor_cahaya : IN STD_LOGIC; --Menandakan siang/malam
        toilet_infrared : IN STD_LOGIC; --Sensor yg menandakan pergerakan pada toilet
        livingroom_infrared : IN STD_LOGIC; --Sensor yg menandakan pergerakan pada pintu masuk rumah
        bedroom_infrared : IN STD_LOGIC; --Sensor yg menandakan pergerakan pada bedroom
        toilet_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada toilet
        livingroom_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada livingroom
        bedroom_lampu : OUT STD_LOGIC; --Menandakan hidup/matinya lampu pada bedroom
        bedroom_lampu_dim : OUT STD_LOGIC); --Menandakan redup/tidaknya lampu pada bedroom sesuai sensor cahaya (malam = hidup / siang = mati)
END Lampu;

ARCHITECTURE arch OF Lampu IS
    --State pada lampu
    TYPE StateLampu IS (OFF, ONN);

    --State untuk toilet
    SIGNAL state_toilet, next_state_toilet : StateLampu;

    --State untuk livingroom
    SIGNAL state_livingroom, next_state_livingroom : StateLampu;

    --State untuk bedroom
    SIGNAL state_bedroom, next_state_bedroom : StateLampu;

    --Menetapkan waktu delay
    CONSTANT DELAY_COUNT : INTEGER := 2; --Bisa disesuaikan, kali ini diset dengan 2

    --Counter untuk delay
    SIGNAL counter_toilet, counter_bedroom : INTEGER := 0;
BEGIN
    --Proses untuk mengendalikan lampu toilet
    PROCESS (time_counter)
    BEGIN
        --Untuk menentukan nextstate pada lampu toilet
        CASE state_toilet IS
            WHEN OFF =>
                IF toilet_infrared = '1' THEN
                    next_state_toilet <= ONN;
                    counter_toilet <= 0;
                ELSE
                    next_state_toilet <= OFF;
                END IF;

            WHEN ONN =>
                IF counter_toilet < DELAY_COUNT THEN
                    counter_toilet <= counter_toilet + 1;
                    next_state_toilet <= ONN;
                ELSE
                    next_state_toilet <= OFF;
                END IF;
        END CASE;

        --Update keadaan lampu toilet
        state_toilet <= next_state_toilet;

        --Mengupdate kondisi lampu toilet sesuai statenya
        IF state_toilet = ONN THEN
            toilet_lampu <= '1';
        ELSE
            toilet_lampu <= '0';
        END IF;
    END PROCESS;

    --Proses untuk mengendalikan lampu livingroom
    PROCESS (time_counter)
    BEGIN
        --Untuk menentukan nextstate pada lampu livingroom
        CASE state_livingroom IS
            WHEN OFF =>
                IF livingroom_infrared = '1' THEN
                    next_state_livingroom <= ONN;
                ELSE
                    next_state_livingroom <= OFF;
                END IF;

            WHEN ONN =>
                IF livingroom_infrared = '1' THEN
                    next_state_livingroom <= OFF;
                ELSE
                    next_state_livingroom <= ONN;
                END IF;
        END CASE;

        --Update keadaan lampu livingroom
        state_livingroom <= next_state_livingroom;

        --Mengupdate kondisi lampu livingroom sesuai statenya
        IF state_livingroom = ONN THEN
            livingroom_lampu <= '1';
        ELSE
            livingroom_lampu <= '0';
        END IF;
    END PROCESS;

    -- Proses untuk mengendalikan lampu bedroom
    PROCESS (time_counter)
    BEGIN
        --Untuk menentukan nextstate pada lampu bedroom
        CASE state_bedroom IS
            WHEN OFF =>
                IF bedroom_infrared = '1' THEN
                    next_state_bedroom <= ONN;
                ELSE
                    next_state_bedroom <= OFF;
                END IF;

            WHEN ONN =>
                IF bedroom_infrared = '1' THEN
                    next_state_bedroom <= OFF;
                ELSE
                    --Mengupdate redup/tidaknya lampu bedroom sesuai sensor cahaya
                    IF sensor_cahaya = '0' THEN
                        bedroom_lampu_dim <= '1';
                    ELSE
                        bedroom_lampu_dim <= '0';
                    END IF;
                    next_state_bedroom <= ONN;
                END IF;
        END CASE;

        --Update keadaan lampu bedroom
        state_bedroom <= next_state_bedroom;

        --Mengupdate kondisi lampu livingroom sesuai statenya
        IF state_bedroom = ONN THEN
            bedroom_lampu <= '1';
        ELSE
            bedroom_lampu <= '0';
        END IF;
    END PROCESS;
END arch;