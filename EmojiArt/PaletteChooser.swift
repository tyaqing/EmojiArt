import SwiftUI

struct PaletteChooser: View {
	var emojiFontSize: CGFloat = 40
	var emojiFont: Font {
		Font.system(size: emojiFontSize)
	}

	@EnvironmentObject var store: PaletteStore

	@State private var chosePaletteIndex = 0

	var body: some View {
		HStack {
			paletteControlButton
			body(for: store.palettes[chosePaletteIndex])
		}
		.clipped()
	}

	var paletteControlButton: some View {
		Button {
			withAnimation {
				chosePaletteIndex = (chosePaletteIndex + 1) % store.palettes.count
			}
		} label: {
			Image(systemName: "paintpalette")
		}
		.font(emojiFont)
		.contextMenu {
			contextMenu
		}
	}

	@ViewBuilder
	var contextMenu: some View {
		AnimatedActionButton(title: "Edit", systemImage: "pencil") {
			editing = true
		}
		AnimatedActionButton(title: "New", systemImage: "plus") {
			store.insertPalette(named: "New", emojis: "", at: chosePaletteIndex)
		}
		AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
			chosePaletteIndex = store.removePalette(at: chosePaletteIndex)
		}
		gotoMenu
	}

	var gotoMenu: some View {
		Menu {
			ForEach(store.palettes) { palette in
				AnimatedActionButton(title: palette.name) {
					if let index = store.palettes.index(matching: palette) {
						chosePaletteIndex = index
					}
				}
			}
		} label: {
			Label("Go To", systemImage: "text.insert")
		}
		.font(emojiFont)
	}

	func body(for palette: Palette) -> some View {
		HStack {
			Text("\(palette.name)\(palette.id)")
			ScrollingEmojiView(emojis: palette.emojis)
				.font(emojiFont)
		}
		.id(palette.id)
		.transition(rollTransition)
		.popover(isPresented: $editing) {
			PaletteEditor(palette: $store.palettes[chosePaletteIndex])
		}
	}

	@State private var editing = false
	var rollTransition: AnyTransition {
		AnyTransition.asymmetric(
			insertion: .offset(x: 0, y: emojiFontSize),
			removal: .offset(x: 0, y: -emojiFontSize)
		)
	}
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

struct PaletteChooser_Previews: PreviewProvider {
	static var previews: some View {
		PaletteChooser()
	}
}
