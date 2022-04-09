import SwiftUI

public typealias RefreshAction = (@escaping () -> Void) -> Void

public struct RefreshableScrollView<Content, RefreshContent>: View where Content: View, RefreshContent: View {
    @State private var refreshContentSize: CGSize = .zero
    @State private var scrollViewOffset: CGFloat = .zero
    @State private var state: RefreshingState = .initial
    
    /// Used to make the scroll animation smoother when realeased for loading
    private let thresholdConstant: CGFloat = 30
    
    private var threshold: CGFloat {
        max(refreshContentSize.height + thresholdConstant, refreshThreshold)
    }
    
    private var visibleRefreshOffset: CGFloat {
        guard state != .initial else { return .zero }
        return max(
            0,
            min(
                refreshContentSize.height,
                refreshContentSize.height - refreshContentSize.height * scrollViewOffset / (refreshContentSize.height + thresholdConstant)
            )
        )
    }
    
    var content: () -> Content
    var refreshContent: () -> RefreshContent
    var onRefresh: RefreshAction
    var refreshThreshold: CGFloat
    
    public init(
        onRefresh: @escaping RefreshAction,
        refreshThreshold: CGFloat = 70,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder refreshContent: @escaping () -> RefreshContent
    ) {
        self.content = content
        self.refreshContent = refreshContent
        self.onRefresh = onRefresh
        self.refreshThreshold = refreshThreshold
    }
    
    public var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                Color.clear
                    .hidden()
                    .scrollOffsetPreference(.scrollable)
                ChildSizeReader(contentSize: $refreshContentSize) {
                    refreshContent()
                        .offset(y: -scrollViewOffset)
                }
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: visibleRefreshOffset)
                    content()
                }
            }
        }
        .scrollOffsetPreference(.static)
        .onScrollOffsetChange { offset in
            DispatchQueue.main.async {
                scrollViewOffset = offset
                if offset > threshold && state == .initial {
                    state = .ready
                } else if offset < threshold && state == .ready {
                    state = .loading
                    onRefresh {
                        withAnimation {
                            state = .initial
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct RefreshableScrollViewPreviewContent: View {
    @State var itemsCount: Int = 1
    
    var body: some View{
        RefreshableScrollView { finished in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                finished()
            }
        } content: {
            VStack {
                ForEach(0...itemsCount, id: \.self) { _ in
                    Color.pink
                        .frame(height: 60)
                }
            }
        } refreshContent: {
            Color.blue
                .frame(height: 30)
        }
    }
}

struct RefreshableScrollView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableScrollViewPreviewContent()
    }
}
