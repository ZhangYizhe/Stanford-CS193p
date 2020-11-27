//
//  MemorizeApp.swift
//  Memorize
//
//  Created by 张艺哲 on 2020/11/25.
//

import SwiftUI

@main
struct MemorizeApp: App {

    var body: some Scene {
        let game = EmojiMemoryGame()
        
        WindowGroup {
            EmojiMemoryGameView(viewModel: game)
        }
    }
}
