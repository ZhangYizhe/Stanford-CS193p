//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by 张艺哲 on 2021/1/10.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage! )
            }
        }
    }
}
