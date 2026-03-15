import SwiftUI

struct ContentView: View {
    @State private var mensaje = "Hola, mundo!"

    var body: some View {
        VStack(spacing: 20) {
            Text(mensaje)
                .font(.title)
                .padding()
            Button("Presióname") {
                mensaje = "Has presionado el botón"
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

