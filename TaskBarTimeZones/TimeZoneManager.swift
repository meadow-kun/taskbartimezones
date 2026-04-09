import Foundation

struct CityTimeZone: Codable, Identifiable, Equatable {
    var id = UUID()
    var label: String
    var timezoneID: String
}

class TimeZoneManager: ObservableObject {
    static let shared = TimeZoneManager()

    @Published var cities: [CityTimeZone] {
        didSet { save() }
    }

    private let key = "savedCities"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([CityTimeZone].self, from: data) {
            self.cities = decoded
        } else {
            self.cities = [
                CityTimeZone(label: "SF", timezoneID: "America/Los_Angeles"),
                CityTimeZone(label: "SG", timezoneID: "Asia/Singapore"),
                CityTimeZone(label: "STO", timezoneID: "Europe/Stockholm"),
            ]
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(cities) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
