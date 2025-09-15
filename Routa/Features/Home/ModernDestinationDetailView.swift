import SwiftUI
import MapKit

struct ModernDestinationDetailView: View {
    let destination: Destination
    @EnvironmentObject var dependencyContainer: DependencyContainer
    @Environment(\.dismiss) var dismiss
    
    @State private var showRouteGenerator = false
    @State private var showFullScreenMap = false
    @State private var mapCameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background
                Color.routaBackground
                    .ignoresSafeArea()
                
                // Main Scrollable Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Image Section (scrollable)
                        heroImageSection(geometry: geometry)
                        
                        // Content Sections
                        VStack(spacing: 20) {
                            overviewSection
                            weatherInfoSection  
                            quickFactsSection
                            mapSection
                            popularPlacesSection
                            bestTimeToVisitSection
                            
                            // Create Route Button Section
                            createRouteButtonSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 100) // For tab bar space
                }
                
                // Navigation Overlay
                navigationOverlay
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showRouteGenerator) {
            RouteGeneratorView(
                destination: destination,
                routeRepository: dependencyContainer.routeRepository
            )
        }
        .sheet(isPresented: $showFullScreenMap) {
            DestinationMapView(destination: destination)
        }
    }
    
    // MARK: - Hero Image Section
    private func heroImageSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Hero Image
            CustomAsyncImage(url: destination.imageURL, aspectRatio: 16/10)
                .frame(width: geometry.size.width)
                .frame(height: 350)
                .clipped()
            
            // Gradient Overlay
            LinearGradient(
                colors: [
                    .clear,
                    .clear,
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: geometry.size.width)
            .frame(height: 350)
            
            // Content Overlay
            VStack(alignment: .leading, spacing: 12) {
                Text(destination.name)
                    .font(.routaTitle1(.bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                        Text(destination.country)
                    }
                    .font(.headline)
                    .foregroundColor(Color.white.opacity(0.9))
                    
                    Spacer()
                    
                    // Weather badges
                    HStack(spacing: 6) {
                        WeatherBadge(
                            icon: "sun.max.fill",
                            temp: destination.averageTemperature.summer,
                            color: .orange
                        )
                        WeatherBadge(
                            icon: "snowflake",
                            temp: destination.averageTemperature.winter,
                            color: .blue
                        )
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .frame(width: geometry.size.width)
        .frame(height: 350)
        .ignoresSafeArea(.container, edges: .top)
    }
    
    // MARK: - Navigation Overlay
    private var navigationOverlay: some View {
        VStack {
            HStack {
                // Back Button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.black.opacity(0.4),
                                            Color.black.opacity(0.6)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Favorite Button
                    FavoriteButton(destinationId: destination.id, size: .large)
                    
                    Button {
                        // Share functionality
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.black.opacity(0.4),
                                                Color.black.opacity(0.6)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 8)
        }
    }
    // MARK: - Overview Section
    private var overviewSection: some View {
        RoutaCard(style: .standard, elevation: .medium) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Genel Bakış")
                    .routaTitle2()
                    .foregroundColor(.routaText)
                
                Text(destination.description)
                    .routaBody()
                    .foregroundColor(.routaTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 8) {
                    InfoPill(
                        icon: "dollarsign.circle.fill",
                        text: destination.currency,
                        color: .routaSuccess
                    )
                    InfoPill(
                        icon: "bubble.left.fill",
                        text: destination.language,
                        color: .routaInfo
                    )
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Popular Places Section
    private var popularPlacesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popüler Yerler")
                .routaTitle2()
                .foregroundColor(.routaText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(destination.popularPlaces, id: \.id) { place in
                        ModernPlaceCard(
                            popularPlace: place
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, -16) // Negative padding to extend scroll to edges
        .padding(.leading, 16) // Add back left padding for title
    }
    
    // MARK: - Best Time to Visit Section
    private var bestTimeToVisitSection: some View {
        RoutaCard(style: .glassmorphic, elevation: .low) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("En İyi Ziyaret Zamanı")
                        .routaTitle3()
                        .foregroundColor(.routaText)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(destination.popularMonths, id: \.self) { month in
                        Text(month)
                            .font(.routaCaption1(.bold))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .frame(maxWidth: 75) // Bu satırı ekle

                            .background(
                                Capsule()
                                    .fill(RoutaGradients.primaryGradient)
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Weather Info Section
    private var weatherInfoSection: some View {
        RoutaCard(style: .gradient, elevation: .high) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .font(.title2)
                        .foregroundColor(Color.white)
                    
                    Text("İklim Bilgisi")
                        .routaTitle3()
                        .foregroundColor(Color.white)
                }
                
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("YAZ")
                            .routaCaption1()
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Text("\(destination.averageTemperature.summer)°C")
                            .routaTitle2()
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
                    
                    VStack(spacing: 4) {
                        Text("KIŞ")
                            .routaCaption1()
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Text("\(destination.averageTemperature.winter)°C")
                            .routaTitle2()
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
                }
            }
        }
    }
    
    // MARK: - Quick Facts Section
    private var quickFactsSection: some View {
        RoutaCard(style: .neumorphic, elevation: .medium) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hızlı Bilgiler")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(spacing: 8) {
                    QuickFactRow(
                        icon: "creditcard.fill",
                        title: "Para Birimi",
                        value: destination.currency,
                        color: .routaSuccess
                    )
                    
                    QuickFactRow(
                        icon: "textformat",
                        title: "Dil",
                        value: destination.language,
                        color: .routaInfo
                    )
                    
                    QuickFactRow(
                        icon: "thermometer.medium",
                        title: "Ortalama Sıcaklık",
                        value: "\(destination.averageTemperature.summer)°C / \(destination.averageTemperature.winter)°C",
                        color: .routaWarning
                    )
                }
            }
        }
    }
    
    // MARK: - Map Section
    private var mapSection: some View {
        RoutaCard(style: .standard, elevation: .medium) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.title2)
                        .foregroundColor(.routaPrimary)
                    
                    Text("Konum ve Popüler Yerler")
                        .routaTitle3()
                        .foregroundColor(.routaText)
                }
                
                // Mini Map Preview
                ZStack {
                    Map(position: $mapCameraPosition) {
                        // Destination marker
                        Marker(destination.name, coordinate: destination.coordinates.clLocationCoordinate2D)
                            .tint(Color.routaPrimary)
                        
                        // Popular places markers
                        ForEach(destination.popularPlaces, id: \.id) { place in
                            Marker(place.name, coordinate: place.coordinate.clLocationCoordinate2D)
                                .tint(Color.routaSecondary)
                        }
                    }
                    .mapStyle(.standard)
                    .mapControls {
                        MapUserLocationButton()
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .disabled(true)
                    .onAppear {
                        mapCameraPosition = MapCameraPosition.region(
                            MKCoordinateRegion(
                                center: destination.coordinates.clLocationCoordinate2D,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                        )
                    }
                    
                    // Overlay to make map non-interactive and show view button
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showFullScreenMap = true
                        }
                }
                
                // Popular Places Quick Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Popüler Yerler")
                        .routaCallout()
                        .foregroundColor(.routaTextSecondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(Array(destination.popularPlaces.prefix(4)), id: \.id) { place in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(RoutaGradients.primaryGradient)
                                    .frame(width: 8, height: 8)
                                
                                Text(place.name)
                                    .routaCaption1()
                                    .foregroundColor(.routaText)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .font(.caption2)
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", place.rating))
                                        .routaCaption2()
                                        .foregroundColor(.routaTextSecondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                // View Full Map Button
                Button {
                    showFullScreenMap = true
                } label: {
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(.blue)
                        
                        Text("Haritayı Görüntüle")
                            .routaCallout()  // Sadece Text'e uygula
                            .foregroundColor(.blue)  // Geçici olarak .blue kullan
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.routaPrimary.opacity(0.1))
                    )
                }
            }
        }
    }
    
    // MARK: - Create Route Button Section
    private var createRouteButtonSection: some View {
        VStack(spacing: 16) {
   

            Button {
                showRouteGenerator = true
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.title2)
                    Text("Rota Oluştur")
                        .routaHeadline()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RoutaGradients.primaryGradient)
                )
            }
            .routaShadow(.medium)
        }
        .padding(.top, 8)
    }
}

