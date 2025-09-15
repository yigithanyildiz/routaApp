import SwiftUI

struct DestinationDetailView: View {
    let destination: Destination
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dependencyContainer: DependencyContainer
    @State private var selectedBudgetType: TravelPlan.BudgetType = .standard
    @State private var showRouteGenerator = false
    @State private var selectedSection = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Clean Hero Header - Reduced Height
                ZStack(alignment: .bottomLeading) {
                    CustomAsyncImage(url: destination.imageURL, aspectRatio: 375/200)
                        .frame(height: 200)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                    
                    // Subtle gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    // Clean title overlay
                    VStack(alignment: .leading, spacing: 4) {
                        Text(destination.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Label(destination.country, systemImage: "mappin.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding()
                }
                
                // Quick Info Cards Section
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        // Weather Card
                        QuickInfoCard(
                            icon: "thermometer.medium",
                            title: "Sıcaklık",
                            subtitle: "\(destination.averageTemperature.summer)°C Yaz",
                            color: .orange
                        )
                        
                        // Best Time Card
                        QuickInfoCard(
                            icon: "calendar",
                            title: "En İyi Zaman",
                            subtitle: destination.popularMonths.first ?? "Yaz",
                            color: .green
                        )
                        
                        // Currency Card
                        QuickInfoCard(
                            icon: "dollarsign.circle",
                            title: "Para Birimi",
                            subtitle: destination.currency,
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                // Segmented Control for Sections
                VStack(spacing: 0) {
                    Picker("Sections", selection: $selectedSection) {
                        Text("Genel Bakış").tag(0)
                        Text("Ziyaret Yerleri").tag(1)
                        Text("Konaklama").tag(2)
                        Text("Seyahat İpuçları").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Content based on selected section
                    VStack(alignment: .leading, spacing: 20) {
                        switch selectedSection {
                        case 0:
                            OverviewSection(destination: destination)
                                .transition(.opacity)
                        case 1:
                            PlacesToVisitSection(destination: destination)
                                .transition(.opacity)
                        case 2:
                            AccommodationSection(destination: destination)
                                .transition(.opacity)
                        case 3:
                            TravelTipsSection(destination: destination)
                                .transition(.opacity)
                        default:
                            OverviewSection(destination: destination)
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .animation(.easeInOut(duration: 0.2), value: selectedSection)
                    .id(selectedSection)
                }
            }
            .padding(.bottom, 120)
        }
        .overlay(alignment: .bottom) {
            // Sticky Create Route Button
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ForEach(TravelPlan.BudgetType.allCases, id: \.self) { type in
                        BudgetTypeButton(
                            type: type,
                            isSelected: selectedBudgetType == type,
                            action: { selectedBudgetType = type }
                        )
                    }
                }
                
                Button(action: {
                    showRouteGenerator = true
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Rota Oluştur")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
            .padding()
            .background(Color(.systemBackground).opacity(0.95))
            .background(.ultraThinMaterial)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Kapat") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showRouteGenerator) {
            RouteGeneratorView(
                destination: destination,
                routeRepository: dependencyContainer.routeRepository
            )
        }
    }
}

// MARK: - Climate Card
struct ClimateCard: View {
    let title: String
    let temperature: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(temperature)°C")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Budget Type Button
struct BudgetTypeButton: View {
    let type: TravelPlan.BudgetType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(type.icon)
                    .font(.title2)
                
                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6)
            )
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Info Card
struct QuickInfoCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Overview Section
struct OverviewSection: View {
    let destination: Destination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Hakkında")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(destination.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Climate Info
            VStack(alignment: .leading, spacing: 16) {
                Text("İklim Bilgisi")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 16) {
                    ClimateCard(
                        title: "Yaz",
                        temperature: destination.averageTemperature.summer,
                        icon: "sun.max.fill",
                        color: .orange
                    )
                    
                    ClimateCard(
                        title: "Kış",
                        temperature: destination.averageTemperature.winter,
                        icon: "snowflake",
                        color: .blue
                    )
                }
            }
            
            // Best Time to Visit
            VStack(alignment: .leading, spacing: 16) {
                Text("En İyi Ziyaret Zamanı")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(destination.popularMonths, id: \.self) { month in
                            Text(month)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }
}

// MARK: - Places to Visit Section
struct PlacesToVisitSection: View {
    let destination: Destination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popüler Yerler")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Sample places - you would get these from your data source
            ForEach(0..<3, id: \.self) { index in
                DetailPlaceCard(
                    name: "Örnek Yer \(index + 1)",
                    type: "Tarihi Mekan",
                    rating: 4.5,
                    description: "Bu destinasyondaki önemli yerlerden biri."
                )
            }
        }
    }
}

// MARK: - Accommodation Section
struct AccommodationSection: View {
    let destination: Destination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Konaklama Seçenekleri")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Sample accommodations
            ForEach(0..<3, id: \.self) { index in
                DetailAccommodationCard(
                    name: "Örnek Otel \(index + 1)",
                    type: "Otel",
                    priceRange: "$$",
                    rating: 4.2
                )
            }
        }
    }
}

// MARK: - Travel Tips Section
struct TravelTipsSection: View {
    let destination: Destination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Seyahat İpuçları")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                TipCard(
                    icon: "info.circle.fill",
                    title: "Genel Bilgi",
                    content: "Yerel para birimi: \(destination.currency)\nDil: \(destination.language)",
                    color: .blue
                )
                
                TipCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "Önemli Notlar",
                    content: "Seyahat öncesi güncel bilgileri kontrol edin.",
                    color: .orange
                )
                
                TipCard(
                    icon: "heart.fill",
                    title: "Tavsiyeler",
                    content: "Yerel kültürü keşfetmeyi unutmayın!",
                    color: .pink
                )
            }
        }
    }
}

// MARK: - Supporting Cards
struct DetailPlaceCard: View {
    let name: String
    let type: String
    let rating: Double
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct DetailAccommodationCard: View {
    let name: String
    let type: String
    let priceRange: String
    let rating: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(type)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Text(priceRange)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        DestinationDetailView(destination: MockData.destinations[0])
            .environmentObject(DependencyContainer())
    }
}
