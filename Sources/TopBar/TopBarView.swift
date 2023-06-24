import SwiftUI

enum CoordinateSpace {
	case topBar
}

public struct BarType: Identifiable, Equatable, Hashable {
	public let rawValue: String
	
	public init(_ text: String) {
		self.rawValue = text
	}
	
	public var id: String { self.rawValue }
}

public struct TopBarView: View {
	let bars: [BarType]
	@Binding var selected: BarType
	@State var barSize: BarSize = .zero
	
	public init(
		bars: [BarType],
		selected: Binding<BarType>
	) {
		self.bars = bars
		self._selected = selected
	}
	
	public var body: some View {
		VStack {
			HStack {
				Spacer()
				ForEach(self.bars) { type in
					BarView(
						type: type,
						selected: self.selected == type,
						onTap: { barSize in
							self.selected = type
							self.barSize = barSize
						}
					)
					Spacer()
				}
			}
			ZStack(alignment: .leading) {
				Divider()
				Capsule()
					.frame(height: 3)
					.frame(width: self.barSize.size.width)
					.offset(x: self.barSize.origin.x)
					.foregroundColor(.accentColor)
			}
		
		}
		.coordinateSpace(name: CoordinateSpace.topBar)
	}
}

struct SizeKey: PreferenceKey {
	static var defaultValue: BarSize = .zero
	
	static func reduce(
		value: inout BarSize,
		nextValue: () -> BarSize
	) {
		value = nextValue()
	}
}

struct BarGeometryReady: View {
	var body: some View {
		GeometryReader { geometry in
			Color.clear
				.preference(
					key: SizeKey.self,
					value: BarSize(
						size: geometry.size,
						origin: geometry.frame(in: .named(CoordinateSpace.topBar)).origin
					)
				)
		}
	}
}

struct BarView: View {
	let type: BarType
	let selected: Bool
	let onTap: (BarSize) -> Void
	@State private var barSize: BarSize = .zero {
		didSet {
			if selected {
				self.onTap(self.barSize)
			}
		}
	}
	
	var body: some View {
		Button {
			withAnimation {
				self.onTap(self.barSize)
			}
		} label: {
			Text(self.type.rawValue)
				.foregroundColor(.black)
				.lineLimit(1)
				.background(BarGeometryReady())
				.onPreferenceChange(SizeKey.self) {
					self.barSize = $0
				}
		}
	}
}

struct TopBarViewPreview: PreviewProvider {
	@State static var selected: BarType = BarType("Bar Type")
	
	static var previews: some View {
		
		return NavigationView {
			VStack(alignment: .leading, spacing: 32) {
				TopBarView(
					bars: [
						.init("Bar Type 1"),
						.init("Bar Type"),
						.init("Bar"),
					],
					selected: $selected
				)
				
				TabView(selection: $selected) {
					VStack {
						Text("One")
						Spacer()
						Text("One")
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color.red)
					.tag(BarType("Bar Type 1"))
					Text("Two")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.tag(BarType("Bar Type"))
					Text("Three")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.tag(BarType("Bar"))
				}
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			}
			.padding()
			.navigationTitle("This is a title")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						
					} label: {
						Text("Cancel")
					}
				}
				ToolbarItem(placement: .primaryAction) {
					Button {
						
					} label: {
						Text("Save")
					}
				}
			}
		}
	}
}
