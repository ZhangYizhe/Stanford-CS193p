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
//                    self.zoomToFit(image, to: geometry.size)
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
                .navigationBarItems(leading: pickImage,trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != document.backgroundURL {
                        self.confirmBackgroundClipPast = true
                    } else {
                        self.explainBackgroundClipPast = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                        .alert(isPresented: $explainBackgroundClipPast) {
                            return Alert(
                                title: Text("Past background"),
                                message: Text("Copy the URL of an image to the clip board and touch this button to make it the background of your document"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                }))
            }
            .zIndex(-1)
        }
        .alert(isPresented: $confirmBackgroundClipPast) {
            return Alert(
                title: Text("Past background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?"),
                primaryButton: .default(Text("OK")) {
                    self.document.backgroundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    @State private var showPickImageView = false
    @State private var imagePickerSourceType = UIImagePickerController.SourceType.photoLibrary
    private var pickImage: some View {
        HStack {
            Image(systemName: "photo").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
                imagePickerSourceType = .photoLibrary
                self.showPickImageView = true
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Image(systemName: "camera").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
                    imagePickerSourceType = .camera
                    self.showPickImageView = true
                }
            }
        }
        .sheet(isPresented: $showPickImageView) {
            ImagePicker(sourceType: imagePickerSourceType) { image in
                if image != nil {
                    DispatchQueue.main.async {
                        self.document.backgroundURL = image!.storeInFilesystem()
                    }
                }
                self.showPickImageView = false
            }
        }
    }
    
    @State private var explainBackgroundClipPast = false
    @State private var confirmBackgroundClipPast = false
    
    var isLoading : Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    // MARK: - Zoom Gesture
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale : CGFloat {
        if tempSelectEmojiArr.count > 0 {
            return document.steadyStateZoomScale
        } else {
            return document.steadyStateZoomScale * gestureZoomScale
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
                    self.document.steadyStateZoomScale *= finalGestureScale
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
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset : CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private var noGesturePanOffset : CGSize {
        (document.steadyStatePanOffset) * zoomScale
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
                    document.steadyStatePanOffset = document.steadyStatePanOffset + finalDragGestureValue.translation / zoomScale
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, to size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStateZoomScale = min(hZoom, vZoom)
            self.document.steadyStatePanOffset = .zero
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
