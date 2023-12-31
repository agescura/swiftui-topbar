import SwiftUI

struct PagerGeometryReader: View {
	var body: some View {
		GeometryReader {
			Color.clear.preference(
				key: PagerOffsetKey.self,
				value: -$0.frame(in: .named(CoordinateSpace.page)).origin.x
			)
		}
	}
}

struct PagerOffsetKey: PreferenceKey {
	 typealias Value = CGFloat
	 static var defaultValue = CGFloat.zero
	 static func reduce(value: inout Value, nextValue: () -> Value) {
		  value += nextValue()
	 }
}
