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
