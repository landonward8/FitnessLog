//
//  WorkoutTrackingView.swift
//  FitnessLog+
//
//  Created by Landon Ward on 4/2/24.
//

import Foundation

struct WorkoutTrackingView: View {
    @State private var workoutType: String = ""
    @State private var workoutDuration: String = ""
    @State private var caloriesBurned: String = ""
    var calorieManager: CalorieManager

    var body: some View {
        VStack(alignment: .leading) {
            Text("Log Workout").font(.headline).padding(.top)
            TextField("Workout Type", text: $workoutType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)

            TextField("Duration (minutes)", text: $workoutDuration)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

            TextField("Calories Burned", text: $caloriesBurned)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

            Button("Log Workout") {
                logWorkout()
            }.padding(.top)
        }
        .padding()
    }

    private func logWorkout() {
        guard let duration = Double(workoutDuration), let calories = Int(caloriesBurned) else {
            // Handle invalid input
            return
        }
        calorieManager.logWorkout(caloriesBurned: calories, type: workoutType, duration: duration)
        workoutType = ""
        workoutDuration = ""
        caloriesBurned = ""
    }
}
