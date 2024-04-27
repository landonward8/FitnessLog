import SwiftUI
import Foundation

struct CalorieTrackingView: View {
    @State private var calorieIntake: String = ""
    @State private var showingWorkoutView: Bool = false // to show workout logging view
    @ObservedObject var calorieManager: CalorieManager = CalorieManager()
    @State private var selectedDate: Date = Date()
    
    var body: some View {
          NavigationView {
              VStack {
                  Form {
                      DatePicker("Date", selection: $selectedDate, displayedComponents: .date) // select the date
                          .onChange(of: selectedDate) { newValue in
                              calorieManager.selectedDate = newValue // update the selected date inside calorie manager
                              calorieManager.fetchTodaysCalories() // fetch how many calories are needed based off of BMR 
                          }
                          .accentColor(.green)
                          .foregroundColor(.black)
                      TextField("Calories Intake", text: $calorieIntake)
                          .keyboardType(.numberPad)
                          .foregroundColor(.black)

                      Button("Log Calorie Intake") {
                          logCalorieIntake()
                      }.foregroundColor(.green)
                      
                      Button("Add Workout") {
                          showingWorkoutView.toggle()
                      }.foregroundColor(.green)
                  }
                  .foregroundColor(.white)

                  if showingWorkoutView {
                      WorkoutTrackingView(calorieManager: calorieManager)
                  }

                  CircleProgressView(remainingCalories: $calorieManager.remainingCalories)
                      .frame(width: 150, height: 150)
                      .padding()
              }
              .navigationBarTitle("Calorie and Workout Tracking", displayMode: .inline)
              .navigationBarTitle("", displayMode: .inline)
              .onAppear {
                  print(DatabaseManager.shared.getCaloriesForDate(date: selectedDate))
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(Color(red: 0, green: 0.1, blue: 0.2))
          }
      }
        
    private func logCalorieIntake() {
        guard let calories = Int(calorieIntake) else { return }
        calorieManager.logCalorieIntake(calories: calories) // log calorie intake using calorie manager
        calorieIntake = "" //reset the text after logging
    }
}

struct WorkoutTrackingView: View {
    @State private var workoutType: String = ""
    @State private var workoutDuration: String = ""
    @State private var caloriesBurned: String = ""
    var calorieManager: CalorieManager

    var body: some View {
        VStack(alignment: .leading) {
            Text("Log Workout").font(.headline).padding(.top)
                .foregroundColor(.white)
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
                
            }.padding(.top).foregroundColor(.green)
        }

        .padding()
    }

    private func logWorkout() {
        guard let duration = Double(workoutDuration), let calories = Int(caloriesBurned) else {
            return
        }
        calorieManager.logWorkout(caloriesBurned: calories, type: workoutType, duration: duration)
        workoutType = ""
        workoutDuration = ""
        caloriesBurned = ""
        
    }
}

// Got the drawing the circle code from ChatGPT ***
struct CircleProgressView: View {
    @Binding var remainingCalories: Int
    let totalCalories: Int = 2000
    @ObservedObject var calorieManager: CalorieManager = CalorieManager()

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(Color.green.opacity(0.8))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(remainingCalories) / Double(calorieManager.todaysCalories), 1)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.white)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: remainingCalories)
            
            VStack {
                Text("\(remainingCalories)")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                Text("calories left")
                    .font(.caption)
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct CalorieTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        CalorieTrackingView()
    }
}
