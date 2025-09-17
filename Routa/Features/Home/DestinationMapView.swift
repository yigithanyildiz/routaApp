import SwiftUI
import MapKit
import Foundation

struct DestinationMapView: View {
    let destination: Destination
    @Environment(\.dismiss) var dismiss
    
    @State private var cameraPosition: MapCameraPosition
    @State private var selectedPlace: PopularPlace?
    @State private var showPlaceDetail = false
    
    init(destination: Destination) {
        self.destination = destination
        _cameraPosition = State(initialValue: Self.initialCameraPosition(for: destination))
    }
    
    private static func initialCameraPosition(for destination: Destination) -> MapCameraPosition {
        MapCameraPosition.region(
            MKCoordinateRegion(
                center: destination.coordinates.clLocationCoordinate2D,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        )
    }
    
    private var hasSelectedPlace: Bool {
        showPlaceDetail && selectedPlace != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                mapView
                
                if hasSelectedPlace, let selectedPlace = selectedPlace {
                    placeDetailOverlay(for: selectedPlace)
                }
            }
            .navigationTitle(destination.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    mapOptionsMenu
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showPlaceDetail)
    }
    
    @ViewBuilder
    private var mapView: some View {
        Map(position: $cameraPosition) {
            ForEach(allMapItems) { item in
                Annotation(item.name, coordinate: item.coordinate) {
                    CustomMapAnnotation(
                        item: item,
                        isSelected: isItemSelected(item)
                    )
                    .onTapGesture {
                        handleAnnotationTap(for: item)
                    }
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .ignoresSafeArea()
    }
    
    
    private func isItemSelected(_ item: MapItem) -> Bool {
        selectedPlace?.id == item.id
    }
    
    private func handleAnnotationTap(for item: MapItem) {
        if let place = destination.popularPlaces.first(where: { $0.id == item.id }) {
            selectedPlace = place
            showPlaceDetail = true
        }
    }
    
    @ViewBuilder
    private func placeDetailOverlay(for place: PopularPlace) -> some View {
        VStack {
            Spacer()
            PlaceDetailCard(place: place) {
                showPlaceDetail = false
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    @ViewBuilder
    private var closeButton: some View {
        Button("Kapat") {
            dismiss()
        }
    }
    
    @ViewBuilder
    private var mapOptionsMenu: some View {
        Menu {
            showAllPlacesButton
            showCenterButton
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    @ViewBuilder
    private var showAllPlacesButton: some View {
        Button {
            zoomToFitAllPlaces()
        } label: {
            Label("Tüm Yerleri Göster", systemImage: "viewfinder")
        }
    }
    
    @ViewBuilder
    private var showCenterButton: some View {
        Button {
            resetToDestinationCenter()
        } label: {
            Label("Merkezi Göster", systemImage: "location")
        }
    }
    
    private func resetToDestinationCenter() {
        cameraPosition = Self.initialCameraPosition(for: destination)
    }
    
    private var allMapItems: [MapItem] {
        var items: [MapItem] = []
        items.append(destinationMapItem)
        items.append(contentsOf: popularPlaceMapItems)
        return items
    }
    
    private var destinationMapItem: MapItem {
        MapItem(
            id: destination.id,
            name: destination.name,
            coordinate: destination.coordinates.clLocationCoordinate2D,
            type: .destination
        )
    }
    
    private var popularPlaceMapItems: [MapItem] {
        destination.popularPlaces.map { place in
            MapItem(
                id: place.id,
                name: place.name,
                coordinate: place.coordinate.clLocationCoordinate2D,
                type: .popularPlace
            )
        }
    }
    
    private func zoomToFitAllPlaces() {
        let coordinates = allMapItems.map { $0.coordinate }
        guard !coordinates.isEmpty else { return }
        
        let bounds = calculateCoordinateBounds(from: coordinates)
        let center = calculateCenter(from: bounds)
        let span = calculateSpan(from: bounds)
        
        cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: center, span: span))
    }
    
    private func calculateCoordinateBounds(from coordinates: [CLLocationCoordinate2D]) -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) {
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        return (
            minLat: latitudes.min() ?? 0,
            maxLat: latitudes.max() ?? 0,
            minLon: longitudes.min() ?? 0,
            maxLon: longitudes.max() ?? 0
        )
    }
    
    private func calculateCenter(from bounds: (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double)) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: (bounds.minLat + bounds.maxLat) / 2,
            longitude: (bounds.minLon + bounds.maxLon) / 2
        )
    }
    
    private func calculateSpan(from bounds: (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double)) -> MKCoordinateSpan {
        MKCoordinateSpan(
            latitudeDelta: (bounds.maxLat - bounds.minLat) * 1.2,
            longitudeDelta: (bounds.maxLon - bounds.minLon) * 1.2
        )
    }
}

// MARK: - Supporting Types

struct MapItem: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let type: MapItemType
    
    enum MapItemType {
        case destination
        case popularPlace
    }
}

struct CustomMapAnnotation: View {
    let item: MapItem
    let isSelected: Bool
    
    private var pinSize: CGFloat {
        isSelected ? 24 : 20
    }
    
    private var strokeWidth: CGFloat {
        isSelected ? 3 : 2
    }
    
    private var iconSize: CGFloat {
        isSelected ? 10 : 8
    }
    
    private var scaleEffect: CGFloat {
        isSelected ? 1.2 : 1.0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            pinButton
            
            if isSelected {
                nameLabel
            }
        }
    }
    
    @ViewBuilder
    private var pinButton: some View {
        pinContent
            .scaleEffect(scaleEffect)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    @ViewBuilder
    private var pinContent: some View {
        ZStack {
            pinBackground
            pinIcon
        }
    }
    
    @ViewBuilder
    private var pinBackground: some View {
        Circle()
            .fill(pinColor)
            .frame(width: pinSize, height: pinSize)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: strokeWidth)
            )
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var pinIcon: some View {
        Image(systemName: pinIconName)
            .font(.system(size: iconSize, weight: .bold))
            .foregroundColor(.white)
    }
    
    @ViewBuilder
    private var nameLabel: some View {
        Text(item.name)
            .routaCaption2()
            .foregroundColor(.routaText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(labelBackground)
            .offset(y: 5)
    }
    
    @ViewBuilder
    private var labelBackground: some View {
        Capsule()
            .fill(.regularMaterial)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var pinColor: Color {
        switch item.type {
        case .destination:
            return .routaPrimary
        case .popularPlace:
            return .routaSecondary
        }
    }
    
    private var pinIconName: String {
        switch item.type {
        case .destination:
            return "star.fill"
        case .popularPlace:
            return "mappin"
        }
    }
}

struct PlaceDetailCard: View {
    let place: PopularPlace
    let onClose: () -> Void
    
    private var ratingText: String {
        String(format: "%.1f", place.rating)
    }
    
    var body: some View {
        RoutaCard(style: .standard, elevation: .high) {
            VStack(alignment: .leading, spacing: 12) {
                headerSection
                descriptionSection
                directionsButton
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            placeInfo
            Spacer()
            ratingSection
            closeButton
        }
    }
    
    @ViewBuilder
    private var placeInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .routaTitle3()
                .foregroundColor(.routaText)
            
            Text(place.type)
                .routaCaption1()
                .foregroundColor(.routaTextSecondary)
        }
    }
    
    @ViewBuilder
    private var ratingSection: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            Text(ratingText)
                .routaCaption1()
                .foregroundColor(.routaText)
        }
    }
    
    @ViewBuilder
    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.routaTextSecondary)
        }
    }
    
    @ViewBuilder
    private var descriptionSection: some View {
        Text(place.description)
            .routaCaption1()
            .foregroundColor(.routaTextSecondary)
            .lineLimit(2)
    }
    
    @ViewBuilder
    private var directionsButton: some View {
        Button {
            openInMaps()
        } label: {
            directionsButtonContent
        }
    }
    
    @ViewBuilder
    private var directionsButtonContent: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(.blue)
            
            Text("Yol tarifi al")
                .routaCallout()
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(directionsButtonBackground)
    }
    
    @ViewBuilder
    private var directionsButtonBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.routaPrimary.opacity(0.1))
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: place.coordinate.clLocationCoordinate2D)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

#Preview {
    DestinationMapView(destination: MockData.destinations[0])
}
