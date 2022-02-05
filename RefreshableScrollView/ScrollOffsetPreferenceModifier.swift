import SwiftUI

struct ScrollOffsetPreferenceModifier: ViewModifier {
    
    var viewType: ScrollOffsetPreferenceTypes.ViewType
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceTypes.Key.self,
                            value: [
                                .init(
                                    type: viewType,
                                    offset: proxy.frame(in: .global).minY
                                )
                            ]
                        )
                }
            )
    }
}

// MARK: - ScrollOffsetPreferenceModifier + View

extension View {
    func scrollOffsetPreference(_ viewType: ScrollOffsetPreferenceTypes.ViewType) -> some View {
        modifier(ScrollOffsetPreferenceModifier(viewType: viewType))
    }
}
