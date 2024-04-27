import SwiftUI

struct LabelView: View {
    @State private var isActive = false
    @EnvironmentObject var calorieManager: CalorieManager
    @State private var isUserDetailsViewPresented = false

    var body: some View {
        if isActive {
            TrackOptionsView().environmentObject(calorieManager)
        } else {
            Image("Image 1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300) 
                
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0, green: 0.1, blue: 0.2))
                .edgesIgnoringSafeArea(.all)
        }
    }

        
    }
        

