enum SeatState {
    case available
    case selected
    case sold

    var accessibilityValue: String {
        switch self {
        case .available: return "available"
        case .selected: return "selected"
        case .sold: return "sold"
        }
    }
}
