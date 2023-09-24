import SwiftUI

struct BarView<Item, Content: View>: View {
	let type: Item
	let selected: Bool
	let onTap: (BarSize) -> Void
	let content: Content
	@State private var barSize: BarSize = .zero {
		didSet {
			if selected {
				self.onTap(self.barSize)
			}
		}
	}
	
	init(
		type: Item,
		selected: Bool,
		onTap: @escaping (BarSize) -> Void,
		@ViewBuilder content: (Item, Bool) -> Content
	) {
		self.type = type
		self.selected = selected
		self.onTap = onTap
		self.content = content(type, selected)
	}
	
	var body: some View {
		Button {
			withAnimation {
				self.onTap(self.barSize)
			}
		} label: {
			self.content
				.background(BarGeometryReader())
				.onPreferenceChange(SizeKey.self) {
					self.barSize = $0
				}
		}
		.onChange(of: self.selected) { newValue in
			if newValue {
				withAnimation {
					self.onTap(self.barSize)
				}
			}
		}
	}
}
