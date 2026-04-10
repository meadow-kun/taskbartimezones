import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var manager: TimeZoneManager
    var onChange: () -> Void

    @State private var newLabel = ""
    @State private var newTimezoneID = "America/New_York"
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    private var sortedTimezoneIDs: [String] {
        TimeZone.knownTimeZoneIdentifiers.sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(manager.cities) { city in
                    HStack {
                        TextField("Label", text: binding(for: city).label)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)

                        Picker("", selection: binding(for: city).timezoneID) {
                            ForEach(sortedTimezoneIDs, id: \.self) { tz in
                                Text(tz).tag(tz)
                            }
                        }
                        .labelsHidden()

                        Spacer()

                        Button(role: .destructive) {
                            manager.cities.removeAll { $0.id == city.id }
                            onChange()
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .onMove { from, to in
                    manager.cities.move(fromOffsets: from, toOffset: to)
                    onChange()
                }
            }

            Divider()

            Toggle("Launch at Login", isOn: $launchAtLogin)
                .padding(.horizontal)
                .padding(.top, 8)
                .onChange(of: launchAtLogin) { newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        launchAtLogin = SMAppService.mainApp.status == .enabled
                    }
                }

            Divider()

            HStack {
                TextField("Label", text: $newLabel)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)

                Picker("", selection: $newTimezoneID) {
                    ForEach(sortedTimezoneIDs, id: \.self) { tz in
                        Text(tz).tag(tz)
                    }
                }
                .labelsHidden()

                Button("Add") {
                    guard !newLabel.isEmpty else { return }
                    manager.cities.append(CityTimeZone(label: newLabel, timezoneID: newTimezoneID))
                    newLabel = ""
                    onChange()
                }
                .disabled(newLabel.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func binding(for city: CityTimeZone) -> Binding<CityTimeZone> {
        guard let index = manager.cities.firstIndex(where: { $0.id == city.id }) else {
            return .constant(city)
        }
        return Binding(
            get: { self.manager.cities[index] },
            set: {
                self.manager.cities[index] = $0
                self.onChange()
            }
        )
    }
}
