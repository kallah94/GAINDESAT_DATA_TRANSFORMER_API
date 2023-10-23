# DataTransformerApi

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


# Mission Principal data files structures
## General Payload File structure
 
  | Field Name         |  Size(octet)  | Type        |
  |--------------------|:-------------:|-------------|
  | file_name          |       8       | String      |
  | file_creation_time |       4       | Datetimes   |
  | file_update_time   |       4       | Datetimes   |
  | first_sector       |       2       | Integer     |
  | file_size          |       4       | Integer     |
  | root_add           |       2       | Integer     |
  | payload            |      TBD      | Hexadecimal |

## payload from Payload File structure
this structure represent a generic structure of payload file. The substructure of the field **`data`** depend
on the value of the field **`tc_code`**


  | Field Name |  Size(octet)  | Type        |
  |------------|:-------------:|-------------|
  | cafe       |       2       | Hexadecimal |
  | timestamp  |       4       | Datetimes   |
  | tc_code    |       1       | Hexadecimal |
  | data       |      TBD      | Hexadecimal |

### Structures of mission data from sensor data collector and payload
This structure fully represent the structure of the field **`data`** from payload file structure
in the case of sensor data collection (**tc_code** = `0xa`)

| Field Name         |  Size(octet)  | Type        |
|--------------------|:-------------:|-------------|
| cafe               |       2       | Hexadecimal |
| timestamp          |       4       | Datetimes   |
| tc_code(`0xa`)     |       1       | Hexadecimal |
| id_station         |       1       | Hexadecimal |
| nb_package         |       1       | Hexadecimal |
| nb_total_package   |       1       | Hexadecimal |
| size_package       |       2       | Integer     |
| set_of_data_packet |      TBD      | Hexadecimal |
the field `set_of_data_packet` in this case is a set of packets of sensor data

#### Structure of data_packet
this structure represent a set of sensor data

| Field Name                |  Size(octet)  | Type        |
|:--------------------------|:-------------:|-------------|
| na                        |       1       | Hexadecimal |
| number_of_packet          |       2       | Integer     |
| number_total_of_packet    |       2       | Integer     |
| number_total_of_measures  |       2       | Integer     |
| set_of_measures           |      TBD      | Hexadecimal |


##### Structure of measures data of a sensor

| Field Name        |  Size(octet)  | Type        |
|-------------------|:-------------:|-------------|
| sensor_id         |       1       | Integer     |
| parameter_value   |       2       | Integer     |
| measure_timestamp |       4       | Datetimes   |
| parameter_type    |       1       | Hexadecimal |


# Second mission data files structures

## Structure of payload file when request pictures taken by the camera
| Field Name       | Size(octet) | Type        |
|:-----------------|:-----------:|-------------|
| cafe             |      2      | Hexadecimal |
| timestamp        |      4      | Datetimes   |
| tc_code(`0x03`)  |      1      | Integer     |
| brightness       |      1      | Integer     |
| contrast         |      1      | Integer     |
| resolution       |      1      | Integer     |
| exposition       |      1      | Integer     |
| nb_package       |      1      | Integer     |
| total_nb_package |      1      | Integer     |
| size_package     |      2      | Integer     |
| data             |     TBD     | Hexadecimal |

# Health data structures of payload include the camera

#### Structure of payload response when request station Status data

| Field Name      | Size(octet) | Type        |
|:----------------|:-----------:|-------------|
| cafe            |      2      | Hexadecimal |
| timestamp       |      4      | Datetimes   |
| tc_code(`0x11`) |      1      | Integer     |
| station_status  |      1      | Integer     |
| na              |     TBD     | Hexadecimal |


#### Structure of payload response when request payload `ADC` value

| Field Name              | Size(octet) | Type        |
|:------------------------|:-----------:|-------------|
| cafe                    |      2      | Hexadecimal |
| timestamp               |      4      | Datetimes   |
| tc_code(`0x01`)         |      1      | Integer     |
| nb_adc(`[1, 8, 9, 10]`) |      1      | Integer     |
| data                    |      2      | Integer     |
| na(`0x00..`)            |     TBD     | Hexadecimal |

#### Structure of payload response when request `TMP` value

| Field Name          | Size(octet) | Type        |
|:--------------------|:-----------:|-------------|
| cafe                |      2      | Hexadecimal |
| timestamp           |      4      | Datetimes   |
| tc_code(`0x02`)     |      1      | Integer     |
| nb_sensor(`[1, 2]`) |      1      | Integer     |
| data                |      2      | Integer     |
| na(`0x00..`)        |     TBD     | Hexadecimal |


#### Structure of payload response when request `Camera parameters`
| Field Name      | Size(octet) | Type        |
|:----------------|:-----------:|-------------|
| cafe            |      2      | Hexadecimal |
| timestamp       |      4      | Datetimes   |
| tc_code(`0x06`) |      1      | Integer     |
| brightness      |      1      | Integer     |
| contrast        |      1      | Integer     |
| resolution      |      1      | Integer     |
| exposition      |      1      | Integer     |
| na              |     TBD     | Hexadecimal |

#### Structure of payload response when ask Gyro information

| Field Name      | Size(octet) | Type        |
|:----------------|:-----------:|-------------|
| cafe            |      2      | Hexadecimal |
| timestamp       |      4      | Datetimes   |
| tc_code(`0x07`) |      1      | Integer     |
| gyro_data_x     |      2      | Integer     |
| gyro_data_y     |      2      | Integer     |
| gyro_data_z     |      2      | Integer     |
| accel_data_x    |      2      | Integer     |
| accel_data_y    |      2      | Integer     |
| accel_data_z    |      2      | Integer     |
| temp_data       |      2      | Integer     |
| na              |     TBD     | Hexadecimal |

#### Sensor Type name from ICD

| Name                        | Code |
|:----------------------------|:----:|
| water_height                |  01  |
| water_temp                  |  02  |
| ambient_temp                |  03  |
| precipitations              |  04  |
| wind_speed                  |  05  |
| wind_direction              |  06  |
| specific_water_conductivity |  07  |
| salinity                    |  08  |
| total_dissolved_solids      |  09  |
| compass                     |  0a  |
| relative_water_humidity     |  0b  |
| barometric_pressure         |  0c  |
| global_radiation            |  0d  |

