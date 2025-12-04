import SwiftUI

// MARK: - Random Destination Sheet

struct RandomDestinationSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dependencyContainer: DependencyContainer
    let destination: Destination
    let onTryAgain: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.routaBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: RoutaSpacing.xl) {
                        // Header
                        headerSection

                        // Destination Card
                        destinationCard

                        // Action Buttons
                        actionButtons
                    }
                    .padding(RoutaSpacing.lg)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.routaTextSecondary)
                            .font(.system(size: 24))
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: RoutaSpacing.md) {
            // Sparkle animation
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.routaPrimary.opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.routaPrimary, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, RoutaSpacing.lg)

            Text("✨ Senin İçin Seçtik!")
                .routaTitle1()
                .foregroundColor(.routaText)
                .multilineTextAlignment(.center)

            Text("Dünya seni buralara götürüyor")
                .routaBody()
                .foregroundColor(.routaTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Destination Card

    private var destinationCard: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            // Image
            if let url = URL(string: destination.imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        shimmerImagePlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .failure:
                        imagePlaceholder
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }

            // Destination Info
            VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                // City name
                Text(destination.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.routaText)

                // Country with flag
                HStack(spacing: RoutaSpacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.routaPrimary)

                    Text(destination.country)
                        .routaTitle3()
                        .foregroundColor(.routaTextSecondary)
                }

                // Description
                if !destination.description.isEmpty {
                    Text(destination.description)
                        .routaBody()
                        .foregroundColor(.routaText)
                        .lineLimit(4)
                        .padding(.top, RoutaSpacing.sm)
                }

                // Best time to visit
                if !destination.popularMonths.isEmpty {
                    HStack(spacing: RoutaSpacing.xs) {
                        Image(systemName: "calendar")
                            .foregroundColor(.routaPrimary)
                            .font(.system(size: 14))

                        Text("En İyi: \(destination.popularMonths.prefix(3).joined(separator: ", "))")
                            .routaCaption1()
                            .foregroundColor(.routaTextSecondary)
                    }
                    .padding(.top, RoutaSpacing.sm)
                }
            }
            .padding(RoutaSpacing.lg)
        }
        .background(Color.routaSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .routaShadow(.medium)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: RoutaSpacing.md) {
            // View Details Button
            NavigationLink(destination: ModernDestinationDetailView(destination: destination)
                .environmentObject(dependencyContainer)
            ) {
                HStack {
                    Image(systemName: "eye.fill")
                    Text("İncele")
                        .font(.routaCallout(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(RoutaSpacing.md)
                .background(
                    RoutaGradients.primaryGradient
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .routaShadow(.medium)
            }
            .simultaneousGesture(TapGesture().onEnded {
                RoutaHapticsManager.shared.buttonTap()
            })

            // Try Again Button
            Button(action: {
                RoutaHapticsManager.shared.selection()
                dismiss()
                // Small delay before triggering new spin
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onTryAgain()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Başka Öner")
                        .font(.routaCallout(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(RoutaSpacing.md)
                .background(Color.routaSurface)
                .foregroundColor(.routaPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.routaPrimary, lineWidth: 2)
                )
            }
        }
        .padding(.bottom, RoutaSpacing.lg)
    }

    // MARK: - Placeholder Views

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(RoutaGradients.primaryGradient)
            .frame(height: 200)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.5))
            )
    }

    private var shimmerImagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.routaSurface)
            .frame(height: 200)
            .overlay(
                ProgressView()
                    .tint(.routaPrimary)
            )
    }
}

// MARK: - Preview

#Preview {
    RandomDestinationSheet(
        destination: Destination(
            id: "paris-france",
            name: "Paris",
            country: "Fransa",
            description: "Işıklar şehri Paris, Eyfel Kulesi, Louvre Müzesi ve romantik atmosferiyle ünlü bir destinasyon.",
            imageURL: "https://example.com/paris.jpg",
            popularMonths: ["Nisan", "Mayıs", "Haziran", "Eylül"],
            averageTemperature: Destination.Temperature(summer: 25, winter: 5),
            currency: "EUR",
            language: "Fransızca",
            coordinates: Destination.Coordinates(latitude: 48.8566, longitude: 2.3522),
            address: "Paris, Fransa",
            popularPlaces: [],
            climate: "Ilıman",
            costOfLiving: nil,
            topAttractions: nil,
            travelStyle: nil,
            bestFor: nil,
            popularity: nil,
            rating: nil,
            createdAt: nil,
            updatedAt: nil
        ),
        onTryAgain: {
            print("Try again tapped")
        }
    )
    .environmentObject(DependencyContainer())
}
