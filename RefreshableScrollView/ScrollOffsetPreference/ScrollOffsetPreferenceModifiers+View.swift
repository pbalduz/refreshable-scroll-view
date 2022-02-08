import SwiftUI

extension View {
    func scrollOffsetPreference(_ viewType: ScrollOffsetPreferenceTypes.ViewType) -> some View {
        modifier(ScrollOffsetPreferenceModifier(viewType: viewType))
    }
    
    func onScrollOffsetChange(perform action: @escaping (CGFloat) -> Void) -> some View {
        modifier(OnScrollOffsetPreferenceChangeModifier(action: action))
    }
}
