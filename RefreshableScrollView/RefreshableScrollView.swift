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
            Color.clear
                .hidden()
                .scrollOffsetPreference(.static)
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
                .scrollOffsetPreference(.scrollable)
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

struct RefreshableScrollView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableScrollView()
    }
}
