import SwiftUI

struct BluetoothDevice: Identifiable {
    let id = UUID()
    let nombre: String
    var conectado: Bool
}

struct ContentView: View {
    @State private var mostrarMensaje = false
    @State private var bluetoothActivo = false
    @State private var dispositivos = [
        BluetoothDevice(nombre: "Audífonos Pro", conectado: false),
        BluetoothDevice(nombre: "Teclado Inalámbrico", conectado: false),
        BluetoothDevice(nombre: "Bocina Portátil", conectado: false)
    ]

    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()

            ScrollView {
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
                        Text("¡Lo logré!")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }

                    bluetoothSection
                }
                .padding()
            }
        }
    }

    private var bluetoothSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Conexiones Bluetooth")
                .font(.title3)
                .bold()
                .foregroundColor(.white)

            Toggle(isOn: $bluetoothActivo) {
                Text(bluetoothActivo ? "Bluetooth activado" : "Bluetooth desactivado")
                    .foregroundColor(.white)
            }
            .toggleStyle(SwitchToggleStyle(tint: .green))

            if bluetoothActivo {
                VStack(spacing: 12) {
                    ForEach(dispositivos.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dispositivos[index].nombre)
                                    .font(.headline)
                                Text(dispositivos[index].conectado ? "Conectado" : "Disponible")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Button(dispositivos[index].conectado ? "Desconectar" : "Conectar") {
                                dispositivos[index].conectado.toggle()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(dispositivos[index].conectado ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
            } else {
                Text("Activa Bluetooth para buscar y conectar dispositivos.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(16)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
