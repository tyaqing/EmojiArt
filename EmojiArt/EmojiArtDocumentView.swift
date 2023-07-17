//
//  ContentView.swift
//  EmojiArt
//
//  Created by yakir on 2023/7/16.
//

import CoreData
import SwiftUI

struct EmojiArtDocumentView: View {
	@ObservedObject var document: EmojiArtDocument

	let defaultEmojiFontSize: CGFloat = 40
	var body: some View {
		VStack(spacing: 0) {
			documentBody
			palette
		}
	}

	var documentBody: some View {
		ZStack {
			Color.yellow
			ForEach(document.emojis) { emoji in
				Text(emoji.text)
			}
		}
	}

	var palette: some View {
		ScrollingEmojiView(emojis: testemojis)
			.font(.system(size: defaultEmojiFontSize))
	}

	let testemojis = "😀😂😍👍🎉🌞🌈🍔🍦⚽️🚗📱🎸✈️🏠🚀🐼🦄"
}

struct ScrollingEmojiView: View {
	let emojis: String
	var body: some View {
		ScrollView(.horizontal) {
			HStack {
				ForEach(emojis.map { String($0) }, id: \.self) { emoji in
					Text(emoji)
				}
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		let document = EmojiArtDocument()
		EmojiArtDocumentView(document: document)
	}
}
