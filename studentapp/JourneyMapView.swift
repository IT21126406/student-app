import SwiftUI
import MapKit
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct Milestone: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let badge: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}

struct JourneyMapView: View {
    @State private var milestones: [Milestone] = []
    @State private var isLoading = true
    @State private var selection: Milestone? = nil
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
    )

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading journey map…")
                    .task { await fetchJourney() }
            } else {
                Map(initialPosition: .region(region), selection: $selection) {
                    ForEach(milestones) { m in
                        Annotation(m.name, coordinate: m.coordinate, anchor: .bottom) {
                            VStack(spacing: 4) {
                                Text(m.badge).font(.title)
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
                            .padding(6)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .onTapGesture { selection = m }
                        }
                        .tag(m)
                        .annotationTitles(.hidden)
                    }
                }
                .mapControls { MapUserLocationButton(); MapCompass() }
                .mapStyle(.standard(elevation: .realistic))
                .edgesIgnoringSafeArea(.all)
                .sheet(item: $selection) { m in
                    MilestoneDetailView(milestone: m)
                }
            }
        }
        .navigationTitle("Journey Map")
    }

    func fetchJourney() async {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let docRef = db.collection("progress").document("journey")
        do {
            let snap = try await docRef.getDocument()
            if let data = snap.data(),
               let raw = data["milestones"] as? [[String: Any]] {
                let parsed = raw.compactMap { dict -> Milestone? in
                    guard let name = dict["name"] as? String,
                          let badge = dict["badge"] as? String,
                          let lat = dict["latitude"] as? Double,
                          let lon = dict["longitude"] as? Double else { return nil }
                    return Milestone(name: name, badge: badge, latitude: lat, longitude: lon)
                }
                if !parsed.isEmpty {
                    milestones = parsed
                    region.center = parsed[0].coordinate
                } else { populateFallback() }
            } else { populateFallback() }
        } catch {
            print("Firestore fetch error:", error.localizedDescription)
            populateFallback()
        }
        #else
        populateFallback()
        #endif
        isLoading = false
    }

    func populateFallback() {
        milestones = [
            Milestone(name: "First 7 Days", badge: "", latitude: 40.7128, longitude: -74.0060),
            Milestone(name: "Month 1 Complete", badge: "", latitude: 34.0522, longitude: -118.2437),
            Milestone(name: "Language Milestone", badge: "", latitude: 51.5074, longitude: -0.1278)
        ]
        region.center = milestones[0].coordinate
    }
}

struct MilestoneDetailView: View {
    let milestone: Milestone
    var body: some View {
        VStack(spacing: 16) {
            Text(milestone.badge).font(.system(size: 64))
            Text(milestone.name).font(.title2.bold()).multilineTextAlignment(.center)
            Text("Lat: \(milestone.latitude), Lon: \(milestone.longitude)")
                .font(.caption).foregroundColor(.secondary)
            Spacer()
            Button(action: openInAppleMaps) {
                Text("Open in Apple Maps")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient.appPurplePink)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    func openInAppleMaps() {
        let placemark = MKPlacemark(coordinate: milestone.coordinate)
        MKMapItem(placemark: placemark).apply { $0.name = milestone.name; $0.openInMaps() }
    }
}

private extension MKMapItem {
    func apply(_ block: (MKMapItem) -> Void) { block(self) }
}

struct JourneyMapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { JourneyMapView() }
    }
}