// MARK: - Supporting Components

struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: RoutaSpacing.xs) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .routaCaption1()
        }
        .foregroundColor(color)
        .padding(.horizontal, RoutaSpacing.sm)
        .padding(.vertical, RoutaSpacing.xs)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

struct ModernPlaceCard: View {
    let popularPlace: PopularPlace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CustomAsyncImage(url: popularPlace.imageURL, aspectRatio: 4/3)
                .frame(width: 160, height: 120)
                .cornerRadius(12)
                .clipped()
                .overlay(
                    HStack {
                        Spacer()
                        VStack {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption2)
                                Text(String(format: "%.1f", popularPlace.rating))
                                    .routaCaption2()
                                    .foregroundColor(Color.white)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.6))
                            )
                            Spacer()
                        }
                        .padding(4)
                    }
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(popularPlace.name)
                    .routaCaption1()
                    .foregroundColor(.routaText)
                    .lineLimit(1)
                
                Text(popularPlace.type)
                    .routaCaption2()
                    .foregroundColor(.routaTextSecondary)
                    .lineLimit(1)
            }
            .frame(width: 160, alignment: .leading)
        }
        .frame(width: 160)
        .routaShadow(.low)
    }
}

struct QuickFactRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .routaCallout()
                .foregroundColor(.routaTextSecondary)
            
            Spacer()
            
            Text(value)
                .routaCallout()
                .foregroundColor(.routaText)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ModernDestinationDetailView(destination: MockData.destinations[0])
            .environmentObject(DependencyContainer())
    }
}
