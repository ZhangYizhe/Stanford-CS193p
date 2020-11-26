//
//  ContentView.swift
//  Memorize
//
//  Created by 张艺哲 on 2020/11/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    var viewModel : EmojiMemoryGame

    var body: some View {
        HStack() {
            ForEach(viewModel.cards, content: { card in
                CardView(card: card).onTapGesture {
                    viewModel.choose(card: card)
                }
            })
        }
            .foregroundColor(.orange)
            .padding()
            .font(Font.largeTitle)
    }
}

struct CardView: View {
    var card : MemoryGame<String>.Card
    
    var body: some View {
        ZStack {
            if card.isFaceUp {
                RoundedRectangle(cornerRadius: 10).fill(Color.white)
                RoundedRectangle(cornerRadius: 10).stroke()
                Text("👻")
            } else {
                RoundedRectangle(cornerRadius: 10).fill()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: EmojiMemoryGame())
    }
}
