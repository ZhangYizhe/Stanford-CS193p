//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by 张艺哲 on 2021/1/8.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document : EmojiArtDocument
    
    @State private var choosenPalette : String = ""
    
    init(document: EmojiArtDocument) {
        self.document = document
        _choosenPalette = State(wrappedValue: document.defaultPalette)
    }
    
    var body: some View {
        VStack{
            HStack {
                PaletteChooser(document: document, choosenPalette: $choosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(choosenPalette.map{ String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: defaultEmojiSize))
                                .onDrag{NSItemProvider(object: emoji as NSString)}
                        }
                    }
                }
                .layoutPriority(1)
            }
            GeometryReader { geometry in
                ZStack {
                    Rectangle().foregroundColor(.white).overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(tempSelectEmojiArr.count > 0 ? noGesturePanOffset : panOffset)
                    )
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large)
                            .spinning()
                    } else {
                        ForEach(document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * (self.isTempSlect(for: emoji) ? (zoomScale * gestureZoomScale) : zoomScale))
                                .position(postion(for: emoji, in: geometry.size))
                                .gesture(self.emojiTapGesture(for: emoji))
                                .selectView(
                                    isSelect: self.isTempSlect(for: emoji),
                                    size: emoji.fontSize * (self.isTempSlect(for: emoji) ? (zoomScale * gestureZoomScale) : zoomScale),
                                    position: postion(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(self.doubleTapToZoom(in: geometry.size))
                .gesture(self.backgroundTapGesture())
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage) { image in
                    self.zoomToFit(image, to: geometry.size)
                }
                .onDrop(of: [.image, .text], isTargeted: nil) { (providers, location) -> Bool in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .overlay(
                    GeometryReader { geometry in
                        ZStack {
                            Rectangle()
                                .cornerRadius(50)
                                .foregroundColor(.white)
                                .shadow(color: .gray, radius: 3, x: 0.0, y: 0.0)
                            Button("Delete") {
                                self.deleteAllSelectEmojis()
                            }
                            .foregroundColor(.blue)
                            .font(Font.system(size: 20))
                        }
                        .frame(width: 130, height: 50)
                        .position(x: geometry.size.width / 2, y: 45)
                        .opacity(tempSelectEmojiArr.count > 0 ? 1 : 0)
                        .animation(Animation.easeIn(duration: 0.1))
                    }
                )
            }
        }
    }
    
    var isLoading : Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    // MARK: - Zoom Gesture
    @State private var steadyZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale : CGFloat {
        if tempSelectEmojiArr.count > 0 {
            return steadyZoomScale
        } else {
            return steadyZoomScale * gestureZoomScale
        }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale, body: { (latestGestureScale, gestureZoomScale, transcation) in
                gestureZoomScale = latestGestureScale
            })
            .onEnded { finalGestureScale in
                if tempSelectEmojiArr.count > 0 {
                    for emojiId in tempSelectEmojiArr {
                        if let emoji = document.emojis.filter({ emoji in
                            emoji.id == emojiId
                        }).first {
                            document.scaleEmoji(emoji, by: finalGestureScale)
                        }
                    }
                } else {
                    self.steadyZoomScale *= finalGestureScale
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, to: size)
                }
            }
    }
    
    // MARK: - Emoji operation
    @State private var tempSelectEmojiArr : Set<Int> = []
    
    private func isTempSlect(for emoji: EmojiArt.Emoji) -> Bool {
        tempSelectEmojiArr.contains(emoji.id)
    }
    
    private func emojiTapGesture(for emoji: EmojiArt.Emoji) -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                if self.tempSelectEmojiArr.contains(emoji.id) {
                    self.tempSelectEmojiArr.remove(emoji.id)
                } else {
                    self.tempSelectEmojiArr.insert(emoji.id)
                }
            }
    }
    
    private func backgroundTapGesture() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                tempSelectEmojiArr.removeAll()
            }
    }
    
    private func deleteAllSelectEmojis() {
        for emojiId in tempSelectEmojiArr {
            if let emoji = document.emojis.filter({ emoji in
                emoji.id == emojiId
            }).first {
                document.deleteEmoji(emoji)
            }
        }
        
        tempSelectEmojiArr.removeAll()
    }
    
    // MARK: - Global Pan Offset
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset : CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private var noGesturePanOffset : CGSize {
        (steadyStatePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { (latestDragGestureValue, gesturePanOffset, transcation) in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                if tempSelectEmojiArr.count > 0 {
                    for emojiId in tempSelectEmojiArr {
                        if let emoji = document.emojis.filter({ emoji in
                            emoji.id == emojiId
                        }).first {
                            document.moveEmoji(emoji, by: finalDragGestureValue.translation / zoomScale)
                        }
                    }
                } else {
                    steadyStatePanOffset = steadyStatePanOffset + finalDragGestureValue.translation / zoomScale
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, to size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyZoomScale = min(hZoom, vZoom)
            self.steadyStatePanOffset = .zero
        }
    }
    
    private func postion(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2)
        
        if tempSelectEmojiArr.count > 0 {
            if isTempSlect(for: emoji) {
                location = CGPoint(x: location.x + self.panOffset.width, y: location.y + self.panOffset.height)
            } else {
                location = CGPoint(x: location.x + noGesturePanOffset.width, y: location.y + noGesturePanOffset.height)
            }
        } else {
            location = CGPoint(x: location.x + self.panOffset.width, y: location.y + self.panOffset.height)
        }
        return location
        
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self, using: { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            })
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
