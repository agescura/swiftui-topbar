import SwiftUI

extension View {
	func isScroll(enabled: Bool) -> some View {
		self.modifier(ScrollModifier(enabled: enabled))
	}
}
