//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by 张艺哲 on 2021/1/12.
//

import SwiftUI

struct PaletteChooser: View {
    
    @ObservedObject var document : EmojiArtDocument
    
    @Binding var choosenPalette : String
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    choosenPalette = document.palette(after: self.choosenPalette)
                },
                onDecrement: {
                    choosenPalette = document.palette(before: self.choosenPalette)
                },
                label: {
                    EmptyView()
                })
            Text(self.document.paletteNames[choosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), choosenPalette: Binding.constant(""))
    }
}
