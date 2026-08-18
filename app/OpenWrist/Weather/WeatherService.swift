import Foundation

struct CurrentWeather: Equatable {
    var tempC: Double
    var humidityPct: Int
    var conditionCode: UInt8      // OpenWrist code (see docs/PROTOCOL.md)
    var summary: String
}

// Fetches current weather from Open-Meteo (free, no API key) and maps it to the
// ble_ow weather packet. Default location is Bengaluru; wire CoreLocation later.
@MainActor
final class WeatherService: ObservableObject {
    @Published var current: CurrentWeather?
    @Published var error: String?

    var latitude = 12.9716
    var longitude = 77.5946

    func refresh() async {
        error = nil
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)"
            + "&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,weather_code")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let r = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            let code = Self.mapWMO(r.current.weather_code)
            current = CurrentWeather(tempC: r.current.temperature_2m,
                                     humidityPct: r.current.relative_humidity_2m,
                                     conditionCode: code,
                                     summary: Self.describe(code))
        } catch {
            self.error = error.localizedDescription
        }
    }

    var packet: WeatherPacket? {
        guard let c = current else { return nil }
        return WeatherPacket(tempCx10: Int16((c.tempC * 10).rounded()),
                             conditionCode: c.conditionCode,
                             humidityPct: UInt8(min(max(c.humidityPct, 0), 100)))
    }

    // WMO weather code -> OpenWrist condition code. Pure, so not actor-isolated.
    nonisolated static func mapWMO(_ wmo: Int) -> UInt8 {
        switch wmo {
        case 0: return 0                                   // clear
        case 1, 2, 3: return 1                             // clouds
        case 45, 48: return 5                              // fog
        case 51...67, 80...82: return 2                    // rain/drizzle
        case 71...77, 85, 86: return 3                     // snow
        case 95...99: return 4                             // thunder
        default: return 1
        }
    }

    static func describe(_ code: UInt8) -> String {
        ["Clear", "Cloudy", "Rain", "Snow", "Thunderstorm", "Fog"][Int(min(code, 5))]
    }
}

private struct OpenMeteoResponse: Decodable {
    struct Current: Decodable {
        let temperature_2m: Double
        let relative_humidity_2m: Int
        let weather_code: Int
    }
    let current: Current
}
