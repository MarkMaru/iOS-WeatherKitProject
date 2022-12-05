import SwiftUI
import CoreLocation
import WeatherKit

class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, currentLocation == nil else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
        }
    }
}

struct ContentView: View {
    
    let weatherService = WeatherService.shared
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }.task(id: locationManager.currentLocation) {
            do {
                if let location = locationManager.currentLocation {
                    let weather = try await weatherService.weather(for: location)
                    print(weather)
                }
            } catch {
                print(error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
