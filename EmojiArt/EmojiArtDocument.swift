
import SwiftUI

class EmojiArtDocument: ObservableObject {
	@Published private(set) var emojiArt: EmojiArtModel {
		didSet {
			if emojiArt.background != oldValue.background {
				fetchBackgroundImageDataIfNecessary()
			}
		}
	}

	init() {
		emojiArt = EmojiArtModel()
		emojiArt.addEmoji("🍺", at: (80, 80), size: 50)
		emojiArt.addEmoji("🤣", at: (-20, -120), size: 50)
	}

	var emojis: [EmojiArtModel.Emoji] {
		emojiArt.emojis
	}

	var background: EmojiArtModel.Background {
		emojiArt.background
	}

	@Published var backgroundImage: UIImage?
	@Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle

	enum BackgroundImageFetchStatus {
		case idle
		case fetching
	}

	private func fetchBackgroundImageDataIfNecessary() {
		backgroundImage = nil
		switch emojiArt.background {
		case .url(let url):
			backgroundImageFetchStatus = .fetching
			DispatchQueue.global(qos: .userInitiated).async {
				let imageData = try? Data(contentsOf: url)
				DispatchQueue.main.async { [weak self] in
					// 当下载完成时,用户已经改变了图片,就不再设置背景
					if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
						self?.backgroundImageFetchStatus = .idle
						if imageData != nil {
							self?.backgroundImage = UIImage(data: imageData!)
						}
					}
				}
			}
		case .imageData(let data):
			backgroundImage = UIImage(data: data)
		case .blank:
			break
		}
	}

	// MARK: - Intent(s)

	func setBackground(_ background: EmojiArtModel.Background) {
		emojiArt.background = background
		print("background:\(background)")
	}

	func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
		emojiArt.addEmoji(emoji, at: location, size: Int(size))
	}

	func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
		if let index = emojiArt.emojis.index(matching: emoji) {
			emojiArt.emojis[index].x += Int(offset.width)
			emojiArt.emojis[index].y += Int(offset.height)
		}
	}

	func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
		if let index = emojiArt.emojis.index(matching: emoji) {
			emojiArt.emojis[index].size = Int(
				(CGFloat(emojiArt.emojis[index].size) * scale)
					.rounded(.toNearestOrAwayFromZero)
			)
		}
	}
}
