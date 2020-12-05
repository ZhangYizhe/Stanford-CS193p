//
//  MemoryGame.swift
//  Memorize
//
//  Created by 张艺哲 on 2020/11/26.
//

// Model

import Foundation

struct MemoryGame<CardContent> {
    var cards : Array<Card>
    
    mutating func choose(card: Card) {
        let indexCard : Int = cards.firstIndex(matching: card)
        self.cards[indexCard].isFaceUp = !self.cards[indexCard].isFaceUp
    }
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()
        
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
    }
    
    struct Card : Identifiable {
        var isFaceUp: Bool = true
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
}
