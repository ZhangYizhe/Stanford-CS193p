//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by 张艺哲 on 2021/1/9.
//

import Foundation
import SwiftUI

struct EmojiArt: Codable {
    var backgroundURL : URL?
    var emojis = [Emoji]()
    
    struct Emoji : Identifiable, Codable {
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var size: Int
        var id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt
        } else {
            return nil
        }
    }
    
    init() {}
    
    private var uniqueEmojiID = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiID))
    }
}

extension EmojiArt.Emoji {
    var fontSize : CGFloat { CGFloat(self.size) }
    var location : CGPoint { CGPoint(x: CGFloat(self.x), y: CGFloat(self.y)) }
}
