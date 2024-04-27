import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    // I originally declared the as date as date objects rather than strings and this lead to inconsistent results because they had different formats. Since SQlite does not handle date types it was converting the dates for me and and this was a big problem. This lead to weird results when querying. I dont know how it was doing the conversion from a date object to a string but it worked some of the time and sometimes not.
    
    // define database tables
    private let usersTable = Table("users")
    private let id = Expression<Int64>("id")
    private let height = Expression<Double>("height")
    private let weight = Expression<Double>("weight")
    private let sex = Expression<String>("sex")
    private let age = Expression<Int>("age")
    private let activityLevel = Expression<String>("activityLevel")
    private let goal = Expression<String>("goal")

    private let calorieEntriesTable = Table("calorie_entries")
    private let entryId = Expression<Int64>("entryId")
    private let date = Expression<String>("date")
    private let calories = Expression<Int>("calories")

    private let workoutsTable = Table("workouts")
    private let workoutId = Expression<Int64>("workoutId")
    private let workoutDate = Expression<String>("date")
    private let workoutType = Expression<String>("type")
    private let workoutDuration = Expression<Double>("duration")
    private let caloriesBurned = Expression<Int>("caloriesBurned")
    
    private let sleepEntriesTable = Table("sleep_entries")
    private let sleepEntryId = Expression<Int64>("sleepEntryId")
    private let sleepDate = Expression<String>("date")
    private let sleepDuration = Expression<Double>("duration")

    // connection to database. got this from YouTube
    init() {
       // deleteDatabaseFile()
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/db.sqlite3")
            try createTables()
        } catch {
            print("Unable to initialize database: \(error)")
        }
    }
    // function actaully creates the tables in the database. got from GPT.
    private func createTables() throws {
        try db?.run(usersTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(height)
            t.column(weight)
            t.column(sex)
            t.column(age)
            t.column(activityLevel)
            t.column(goal)
        })

        try db?.run(calorieEntriesTable.create(ifNotExists: true) { t in
            t.column(entryId, primaryKey: true)
            t.column(date)
            t.column(calories)
        })

        try db?.run(workoutsTable.create(ifNotExists: true) { t in
            t.column(workoutId, primaryKey: true)
            t.column(workoutDate)
            t.column(workoutType)
            t.column(workoutDuration)
            t.column(caloriesBurned)
        })
        
        try db?.run(sleepEntriesTable.create(ifNotExists: true) { t in
                    t.column(sleepEntryId, primaryKey: true)
                    t.column(sleepDate)
                    t.column(sleepDuration)
                })
        
    }
    
    func addSleepEntry(date: Date, duration: Double) {
        let dateFormatter = DateFormatter()
        // got this code from GPT. Solved the issue of the date problem.
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let insert = sleepEntriesTable.insert(self.sleepDate <- dateString, self.sleepDuration <- duration)
        do {
            try db?.run(insert)
            print("Sleep entry added successfully.")
        } catch {
            print("Insertion failed: \(error)")
        }
    }

    // function to get all sleep entries from the database. would be used for feedback in future iterations
    func getSleepEntries() -> [(date: Date, duration: Double)] {
        var entries: [(Date, Double)] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        do {
            for entry in try db!.prepare(sleepEntriesTable) {
                if let date = dateFormatter.date(from: entry[sleepDate]) {
                    entries.append((date, entry[sleepDuration]))
                } else {
                    print("Date parsing failed for entry: \(entry[sleepDate])")
                }
            }
        } catch {
            print("Selection failed: \(error)")
        }
        return entries
    }

    // gets sleep for the date specified from the user.
    func getSleepDurationForDate(date: Date) -> Double? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        do {
            let query = sleepEntriesTable.filter(self.sleepDate == dateString)
            for entry in try db!.prepare(query) {
                return entry[sleepDuration]
            }
        } catch {
            print("Query failed: \(error)")
        }
        return nil
    }

    //  only 1 in database
    func addUser(height: Double, weight: Double, sex: String, age: Int, activityLevel: String, goal: String) {
        do {
            if let userRow = try db?.pluck(usersTable) {
                // got from gpt. check if user is already in the database
                let userId = userRow[id]
                let updateUser = usersTable.filter(id == userId).update(
                    self.height <- height,
                    self.weight <- weight,
                    self.sex <- sex,
                    self.age <- age,
                    self.activityLevel <- activityLevel,
                    self.goal <- goal
                )
                do {
                    try db?.run(updateUser)
                    print("User updated successfully.")
                } catch {
                    print("Failed to update user: \(error)")
                }
            } else {
                // if no user exists then insert
                let insert = usersTable.insert(
                    self.height <- height,
                    self.weight <- weight,
                    self.sex <- sex,
                    self.age <- age,
                    self.activityLevel <- activityLevel,
                    self.goal <- goal
                )
                do {
                    try db?.run(insert)
                    print("Inserted new user successfully.")
                } catch {
                    print("Failed to insert new user: \(error)")
                }
            }
        } catch {
            print("Database operation failed: \(error)")
        }
    }

