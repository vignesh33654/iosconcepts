import SwiftUI

private enum ConceptRoute: String, CaseIterable, Identifiable {
    case movie = "Movie"
    case digilocker = "Digilocker"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .movie:
            "theatermasks"
        case .digilocker:
            "wallet.pass"
        }
    }
}

struct MainPage: View {
    @State private var selectedRoute = ConceptRoute.movie

    var body: some View {
        ZStack(alignment: .trailing) {
            Color.black.ignoresSafeArea()

            activeConcept
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            conceptSwitcher
        }
    }

    private var conceptSwitcher: some View {
        VStack(spacing: 0) {
            ForEach(ConceptRoute.allCases) { route in
                Button {
                    selectedRoute = route
                } label: {
                    Image(systemName: route.symbolName)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(selectedRoute == route ? .red : .white)
                        .frame(width: 24, height: 24)
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(route.rawValue)
                .accessibilityAddTraits(selectedRoute == route ? .isSelected : [])
            }
        }
        .padding(.vertical, 10)
        .background(Color.black, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        }
        .padding(.trailing,0)
    }

    @ViewBuilder
    private var activeConcept: some View {
        switch selectedRoute {
        case .movie:
            MovieHomePage()
        case .digilocker:
            Main()
        }
    }
}

#Preview {
    MainPage()
}
