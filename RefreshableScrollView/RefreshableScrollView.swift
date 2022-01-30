import SwiftUI

struct RefreshableScrollView: View {
    @State private var contentOffset: CGFloat = .zero
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { staticViewProxy in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceTypes.Key.self,
                        value: [.init(type: .static, offset: staticViewProxy.frame(in: .global).minY)]
                    )
                    .hidden()
            }
            ScrollView {
                GeometryReader { contentProxy in
                    VStack {
                        ForEach(0...4, id: \.self) { _ in
                            Color.pink
                                .frame(height: 60)
                        }
                        Text("Content offset: \(contentOffset)")
                    }
                    .preference(
                        key: ScrollOffsetPreferenceTypes.Key.self,
                        value: [
                            .init(
                                type: .scrollable,
                                offset: contentProxy.frame(in: .global).minY
                            )
                        ]
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
