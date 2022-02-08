import SwiftUI

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
