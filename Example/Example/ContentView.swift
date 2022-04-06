//
//  ContentView.swift
//  Example
//
//  Created by Pablo Balduz on 16/2/22.
//

import SwiftUI
import RefreshableScrollView

struct ContentView: View {
    @State var isRefreshing: Bool = false
    
    @State var colors: [Color] = [.random, .random, .random]
    
    var body: some View{
        RefreshableScrollView { finished in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                randomColors()
                finished()
            }
        } content: {
            VStack {
                ForEach(colors, id: \.self) { color in
                    color
                        .frame(height: 60)
                }
            }
        } refreshContent: {
            Text("Pull to refresh")
                .font(.body)
                .padding(.vertical)
        }
    }
    
    private func randomColors() {
        colors.removeAll()
        for _ in 0...Int.random(in: 1...10) {
            colors.append(Color.random)
        }
    }
}

extension Double {
    static var random: CGFloat {
        Double(arc4random()) / Double(UInt32.max)
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random,
            green: .random,
            blue: .random
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
