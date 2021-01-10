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
                            .onDrag{NSItemProvider(object: emoji as NSString)}
                    }
                }
            }.padding(.horizontal)
            GeometryReader { geometry in
                ZStack {
                    Rectangle().foregroundColor(.white).overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(panOffset)
                    )
                    .gesture(self.doubleTapToZoom(in: geometry.size))
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * zoomScale)
                            .position(postion(for: emoji, in: geometry.size))
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: [.image, .text], isTargeted: nil) { (providers, location) -> Bool in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return self.drop(providers: providers, at: location)
                }
            }
        }
    }
    
    @State private var steadyZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale : CGFloat {
        steadyZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale, body: { (latestGestureScale, gestureZoomScale, transcation) in
                gestureZoomScale = latestGestureScale
            })
            .onEnded { finalGestureScale in
                self.steadyZoomScale *= finalGestureScale
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
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset : CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { (latestDragGestureValue, gesturePanOffset, transcation) in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + finalDragGestureValue.translation / zoomScale
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
        location = CGPoint(x: location.x + self.panOffset.width, y: location.y + self.panOffset.height)
        return location
        
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.setBackgroundURL(url)
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
