public enum RefreshingState {
    case initial, ready, loading
}

public typealias RefreshAction = (@escaping () -> Void) -> Void
