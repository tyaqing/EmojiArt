
import SwiftUI

class EmojiArtDocument: ObservableObject {
	@Published private(set) var emojiArt: EmojiArtModel {
		didSet {
			scheduleAutoSave()
			if emojiArt.background != oldValue.background {
				fetchBackgroundImageDataIfNecessary()
			}
		}
	}

	private var autoSaveTime: Timer?

	private func scheduleAutoSave() {
		autoSaveTime?.invalidate()
		autoSaveTime = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
			self.autosave()
		}
	}

	private enum Autosave {
		static let filename = "Autosaved.emojiart"
		static var url: URL? {
			let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
			return documentDirectory?.appendingPathComponent(filename)
		}

		static let coalescingInterval = 5.0
	}

	private func autosave() {
		if let url = Autosave.url {
			save(to: url)
		}
	}

	private func save(to url: URL) {
		let thisFunction = "\(String(describing: self)).\(#function)"

		do {
			let data = try emojiArt.json()
			print("\(thisFunction) \(url): data=\(String(data: data, encoding: .utf8) ?? "nil")")
			try data.write(to: url)
			print("\(thisFunction) \(url): success!")
		} catch let encodingError where encodingError is EncodingError {
			print("\(thisFunction) \(url): encodingError:\(encodingError.localizedDescription)")
		} catch {
			print("\(thisFunction) \(url): \(error)")
		}
	}

	init() {
		if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
			emojiArt = autosavedEmojiArt
			fetchBackgroundImageDataIfNecessary()
		} else {
			emojiArt = EmojiArtModel()
		}

//		emojiArt.addEmoji("🍺", at: (80, 80), size: 50)
//		emojiArt.addEmoji("🤣", at: (-20, -120), size: 50)
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
