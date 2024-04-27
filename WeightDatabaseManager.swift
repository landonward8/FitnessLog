import Foundation
import SQLite

class WeightDatabaseManager {
    static let shared = WeightDatabaseManager()
    private var db: Connection?
    private let weightTable = Table("weights")
    private let settingsTable = Table("settings")
    private let id = Expression<Int64>("id")
    private let date = Expression<Date>("date")
    private let weight = Expression<Double>("weight")

    private init() {
        initializeDatabase()
        // deleteDatabaseFile()
    }
    
    private func initializeDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/weightDB.sqlite3")
            try createWeightTable()
            try createSettingsTable()
        } catch {
            print("Unable to initialize weight database: \(error)")
        }
    }

    private func createWeightTable() throws {
        try db?.run(weightTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(date)
            t.column(weight)
        })
    }
    
    private func createSettingsTable() throws {
        try db?.run(settingsTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
        })
    }

    func addWeightEntry(date: Date, weight: Double) {
        let insert = weightTable.insert(self.date <- date, self.weight <- weight)
        do {
            try db?.run(insert)
        } catch {
            print("Failed to insert weight entry: \(error)")
        }
    }
    
    // fetch all weight history
    func fetchWeightHistory() -> [(date: Date, weight: Double)] {
        var results: [(Date, Double)] = []
        do {
            for entry in try db!.prepare(weightTable.order(date.asc)) {
                results.append((entry[date], entry[weight]))
            }
        } catch {
            print("Failed to fetch weight history: \(error)")
        }
        return results
    }
    // fetch weight for a specific day.
    func fetchWeight(for selectedDate: Date) -> Double? {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            let query = weightTable.filter(date >= startOfDay && date < endOfDay)
            if let weightEntry = try db?.pluck(query) {
                return weightEntry[weight]
            }
        } catch {
            print("Failed to fetch weight for selected date: \(error)")
        }
        
        return nil
    }
}

