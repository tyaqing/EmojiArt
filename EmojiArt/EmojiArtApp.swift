//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by yakir on 2023/7/16.
//

import SwiftUI

@main
struct EmojiArtApp: App {
	var body: some Scene {
		@StateObject var document = EmojiArtDocument()
		@StateObject var paletteStore = PaletteStore(name: "Default")
		WindowGroup {
			EmojiArtDocumentView(document: document)
				.environmentObject(paletteStore)
		}
	}
}
