import SwiftUI

struct RefreshableScrollView: View {
    @State private var isRefreshing: Bool = false
    @State private var scrollViewOffset: CGFloat = .zero
    
    private var refreshContentHeight: CGFloat = 60
    private var threshold: CGFloat = 100
    
    private var visibleRefreshOffset: CGFloat {
        guard isRefreshing else { return .zero }
        return max(
            0,
            refreshContentHeight - refreshContentHeight * scrollViewOffset / (refreshContentHeight + 30)
        )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.orange
                .frame(height: refreshContentHeight)
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
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: visibleRefreshOffset)
                    VStack {
                        ForEach(0...4, id: \.self) { _ in
                            Color.pink
                                .frame(height: 60)
                        }
                    }
                    Text("Content offset: \(scrollViewOffset)")
                }
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
        .onPreferenceChange(ScrollOffsetPreferenceTypes.Key.self) { values in
            guard
                let first = values.first(where: { $0.type == .static }),
                let last = values.last(where: { $0.type == .scrollable })
            else {
                scrollViewOffset = 0
                return
            }
            scrollViewOffset = last.offset - first.offset
            
            if scrollViewOffset > threshold {
                guard !isRefreshing else { return }
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
