//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by 张艺哲 on 2021/1/8.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document : EmojiArtDocument
    
    var body: some View {
        VStack{
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map{ String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: defaultEmojiSize))
                    }
                }
            }.padding(.horizontal)
            Rectangle().foregroundColor(.yellow)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
