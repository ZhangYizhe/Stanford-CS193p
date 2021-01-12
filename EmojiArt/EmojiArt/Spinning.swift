//
//  Spinning.swift
//  EmojiArt
//
//  Created by 张艺哲 on 2021/1/11.
//

import SwiftUI

struct Spinning : ViewModifier {
    
    @State var isVisiable : Bool = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisiable ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear { self.isVisiable = true }
    }
}

extension View {
    func spinning() -> some View {
        self.modifier(Spinning())
    }
}
