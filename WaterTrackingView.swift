import SwiftUI

struct WaterTrackingView: View {
    @ObservedObject var waterTrackingManager = WaterTrackingManager.shared
    @State private var selectedDate = Date()

    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: selectedDate)
    }

    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            Text("Click to track. Each Filled Drop = 8oz")
                .font(.title3)
                .padding()
            
            Text("Drink at least 64oz. -8by8 Rule")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                ForEach(0..<8) { index in
                    WaterCupView(isFilled: self.isCupFilled(index: index))
                        .onTapGesture {
                            self.toggleCup(index: index)
                        }
                }
            }
            .padding()
        }
        .accentColor(.green)
        .onChange(of: selectedDate) { _ in
            self.waterTrackingManager.fetchWaterEntries()
        }
    }
    // function to check if a cup at a specific spot is filled
    func isCupFilled(index: Int) -> Bool {
        guard let entry = waterTrackingManager.entryForDate(selectedDate) else {
            return false
        }
        return entry.cups.count > index && entry.cups[index]
    }
    // change the state of the cup
    func toggleCup(index: Int) {
        var cupsStatus = waterTrackingManager.entryForDate(selectedDate)?.cups ?? Array(repeating: false, count: 8)
        cupsStatus[index] = !cupsStatus[index]
        waterTrackingManager.addOrUpdateWaterEntry(date: selectedDate, cups: cupsStatus)
    }
}
// displays the water cup
struct WaterCupView: View {
    var isFilled: Bool
    
    var body: some View {
        Image(systemName: isFilled ? "drop.fill" : "drop")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(10)
            .foregroundColor(isFilled ? .blue.opacity(0.8) : .black.opacity(0.8))
            .animation(.default, value: isFilled)
    }
}
