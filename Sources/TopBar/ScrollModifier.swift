import SwiftUI

struct ScrollModifier: ViewModifier {
	let enabled: Bool
	
	func body(content: Content) -> some View {
		if enabled {
			ScrollView(
				.horizontal,
				showsIndicators: false
			) {
				content
					.background(ScrollGeometryReader())
			}
			.coordinateSpace(name: CoordinateSpace.scroll)
		} else {
			content
		}
	}
}
