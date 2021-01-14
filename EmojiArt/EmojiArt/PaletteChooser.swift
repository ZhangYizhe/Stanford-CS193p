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
    @State private var showPaletteEditor = false
    
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
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor, content: {
                    PaletteEditor(choosenPalette: $choosenPalette, isShowing: $showPaletteEditor)
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                })
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor : View {
    @EnvironmentObject var document : EmojiArtDocument
    
    @Binding var choosenPalette : String
    @Binding var isShowing : Bool
    @State private var paletteName : String = ""
    @State private var emojisToAdd : String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: {
                        Text("Done")
                    }).padding()
                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(choosenPalette, to: paletteName)
                        }
                    })
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            self.choosenPalette = self.document.addEmoji(emojisToAdd, toPalette: self.choosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")) {
                    Grid(choosenPalette.map{ String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.choosenPalette = self.document.removeEmoji(emoji, fromPalette: self.choosenPalette)
                            }
                    }.frame(height: self.height)
                }
            }
        }
        .onAppear { paletteName = self.document.paletteNames[choosenPalette] ?? ""}
    }
    
    private var height : CGFloat {
        CGFloat((self.paletteName.count - 1) / 6 ) * 70 + 70
    }
    
    let fontSize : CGFloat = 40
    
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), choosenPalette: Binding.constant(""))
    }
}
