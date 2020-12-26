//
//  Cardify.swift
//  Memorize
//
//  Created by 张艺哲 on 2020/12/26.
//

import SwiftUI

struct Cardify: ViewModifier {
    
    var isFaceUp : Bool
    
    func body(content: Content) -> some View {
        ZStack {
            if isFaceUp {
                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
                content
            } else {
                RoundedRectangle(cornerRadius: cornerRadius).fill()
            }
        }
    }
    
    private let cornerRadius : CGFloat = 10.0
    private let edgeLineWidth: CGFloat = 3.0
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
       return self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
