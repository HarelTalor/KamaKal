import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("KamaKal 🔥")
                .font(.largeTitle)
                .fontWeight(.bold)
                .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
