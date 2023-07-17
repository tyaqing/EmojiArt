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
		GeometryReader { geometry in
			ZStack {
				Color.yellow
				ForEach(document.emojis) { emoji in
					Text(emoji.text)
						.font(.system(size: fontSize(for: emoji)))
						.position(position(for: emoji, in: geometry))
				}
			}
			.onDrop(of: [.plainText], isTargeted: nil){ providers,location in
				drop(providers: providers, at: location, in: geometry)
			}
		}
	}
	
	private func drop(
		providers:[NSItemProvider],
		at location:CGPoint,
		in geometry :GeometryProxy
	)->Bool{
		return providers.loadObjects(ofType: String.self){ string in
			if let emoji = string.first,emoji.isEmoji {
				document.addEmoji(
					String(emoji),
					at: convertToEmojiCoordinates(location,in: geometry),
					size: defaultEmojiFontSize
				)
			}
			
		}
	}


	private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
		CGFloat(emoji.size)
	}

	private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
		return convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
	}

	private func convertToEmojiCoordinates(
		_ location:CGPoint,
		in geometry:GeometryProxy
	)->(x:Int,y:Int){
		let center = geometry.frame(in: .local).center
		let location = CGPoint(
			x: location.x - center.x,
			y: location.y - center.y
		)
		return (Int(location.x),Int(location.y))
	}
	
	private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
		let center = geometry.frame(in: .local).center
		return CGPoint(
			x: center.x + CGFloat(location.x),
			y: center.y + CGFloat(location.y)
		)
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
						.onDrag {
							// 这里表示在拖拽到时候给到的异步信息
							NSItemProvider(object: emoji as NSString)
						}
				}
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		let document = EmojiArtDocument()
		EmojiArtDocumentView(document: document)
			.previewInterfaceOrientation(.landscapeRight)
	}
}
