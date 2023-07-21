import SwiftUI

struct PaletteEditor: View {
	@Binding var palette: Palette
	var body: some View {
		Form {
			Section(header: Text("Gaga")) {
				TextField("Palette Name", text: $palette.name)
			}
		}
		.frame(width: 300, height: 350)
	}
}

struct PaletteEditor_Previews: PreviewProvider {
	static var previews: some View {
		PaletteEditor(palette: .constant(PaletteStore(name: "Preview").palette(at: 4)))
			.previewLayout(.fixed(width: 300, height: 350))
	}
}
