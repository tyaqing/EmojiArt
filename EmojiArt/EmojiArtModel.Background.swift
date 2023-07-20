import Foundation

extension EmojiArtModel {
	enum Background: Equatable, Codable {
		case blank
		// URL可以是本地资源也可以是远程资源
		case url(URL)
		case imageData(Data)

		var url: URL? {
			switch self {
			case .url(let url):
				return url
			default:
				return nil
			}
		}

		var imageData: Data? {
			switch self {
			case .imageData(let data):
				return data
			default:
				return nil
			}
		}
	}
}
