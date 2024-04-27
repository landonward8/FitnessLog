
import SwiftUI

struct SleepTrackingView: View {
    @ObservedObject var viewModel = SleepTrackingManager()
    @State private var selectedDate = Date()
    @State private var sleepHours: Double = 8
    @State private var sleepMinutes: Double = 0
    @State private var sleepDurationForSelectedDate: Double?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .onChange(of: selectedDate) { _ in
                            fetchSleepData()
                        }
                        .accentColor(.green)
                }
                
                Section(header: Text("Input Sleep Duration")) {
                    VStack(alignment: .leading) {
                        Slider(value: $sleepHours, in: 0...23, step: 1) {
                            Text("Hours")
                        } minimumValueLabel: {
                            Text("0h")
                        } maximumValueLabel: {
                            Text("23h")
                        }
                        .accentColor(.green)
                        Slider(value: $sleepMinutes, in: 0...59, step: 1) {
                            Text("Minutes")
                        } minimumValueLabel: {
                            Text("0m")
                        } maximumValueLabel: {
                            Text("59m")
                        }
                        .accentColor(.green)
                        
                        Text("Hours of Sleep: \(Int(sleepHours)) Hours, \(Int(sleepMinutes)) Minutes")
                            .padding(.top, 10)
                    }
                }
                
                Section {
                    Button("Save Sleep Data") {
                        saveSleepData()
                    }
                    .foregroundColor(.green)
                }
                
                if let duration = sleepDurationForSelectedDate {
                    Section(header: Text("Sleep Summary for Selected Date")) {
                        Text("Total Sleep: \(duration, specifier: "%.2f") hours")
                    }
                }
            }
            .navigationBarTitle("Sleep Tracking", displayMode: .inline)
            .onAppear {
                fetchSleepData()
            }
        }
    }
// saves sleep data for the user
    private func saveSleepData() {
        let totalHours = sleepHours + sleepMinutes / 60.0
        DatabaseManager.shared.addSleepEntry(date: selectedDate, duration: totalHours)
        fetchSleepData()
    }

    private func fetchSleepData() {
        if let sleepData = DatabaseManager.shared.getSleepDurationForDate(date: selectedDate) {
            self.sleepDurationForSelectedDate = sleepData
        } else {
            self.sleepDurationForSelectedDate = nil
        }
    }
}

struct SleepTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        SleepTrackingView()
    }
}
