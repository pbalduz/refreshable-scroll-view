import SwiftUI

struct RefreshableScrollView: View {
    @State private var contentOffset: CGFloat = .zero
    @State private var isRefreshing: Bool = false
    
    private var refreshOffset: CGFloat {
        if isRefreshing {
            return max(contentOffset, 60)
        }
        return max(contentOffset, 0)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.orange
                .frame(height: 60)
            GeometryReader { staticViewProxy in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceTypes.Key.self,
                        value: [
                            .init(
                                type: .static,
                                offset: staticViewProxy.frame(in: .global).minY
                            )
                        ]
                    )
                    .hidden()
            }
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Color.blue
                        .opacity(0.5)
                        .frame(height: refreshOffset)
                    VStack {
                        ForEach(0...4, id: \.self) { _ in
                            Color.pink
                                .frame(height: 60)
                        }
                    }
                    Text("Content offset: \(contentOffset)")
                }
                .offset(y: min(contentOffset, 0))
                ScrollView {
                    Color.clear
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetPreferenceTypes.Key.self,
                                        value: [
                                            .init(type: .scrollable, offset: proxy.frame(in: .global).minY)
                                        ]
                                    )
                            }
                        )
                }
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceTypes.Key.self) { values in
            guard
                let first = values.first(where: { $0.type == .static }),
                let last = values.last(where: { $0.type == .scrollable })
            else {
                contentOffset = 0
                return
            }
            contentOffset = last.offset - first.offset
            
            if contentOffset > 80 {
                isRefreshing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isRefreshing = false
                    }
                }
            }
        }
    }
}

struct ScrollOffsetPreferenceTypes {
    
    struct Data: Equatable {
        var type: ViewType
        var offset: CGFloat
    }
    
    enum ViewType {
        case `static`
        case scrollable
    }
    
    struct Key: PreferenceKey {
        static var defaultValue: [Data] = []
        
        static func reduce(value: inout [Data], nextValue: () -> [Data]) {
            value.append(contentsOf: nextValue())
        }
    }
}

struct RefreshableScrollView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableScrollView()
    }
}
