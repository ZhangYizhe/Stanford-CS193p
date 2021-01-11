//
//  SelectView.swift
//  EmojiArt
//
//  Created by 张艺哲 on 2021/1/11.
//

import SwiftUI

struct SelectView: ViewModifier {
    
    var isSelect: Bool
    var size: CGFloat
    var position: CGPoint
    
    func body(content: Content) -> some View {
        ZStack {
            if isSelect {
                Rectangle()
                    .foregroundColor(.clear)
                    .border(Color.blue)
                    .frame(width: size + 5, height: size + 5, alignment: .center)
                    .position(position)
            }
            content
        }
    }
    
}

extension View {
    func selectView(isSelect: Bool, size: CGFloat, position: CGPoint) -> some View {
        return self.modifier(SelectView(isSelect: isSelect, size: size, position: position))
    }
}

//struct SelectView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectView()
//    }
//}
