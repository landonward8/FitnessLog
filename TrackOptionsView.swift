import SwiftUI

struct TrackOptionsView: View {
    @EnvironmentObject var calorieManager: CalorieManager
    @State private var isUserDetailsViewPresented = false
    // grid layout for the buttons
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    let buttonHeight: CGFloat = 100
    let buttonWidth: CGFloat = 140
    // main body of the view
    var body: some View {
        ScrollView {
            HStack {
                Text("The only bad workout is the one that didn't happen.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Spacer()
                
                CircleProgressView(remainingCalories: $calorieManager.remainingCalories)
                    .frame(width: 150, height: 150)
            }
            .padding()
            // column layout for buttons
            LazyVGrid(columns: columns, spacing: 20) {
                
                NavigationLink(destination: CalorieTrackingView().environmentObject(calorieManager)) {
                    buttonContent(iconName: "flame.fill", text: "Calorie Tracking")
                }
                
                NavigationLink(destination: SleepTrackingView().environmentObject(calorieManager)) {
                    buttonContent(iconName: "moon.fill", text: "Sleep Tracking")
                }
                
                NavigationLink(destination: MoodTrackingView().environmentObject(calorieManager)) {
                    buttonContent(iconName: "book.fill", text: "Journal")
                }
                NavigationLink(destination: WeightTrackingView()) {
                    buttonContent(iconName: "chart.bar.fill", text: "Weight Tracking")
                }
                
                NavigationLink(destination: WaterTrackingView()) {
                    buttonContent(iconName: "drop.fill", text: "Water Tracking")
                }
                
                
                
                Button(action: {
                    isUserDetailsViewPresented = true
                }) {
                    buttonContent(iconName: "person.fill", text: "Profile")
                }
                .sheet(isPresented: $isUserDetailsViewPresented) {
                    UserDetailsView(isPresented: $isUserDetailsViewPresented)
                }
            }
            Spacer()
            HStack {
                Spacer()
                Text("FitnessLog")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Image("Image 1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                Spacer()
            }
           .padding()
        
        }
        .onAppear() {
            fetchLatestData()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0, green: 0.1, blue: 0.2))
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    private func fetchLatestData() {
        calorieManager.fetchTodaysCalories()
    }
    // got this from chat gpt. builds the buttons puts it into the v grid
    @ViewBuilder
    private func buttonContent(iconName: String, text: String) -> some View {
        VStack {
        Image(systemName: iconName)
            .resizable()
            .scaledToFit()
            .frame(height: 50)
            .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
        }
        .frame(width: buttonWidth, height: buttonHeight)
        .padding()
        .background(Color(red: 0, green: 0.1, blue: 0.2))
        .cornerRadius(10)
        .overlay(
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.green.opacity(0.8), lineWidth: 2))
        
    }
    
}

