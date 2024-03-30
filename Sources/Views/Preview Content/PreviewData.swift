import Foundation
import UIKit
import Models
import Network

#if DEBUG
enum PreviewData {
    static func loadTestData(withFileName fileName: String) -> Data {
        let dataAsset = NSDataAsset(name: fileName)!

        return dataAsset.data
    }
    
    static func loadDevice() -> Device {
        let decoder = Client.jsonDecoder()
        do {
            let device = try decoder.decode(Device.self, from: deviceResponse)
            return device

        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func loadReadings() -> Readings {
        let data = PreviewData.loadTestData(withFileName: "Readings")
        let decoder = Client.jsonDecoder()
        let measurements = try! decoder.decode(Readings.self, from: data)

        return measurements
    }

    static func loadReadingsFullDay() -> Readings {
        let data = SensorFetcher.FullDayReadings
        let decoder = Client.jsonDecoder()
        let measurements = try! decoder.decode(Readings.self, from: data)

        return measurements
    }

    static func loadWorldDeviceForBarcelona() -> [WorldMapDevice] {
        let data = PreviewData.loadTestData(withFileName: "WorldDevices")
        let decoder = Client.jsonDecoder()
        let devices = try! decoder.decode(Array<WorldMapDevice>.self, from: data)

        return devices
    }
    
    static let deviceResponse: Data = {
        Data(#"""
        {
            "id": 1234,
            "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
            "name": "MyDevice",
            "description": "Smart Citizen Kit 2.1 with Urban Sensor Board",
            "state": "has_published",
            "hardware_info": {
                "id": "1234",
                "mac": "AA:BB:CC:DD:EE:FF",
                "time": "2020-01-05T01:10:07Z",
                "esp_bd": "",
                "hw_ver": "2.1",
                "sam_bd": "2019-08-20T13:25:01Z",
                "esp_ver": "",
                "sam_ver": "0.9.5-a91f850"
            },
            "system_tags": [
                "indoor",
                "new",
                "offline"
            ],
            "user_tags": [
                "Experimental",
                "Living Room"
            ],
            "is_private": false,
            "notify_low_battery": false,
            "notify_stopped_publishing": false,
            "last_reading_at": "2020-01-05T01:07:37Z",
            "added_at": "2020-01-04T11:18:47Z",
            "updated_at": "2020-01-05T02:09:30Z",
            "mac_address": "[FILTERED]",
            "owner": {
                "id": 1234,
                "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                "username": "USERNAME",
                "avatar": "https://smartcitizen.s3.amazonaws.com/avatars/default.svg",
                "url": null,
                "joined_at": "2020-01-04T11:18:45Z",
                "location": {
                    "city": "Fukuoka",
                    "country": "Japan",
                    "country_code": "JP"
                },
                "device_ids": []
            },
            "data": {
                "recorded_at": "2020-01-05T01:07:37Z",
                "added_at": "2020-01-05T01:07:37Z",
                "location": {
                    "ip": null,
                    "exposure": "indoor",
                    "elevation": null,
                    "latitude": 30.590355,
                    "longitude": 130.401716,
                    "geohash": "wvuxp6gwh0nbq",
                    "city": "Fukuoka",
                    "country_code": "JP",
                    "country": "Japan"
                },
                "sensors": [
                    {
                        "id": 113,
                        "ancestry": "111",
                        "name": "AMS CCS811 - TVOC",
                        "description": "Total Volatile Organic Compounds Digital Indoor Sensor",
                        "unit": "ppb",
                        "created_at": "2019-03-21T16:43:37Z",
                        "updated_at": "2019-03-21T16:43:37Z",
                        "measurement": {
                            "id": 47,
                            "name": "TVOC",
                            "description": "Total volatile organic compounds is a grouping of a wide range of organic chemical compounds to simplify reporting when these are present in ambient air or emissions. Many substances, such as natural gas, could be classified as volatile organic compounds (VOCs).",
                            "unit": null,
                            "uuid": "c6f9a729-1782-4da1-adc9-e88b7143e45c"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 2.0,
                        "raw_value": 2.0,
                        "prev_value": 2.0,
                        "prev_raw_value": 2.0
                    },
                    {
                        "id": 112,
                        "ancestry": "111",
                        "name": "AMS CCS811 - eCO2",
                        "description": "Equivalent Carbon Dioxide Digital Indoor Sensor",
                        "unit": "ppm",
                        "created_at": "2019-03-21T16:43:37Z",
                        "updated_at": "2019-03-21T16:43:37Z",
                        "measurement": {
                            "id": 46,
                            "name": "eCO2",
                            "description": "Equivalent CO2 is the concentration of CO2 that would cause the same level of radiative forcing as a given type and concentration of greenhouse gas. Examples of such greenhouse gases are methane, perfluorocarbons, and nitrous oxide. CO2 is primarily a by-product of human metabolism and is constantly being emitted into the indoor environment by building occupants. CO2 may come from combustion sources as well. Associations of higher indoor carbon dioxide concentrations with impaired work performance and increased health symptoms have been attributed to correlation of indoor CO2 with concentrations of other indoor air pollutants that are also influenced by rates of outdoor-air ventilation.",
                            "unit": null,
                            "uuid": "b6fee847-2bb6-4e1e-8e39-979612e2beb9"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 414.0,
                        "raw_value": 414.0,
                        "prev_value": 414.0,
                        "prev_raw_value": 414.0
                    },
                    {
                        "id": 14,
                        "ancestry": null,
                        "name": "BH1730FVC",
                        "description": "Digital Ambient Light Sensor",
                        "unit": "Lux",
                        "created_at": "2015-02-02T18:24:56Z",
                        "updated_at": "2015-07-05T19:57:36Z",
                        "measurement": {
                            "id": 3,
                            "name": "Light",
                            "description": "Lux is a measure of how much light is spread over a given area. A full moon clear night is around 1 lux, inside an office building you usually have 400 lux and a bright day can be more than 20000 lux.",
                            "unit": null,
                            "uuid": "50aa0431-86ac-4340-bf51-ad498ee35a3b"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 1152.0,
                        "raw_value": 1152.0,
                        "prev_value": 1152.0,
                        "prev_raw_value": 1152.0
                    },
                    {
                        "id": 10,
                        "ancestry": null,
                        "name": "Battery SCK 1.1",
                        "description": "Custom Circuit",
                        "unit": "%",
                        "created_at": "2015-02-02T18:18:00Z",
                        "updated_at": "2015-07-05T19:53:51Z",
                        "measurement": {
                            "id": 7,
                            "name": "battery",
                            "description": "The SCK remaining battery level in percentage.",
                            "uuid": "c5964926-c2d2-4714-98b5-18f84c6f95c1"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 76.0,
                        "raw_value": 76.0,
                        "prev_value": 76.0,
                        "prev_raw_value": 76.0
                    },
                    {
                        "id": 53,
                        "ancestry": "52",
                        "name": "ICS43432 - Noise",
                        "description": "I2S Digital Mems Microphone with custom Audio Processing Algorithm",
                        "unit": "dBA",
                        "created_at": "2018-05-03T10:42:47Z",
                        "updated_at": "2018-05-03T10:42:54Z",
                        "measurement": {
                            "id": 4,
                            "name": "Noise Level",
                            "description": "dB's measure sound pressure difference between the average local pressure and the pressure in the sound wave.  A quiet library is below 40dB, your house is around 50dB and a diesel truck in your street 90dB.",
                            "uuid": "2841719f-658e-40df-a14a-74a86adc1410"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 43.93,
                        "raw_value": 43.93,
                        "prev_value": 43.93,
                        "prev_raw_value": 43.93
                    },
                    {
                        "id": 58,
                        "ancestry": "57",
                        "name": "MPL3115A2 - Barometric Pressure",
                        "description": "Digital Barometric Pressure Sensor",
                        "unit": "K Pa",
                        "created_at": "2018-05-03T10:49:17Z",
                        "updated_at": "2018-05-03T10:49:17Z",
                        "measurement": {
                        "id": 25,
                            "name": "Barometric Pressure",
                            "description": "Barometric pressure is the pressure within the atmosphere of Earth. In most circumstances atmospheric pressure is closely approximated by the hydrostatic pressure caused by the weight of air above the measurement point.",
                            "uuid": "2a944e9d-073d-49ed-8dc7-e376495f283d"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 102.44,
                        "raw_value": 102.44,
                        "prev_value": 102.44,
                        "prev_raw_value": 102.44
                    },
                    {
                        "id": 89,
                        "ancestry": "86",
                        "name": "PMS5003_AVG-PM1",
                        "description": "Particle Matter PM 1",
                        "unit": "ug/m3",
                        "created_at": "2018-05-22T13:20:34Z",
                        "updated_at": "2018-05-22T13:20:34Z",
                        "measurement": {
                            "id": 27,
                            "name": "PM 1",
                            "description": "PM stands for particulate matter: the term for a mixture of solid particles and liquid droplets found in the air. Some particles, such as dust, dirt, soot, or smoke, are large or dark enough to be seen with the naked eye.",
                            "uuid": "9759c2fd-15d8-424b-adcc-d6efcf940f6e"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 3.0,
                        "raw_value": 3.0,
                        "prev_value": 3.0,
                        "prev_raw_value": 3.0
                    },
                    {
                        "id": 88,
                        "ancestry": "86",
                        "name": "PMS5003_AVG-PM10",
                        "description": "Particle Matter PM 10",
                        "unit": "ug/m3",
                        "created_at": "2018-05-22T13:20:34Z",
                        "updated_at": "2018-05-22T13:20:34Z",
                        "measurement": {
                            "id": 13,
                            "name": "PM 10",
                            "description": "PM stands for particulate matter: the term for a mixture of solid particles and liquid droplets found in the air. Some particles, such as dust, dirt, soot, or smoke, are large or dark enough to be seen with the naked eye.",
                            "uuid": "30e5b614-ab7e-46bc-b6f7-fa9a30926ce9"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 5.0,
                        "raw_value": 5.0,
                        "prev_value": 5.0,
                        "prev_raw_value": 5.0
                    },
                    {
                        "id": 87,
                        "ancestry": "86",
                        "name": "PMS5003_AVG-PM2.5",
                        "description": "Particle Matter PM 2.5",
                        "unit": "ug/m3",
                        "created_at": "2018-05-22T13:20:34Z",
                        "updated_at": "2018-05-22T13:20:34Z",
                        "measurement": {
                            "id": 14,
                            "name": "PM 2.5",
                            "description": "PM stands for particulate matter: the term for a mixture of solid particles and liquid droplets found in the air. Some particles, such as dust, dirt, soot, or smoke, are large or dark enough to be seen with the naked eye.",
                            "uuid": "c8ecda46-c430-4cbc-9ad4-5ea8a07c5820"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 5.0,
                        "raw_value": 5.0,
                        "prev_value": 5.0,
                        "prev_raw_value": 5.0
                    },
                    {
                        "id": 56,
                        "ancestry": "54",
                        "name": "SHT31 - Humidity",
                        "description": "Humidity",
                        "unit": "%",
                        "created_at": "2018-05-03T10:47:17Z",
                        "updated_at": "2018-05-03T10:47:17Z",
                        "measurement": {
                            "id": 2,
                            "name": "Relative Humidity",
                            "description": "Relative humidity is a measure of the amount of moisture in the air relative to the total amount of moisture the air can hold. For instance, if the relative humidity was 50%, then the air is only half saturated with moisture.",
                            "uuid": "9cbbd396-5bd3-44be-adc0-7ffba778072d"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 64.0,
                        "raw_value": 64.0,
                        "prev_value": 64.0,
                        "prev_raw_value": 64.0
                    },
                    {
                        "id": 55,
                        "ancestry": "54",
                        "name": "SHT31 - Temperature",
                        "description": "Temperature",
                        "unit": "ºC",
                        "created_at": "2018-05-03T10:47:15Z",
                        "updated_at": "2018-05-03T10:47:15Z",
                        "measurement": {
                            "id": 1,
                            "name": "Air Temperature",
                            "description": "Air temperature is a measure of how hot or cold the air is. It is the most commonly measured weather parameter. Air temperature is dependent on the amount and strength of the sunlight hitting the earth, and atmospheric conditions, such as cloud cover and humidity, which trap heat.",
                            "uuid": "b3f44b63-0a17-4d84-bbf1-4c17764b7eae"
                        },
                        "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                        "value": 22.39,
                        "raw_value": 22.39,
                        "prev_value": 22.39,
                        "prev_raw_value": 22.39
                    }
                ]
            },
            "kit": {
                "id": 26,
                "uuid": "deadbeed-dead-beef-beef-deadbeeddead",
                "slug": "sck:2,1",
                "name": "SCK 2.1",
                "description": "Smart Citizen Kit 2.1 with Urban Sensor Board",
                "created_at": "2019-03-21T17:02:46Z",
                "updated_at": "2019-03-21T17:02:46Z"
            }
        }
        """#.utf8)
    }()
}


#endif