// retrirves users from the database. no longer needed
    func getAllUsers() -> [(height: Double, weight: Double, sex: String, age: Int, activityLevel: String, goal: String)] {
        var users: [(Double, Double, String, Int, String, String)] = []
        do {
            for user in try db!.prepare(usersTable) {
                users.append((user[height], user[weight], user[sex], user[age], user[activityLevel], user[goal]))
            }

        } catch {
            print("Selection failed: \(error)")
        }
        return users
    }

    // add calories for a specific date
    func addCalorieEntry(date: Date, calories: Int) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        

        let insert = calorieEntriesTable.insert(self.date <- dateString, self.calories <- calories)
        do {
            try db?.run(insert)
            print("Calorie entry added successfully.")
        } catch {
            print("Insertion failed: \(error)")
        }
    }


    func getCaloriesForDate(date: Date) -> Int {
        var totalCalories = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        do {
            let query = calorieEntriesTable.filter(self.date == dateString)
            for entry in try db!.prepare(query) {
                totalCalories += entry[calories]
            }
            print("Calories for \(dateString): \(totalCalories)")
            print(totalCalories)
        } catch {
            print("Query failed: \(error)")
        }
        return totalCalories
    }


    func addWorkoutEntry(date: Date, type: String, duration: Double, caloriesBurned: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let insert = workoutsTable.insert(
            self.workoutDate <- dateString,
            self.workoutType <- type,
            self.workoutDuration <- duration,
            self.caloriesBurned <- caloriesBurned
        )
        do {
            try db?.run(insert)
            print("Workout entry added successfully.")
        } catch {
            print("Insertion failed: \(error)")
        }
    }
    
    

    func getCaloriesBurnedForDate(date: Date) -> Int {
        var totalCaloriesBurned = 0
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        

        do {
            let query = workoutsTable.filter(self.workoutDate == dateString)
            for workout in try db!.prepare(query) {
                totalCaloriesBurned += workout[caloriesBurned]
            }
        } catch {
            print("Query failed: \(error)")
        }
        return totalCaloriesBurned
    }
    

    func calculateDailyCalorieNeeds() -> Int {
        do {
            guard let userRow = try db?.pluck(usersTable) else {
                print("No user found - returning default calorie needs")
                return 2000
            }
            // gets the information from the user details view. then goes through the formula.
            let userSex = try userRow.get(sex)
            let userWeight = try userRow.get(weight)
            let userHeight = try userRow.get(height)
            let userAge = try userRow.get(age)
            let userActivityLevel = try userRow.get(activityLevel)
            let userGoal = try userRow.get(goal)

            // If Other or Female was selected they use the female formula. Because females eat less calories and majority of people using the app will be trying to lose weight.
            // Harris Benedict Equation
            // BMR
            let bmr: Double
            if userSex == "Male" {
                bmr = 66.47 + (6.24 * userWeight) + (12.7 * userHeight) - (6.755 * Double(userAge))
            } else {
                bmr = 655.1 + (4.35 * userWeight) + (4.7 * userHeight) - (4.7 * Double(userAge))
            }
            
            // get from user details view and extract from that method
            let activityMultiplier = getActivityMultiplier(forLevel: userActivityLevel)
            
            var dailyCalorieNeeds = bmr * activityMultiplier
            
            // user goal to either gain or lose weight.
            switch userGoal {
            case "Lose Weight":
                dailyCalorieNeeds *= 0.9
            case "Gain Weight":
                dailyCalorieNeeds *= 1.1
            default:
                break
            }
            
            return Int(dailyCalorieNeeds)
        } catch {
            print("An error occurred while calculating daily calorie needs: \(error)")
            return 2000
        }
    }

    // get activity multiplier for calorie needs formula
    private func getActivityMultiplier(forLevel level: String) -> Double {
        switch level {
        case "Sedentary": return 1.2
        case "LightlyActive": return 1.375
        case "ModeratelyActive": return 1.55
        case "VeryActive": return 1.725
        default: return 1.375
        }
    }
    
    func updateUser(height: Double? = nil, weight: Double? = nil, sex: String? = nil, age: Int? = nil, activityLevel: String? = nil, goal: String? = nil) {
        guard let userRow = try? db?.pluck(usersTable) else {
            print("No user found to update")
            return
        }
        let userId = userRow[id]

        var setter: [Setter] = []
        if let height = height {
            setter.append(self.height <- height)
        }
        if let weight = weight {
            setter.append(self.weight <- weight)
        }
        if let sex = sex {
            setter.append(self.sex <- sex)
        }
        if let age = age {
            setter.append(self.age <- age)
        }
        if let activityLevel = activityLevel {
            setter.append(self.activityLevel <- activityLevel)
        }
        if let goal = goal {
            setter.append(self.goal <- goal)
        }

        do {
            try db?.run(usersTable.filter(id == userId).update(setter))
            print("User updated successfully.")
        } catch {
            print("Update failed: \(error)")
        }
    }

}



