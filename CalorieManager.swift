import SwiftUI
import Combine

class CalorieManager: ObservableObject {
    // to notify when a view updates
    @Published var todaysCalories: Int = 0
    @Published var neededCalories: Int = 0
    @Published var caloriesBurned: Int = 0
    @Published var remainingCalories: Int = 0
    @Published var dailyCalorieNeeds: Int = 0
    @Published var workoutsForSelectedDate: [Dictionary<String, Any>] = []
    
    var selectedDate: Date = Date()
    // fetches todays calories
    init() {
            fetchTodaysCalories()
    }

    func fetchTodaysCalories() {
         dailyCalorieNeeds = DatabaseManager.shared.calculateDailyCalorieNeeds() // Calculate the calorie needs for the database
        todaysCalories = DatabaseManager.shared.getCaloriesForDate(date: selectedDate) // calorie needs for selected date
        caloriesBurned = DatabaseManager.shared.getCaloriesBurnedForDate(date: selectedDate) // calorie burned for the selected date
        remainingCalories = dailyCalorieNeeds - todaysCalories + caloriesBurned // calculate the remaining calories for that date
        print(todaysCalories)
    }
 

    func logCalorieIntake(calories: Int) {
        DatabaseManager.shared.addCalorieEntry(date: selectedDate, calories: calories)
       // having a problem here neededCalories += calories KNOW FOR A FACT
        todaysCalories += calories
        let dailyCalorieNeeds = DatabaseManager.shared.calculateDailyCalorieNeeds()
        remainingCalories = dailyCalorieNeeds - todaysCalories + caloriesBurned
    }


    func logWorkout(caloriesBurned: Int, type: String, duration: Double) {
        DatabaseManager.shared.addWorkoutEntry(date: selectedDate, type: type, duration: duration, caloriesBurned: caloriesBurned) // adds the calories burned to the database
        self.caloriesBurned += caloriesBurned // update this variable
        let dailyCalorieNeeds = DatabaseManager.shared.calculateDailyCalorieNeeds()
        remainingCalories = dailyCalorieNeeds - todaysCalories + self.caloriesBurned
    }

   //  private func updateRemainingCalories() {
    //    remainingCalories -= todaysCalories
    //    print(todaysCalories)
    //    remainingCalories += caloriesBurned
  //  }
    
   
    
    // @objc func recalculateDailyNeeds() {
        //    let dailyCalorieNeeds = DatabaseManager.shared.calculateDailyCalorieNeeds()
       //     todaysCalories = DatabaseManager.shared.getCaloriesForDate(date: selectedDate)
        //    caloriesBurned = DatabaseManager.shared.getCaloriesBurnedForDate(date: selectedDate)
       //     remainingCalories = dailyCalorieNeeds - todaysCalories + caloriesBurned
       // }

    
}

