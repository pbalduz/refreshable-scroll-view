import SwiftUI

struct RefreshableScrollView<Content: View, RefreshContent: View>: View {
    @State private var isRefreshEnabled: Bool = true
    @State private var refreshContentSize: CGSize = .zero
    @State private var scrollViewOffset: CGFloat = .zero
    
    private var contentOffset: CGFloat {
        scrollViewOffset + visibleRefreshOffset
    }
    
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
    @Binding var isRefreshing: Bool
    @ViewBuilder var refreshContent: () -> RefreshContent
    var refreshThreshold: CGFloat
    
    init(
        isRefreshing: Binding<Bool>,
        refreshThreshold: CGFloat = 100,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder refreshContent: @escaping () -> RefreshContent
    ) {
        self.content = content
        self._isRefreshing = isRefreshing
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
            if contentOffset == 0 { isRefreshEnabled = true }
            if scrollViewOffset > threshold {
                guard !isRefreshing, isRefreshEnabled else { return }
                isRefreshing = true
                isRefreshEnabled = false
            }
        }
    }
}

struct RefreshableScrollViewPreviewContent: View {
    @State var isRefreshing: Bool = false
    @State var itemsCount: Int = 1
    
    var body: some View{
        RefreshableScrollView(isRefreshing: $isRefreshing) {
            VStack {
                ForEach(0...itemsCount, id: \.self) { _ in
                    Color.pink
                        .frame(height: 60)
                }
            }
        } refreshContent: {
            Color.blue
                .frame(height: 60)
        }
        .onChange(of: isRefreshing) { newValue in
            guard newValue else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.itemsCount += 1
                    self.isRefreshing = false
                }
            }
        }
    }
}

struct RefreshableScrollView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableScrollViewPreviewContent()
    }
}
