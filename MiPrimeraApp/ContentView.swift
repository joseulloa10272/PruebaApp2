import SwiftUI

struct ContentView: View {
    @State private var mostrarMensaje = false

    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Button("Presióname") {
                    mostrarMensaje = true
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundColor(.blue)
                .cornerRadius(10)

                if mostrarMensaje {
                    Text("Ricardo puto lo logre")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
