import SwiftUI

struct WeightTrackingView: View {
    @State private var currentWeight: Double = 0
    @State private var selectedDate = Date()
    @State private var sliderRange: ClosedRange<Double> = 50...1000
    // range from 50-1000 that the user can select.
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date:", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .onChange(of: selectedDate, perform: { newDate in
                        fetchWeight(for: newDate)
                    })
                    .padding()
            
                WeightDisplayView(currentWeight: $currentWeight, range: sliderRange)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("Save Weight") {
                    saveWeight()
                }
                .padding()
            }
            .accentColor(.green)
            .navigationBarTitle("Weight Tracking", displayMode: .inline)
            .onAppear {
                fetchWeight(for: selectedDate)
            }
        }
    }

    private func saveWeight() {
        WeightDatabaseManager.shared.addWeightEntry(date: selectedDate, weight: currentWeight)
        fetchWeight(for: selectedDate) // refetch the weight to the UI.
    }
    // adjust slider range for the first entry in the database. 
    private func fetchWeight(for date: Date) {
        let weightHistory = WeightDatabaseManager.shared.fetchWeightHistory()
        if let firstWeightEntry = weightHistory.first?.weight {
            // Set a range of +- 75 around the first weight entry
            sliderRange = (firstWeightEntry - 75)...(firstWeightEntry + 75)
        }
        
        if let weight = WeightDatabaseManager.shared.fetchWeight(for: date) {
            currentWeight = weight
        } else {
            currentWeight = (sliderRange.lowerBound + sliderRange.upperBound) / 2
        }
    }
}

struct WeightDisplayView: View {
    @Binding var currentWeight: Double
    var range: ClosedRange<Double>

    var body: some View {
        VStack {
            Text("Current Weight")
                .font(.headline)
                .foregroundColor(.white)

            Text("\(currentWeight, specifier: "%.1f") lbs")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white)
                .padding()

            RulerSlider(value: $currentWeight, range: range)
                .accentColor(.green)
                .frame(height: 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0, green: 0.1, blue: 0.2))
        .cornerRadius(20)
    }
}

struct RulerSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        Slider(value: $value, in: range)
            .transformEffect(CGAffineTransform(scaleX: 1, y: 1)) 
    }
}

struct ParentView: View {
    var body: some View {
        WeightTrackingView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
    }
}
