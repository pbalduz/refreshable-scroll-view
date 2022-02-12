import SwiftUI

struct RefreshableScrollView<Content: View, RefreshContent: View>: View {
    @State private var isRefreshing: Bool = false
    @State private var refreshContentSize: CGSize = .zero
    @State private var scrollViewOffset: CGFloat = .zero
    
    private var threshold: CGFloat {
        max(refreshContentSize.height, refreshThreshold)
    }
    
    private var visibleRefreshOffset: CGFloat {
        guard isRefreshing else { return .zero }
        return max(
            0,
            refreshContentSize.height - refreshContentSize.height * scrollViewOffset / (refreshContentSize.height + 30)
        )
    }
    
    @ViewBuilder var content: () -> Content
    @ViewBuilder var refreshContent: () -> RefreshContent
    var refreshThreshold: CGFloat
    
    init(
        refreshThreshold: CGFloat = 100,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder refreshContent: @escaping () -> RefreshContent
    ) {
        self.content = content
        self.refreshContent = refreshContent
        self.refreshThreshold = refreshThreshold
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ChildSizeReader(contentSize: $refreshContentSize) {
                refreshContent()
            }
            Color.clear
                .hidden()
                .scrollOffsetPreference(.static)
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: visibleRefreshOffset)
                    content()
                }
                .scrollOffsetPreference(.scrollable)
            }
        }
        .onScrollOffsetChange { offset in
            scrollViewOffset = offset
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

struct RefreshableScrollView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableScrollView {
            VStack {
                ForEach(0...2, id: \.self) { _ in
                    Color.pink
                        .frame(height: 60)
                }
            }
        } refreshContent: {
            Color.blue
                .frame(height: 60)
        }
    }
}
