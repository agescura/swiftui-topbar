import SwiftUI

struct SizeKey: PreferenceKey {
	static var defaultValue: BarSize = .zero
	
	static func reduce(
		value: inout BarSize,
		nextValue: () -> BarSize
	) {
		value = nextValue()
	}
}
