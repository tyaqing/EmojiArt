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
				Color.white.overlay {
					OptionalImage(uiImage: document.backgroundImage)
						.scaleEffect(zoomScale)
						.position(convertFromEmojiCoordinates((0, 0), in: geometry))
				}
				.gesture(doubleTapToZoom(in: geometry.size))
				if document.backgroundImageFetchStatus == .fetching {
					ProgressView().scaleEffect(2)
				} else {
					ForEach(document.emojis) { emoji in
						Text(emoji.text)
							.font(.system(size: fontSize(for: emoji)))
							.scaleEffect(zoomScale)
							.position(position(for: emoji, in: geometry))
					}
				}
			}
			.clipped() // 不让空间溢出本窗口范围
			.onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
				drop(providers: providers, at: location, in: geometry)
			}
			.gesture(panGesture().simultaneously(with: zoomGesture()))
		}
	}

	private func drop(
		providers: [NSItemProvider],
		at location: CGPoint,
		in geometry: GeometryProxy
	) -> Bool {
		var found = providers.loadFirstObject(ofType: URL.self) { url in
			document.setBackground(.url(url.absoluteURL))
		}
		if !found {
			found = providers.loadFirstObject(ofType: UIImage.self) { image in
				if let data = image.jpegData(compressionQuality: 1.0) {
					document.setBackground(.imageData(data))
				}
			}
		}
		if !found {
			found = providers.loadObjects(ofType: String.self) { string in
				if let emoji = string.first, emoji.isEmoji {
					document.addEmoji(
						String(emoji),
						at: convertToEmojiCoordinates(location, in: geometry),
						size: defaultEmojiFontSize / zoomScale
					)
				}
			}
		}
		return found
	}

	private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
		CGFloat(emoji.size)
	}

	@State private var steadyStatePanOffset: CGSize = .zero
	@GestureState private var gesturePanOffset: CGSize = .zero

	private var panOffset: CGSize {
		CGSize(
			width: (steadyStatePanOffset.width + gesturePanOffset.width) * gestureZoomScale,
			height: (steadyStatePanOffset.height + gesturePanOffset.height) * gestureZoomScale
		)
	}

	private func panGesture() -> some Gesture {
		DragGesture()
			.updating($gesturePanOffset) { latestGestureValue, gesturePanOffset, _ in
				let translation = latestGestureValue.translation
				let scaledTranslation = CGSize(
					width: translation.width / zoomScale,
					height: translation.height / zoomScale
				)
				gesturePanOffset = scaledTranslation
			}
			.onEnded { finalDragGestureValue in
				let finalTranslation = finalDragGestureValue.translation
				let scaledFinalTranslation = CGSize(width: finalTranslation.width / zoomScale, height: finalTranslation.height / zoomScale)
				steadyStatePanOffset = CGSize(
					width: steadyStatePanOffset.width + (scaledFinalTranslation.width / zoomScale),
					height: steadyStatePanOffset.height + (scaledFinalTranslation.height / zoomScale)
				)
			}
	}

	@State private var steadyStateZoomScale: CGFloat = 1
	@GestureState private var gestureZoomScale: CGFloat = 1

	private var zoomScale: CGFloat {
		steadyStateZoomScale * gestureZoomScale
	}

	private func zoomGesture() -> some Gesture {
		MagnificationGesture()
			.updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
				gestureZoomScale = latestGestureScale
			}
			.onEnded { gestureScale in
				steadyStateZoomScale *= gestureScale
			}
	}

	private func doubleTapToZoom(in size: CGSize) -> some Gesture {
		TapGesture(count: 2)
			.onEnded {
				withAnimation {
					zoomToFit(document.backgroundImage, in: size)
				}
			}
	}

	private func zoomToFit(_ image: UIImage?, in size: CGSize) {
		if let image = image, image.size.width > 0, image.size.height > 0,
		   size.width > 0, size.height > 0
		{
			let hZoom = size.width / image.size.width
			let vZoom = size.height / image.size.height
			steadyStatePanOffset = .zero
			steadyStateZoomScale = min(hZoom, vZoom)
		}
	}

	private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
		return convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
	}

	private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (
		x: Int, y: Int
	) {
		let center = geometry.frame(in: .local).center
		let location = CGPoint(
			x: (location.x - panOffset.width - center.x) / zoomScale,
			y: (location.y - panOffset.height - center.y) / zoomScale
		)
		return (Int(location.x), Int(location.y))
	}

	private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy)
		-> CGPoint
	{
		let center = geometry.frame(in: .local).center
		return CGPoint(
			x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
			y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
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

struct OptionalImage: View {
	var uiImage: UIImage?
	var body: some View {
		if uiImage != nil {
			Image(uiImage: uiImage!)
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
