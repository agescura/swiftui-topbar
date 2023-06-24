import SwiftUI

enum CoordinateSpace {
	case topBar
}

public struct TopBarView<Item: Equatable & Hashable, Content: View>: View {
	let bars: [Item]
	@Binding var selected: Item
	@State var barSize: BarSize = .zero
	let content: (Item) -> Content
	
	public init(
		bars: [Item],
		selected: Binding<Item>,
		content: @escaping (Item) -> Content
	) {
		self.bars = bars
		self._selected = selected
		self.content = content
	}
	
	public var body: some View {
		let _ = print(selected)
		return VStack {
			HStack {
				Spacer()
				ForEach(self.bars, id: \.self) { type in
					BarView(
						type: type,
						selected: self.selected == type,
						onTap: { barSize in
							self.selected = type
							print("onTap", type)
							self.barSize = barSize
						},
						content: self.content
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
		@ViewBuilder content: (Item) -> Content
	) {
		self.type = type
		self.selected = selected
		self.onTap = onTap
		self.content = content(type)
	}
	
	var body: some View {
		Button {
			withAnimation {
				self.onTap(self.barSize)
			}
		} label: {
			self.content
				.background(BarGeometryReady())
				.onPreferenceChange(SizeKey.self) {
					self.barSize = $0
				}
		}
	}
}

enum Tab {
	case home
	case settings
	case profile
	
	var rawValue: String {
		switch self {
			case .home:
				return "Laaaaaaargooooo"
			case .settings:
				return "Sho"
			case .profile:
				return "Normalito"
		}
	}
}
struct TopBarViewPreview: PreviewProvider {
	@State static var selected: Tab = .home
	
	static var previews: some View {
		
		return NavigationView {
			VStack(alignment: .leading, spacing: 32) {
				TopBarView(
					bars: [
						Tab.home,
						.settings,
						.profile
					],
					selected: $selected,
					content: { tab in
						Text(tab.rawValue)
					}
				)
				
				
				TabView(selection: $selected) {
					VStack {
						Text("One")
						Spacer()
						Text("One")
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color.red)
					.tag(Tab.home)
					Text("Two")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.tag(Tab.settings)
					Text("Three")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.tag(Tab.profile)
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
