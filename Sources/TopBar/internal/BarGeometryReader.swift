import SwiftUI

struct BarGeometryReader: View {
	var body: some View {
		GeometryReader { geometry in
			Color.clear
				.preference(
					key: SizeKey.self,
					value: BarSize(
						width: geometry.size.width,
						originX: geometry.frame(in: .named(CoordinateSpace.topBar)).origin.x
					)
				)
		}
	}
}
