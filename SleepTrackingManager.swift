import Foundation
import Combine

class SleepTrackingManager: ObservableObject {
    @Published var sleepDurationForSelectedDate: Double?
    private var databaseManager = DatabaseManager.shared
    
    
    func fetchSleepData(for date: Date) {
        if let sleepData = databaseManager.getSleepDurationForDate(date: date) {
            DispatchQueue.main.async {
                self.sleepDurationForSelectedDate = sleepData
            }
        } else {
            DispatchQueue.main.async {
                self.sleepDurationForSelectedDate = nil
            }
        }
    }
    // got this from chatgpt. Said its becasue of a separation of concerns. Not exactly sure why its neded but dont break something that aint fixed!
    func saveSleepData(date: Date, hours: Double, minutes: Double) {
        let totalHours = hours + minutes / 60.0
        databaseManager.addSleepEntry(date: date, duration: totalHours)
        fetchSleepData(for: date)
    }
}

