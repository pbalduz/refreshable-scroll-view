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

struct OnScrollOffsetPreferenceChangeModifier: ViewModifier {
    
    var action: (CGFloat) -> Void
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(ScrollOffsetPreferenceTypes.Key.self) { values in
                let scrollOffset: CGFloat = {
                    guard
                        let first = values.first(where: { $0.type == .static }),
                        let last = values.last(where: { $0.type == .scrollable })
                    else {
                        return 0
                    }
                    return last.offset - first.offset
                }()
                action(scrollOffset)
            }
    }
}

// MARK: - ScrollOffsetPreferenceModifier + View

extension View {
    func scrollOffsetPreference(_ viewType: ScrollOffsetPreferenceTypes.ViewType) -> some View {
        modifier(ScrollOffsetPreferenceModifier(viewType: viewType))
    }
    
    func onScrollOffsetChange(perform action: @escaping (CGFloat) -> Void) -> some View {
        modifier(OnScrollOffsetPreferenceChangeModifier(action: action))
    }
}
