import SwiftUI

public struct TopBarView<Item: Equatable & Hashable, Content: View, Separator: View, Underscore: View>: View {
	private let isScrollEnabled: Bool
	private let bars: [Item]
	@Binding private var selected: Item
	@State private var barSize: BarSize = .zero
	private let content: (Item, Bool) -> Content
	private let separator: Separator
	private let underscore: Underscore
	@State private var scrollOffset: CGFloat = .zero
	
	public init(
		isScrollEnabled: Bool = false,
		bars: [Item],
		selected: Binding<Item>,
		content: @escaping (Item, Bool) -> Content,
		@ViewBuilder underscore: () -> Underscore = {
			Capsule()
				.frame(height: 3)
				.foregroundColor(.accentColor)
		},
		@ViewBuilder separator: () -> Separator = { Divider() }
	) {
		self.isScrollEnabled = isScrollEnabled
		self.bars = bars
		self._selected = selected
		self.content = content
		self.underscore = underscore()
		self.separator = separator()
	}
	
	public var body: some View {
		VStack {
			ScrollViewReader { proxy in
				HStack {
					Spacer()
					ForEach(self.bars, id: \.self) { type in
						BarView(
							type: type,
							selected: self.selected == type,
							onTap: { barSize in
								self.selected = type
								self.barSize = barSize
							},
							content: self.content
						)
						.id(type)
						Spacer()
					}
				}
				.onChange(of: self.selected) { newValue in
					withAnimation {
						proxy.scrollTo(newValue)
					}
				}
			}
			ZStack(alignment: .leading) {
				self.separator
				Color.clear
					.frame(height: 0)
				self.underscore
					.frame(width: self.barSize.width)
					.offset(x: self.barSize.originX + self.scrollOffset)
			}
		}
		.isScroll(enabled: self.isScrollEnabled)
		.coordinateSpace(name: CoordinateSpace.topBar)
		.onPreferenceChange(ViewOffsetKey.self) {
			self.scrollOffset = $0
		}
	}
}

struct TopBarViewPreview: PreviewProvider {
	enum Tab: CaseIterable {
		case home
		case search
		case settings
		
		var rawValue: String {
			switch self {
				case .home:
					return "Home"
				case .search:
					return "Search"
				case .settings:
					return "Settings"
			}
		}
		
		var color: Color {
			switch self {
				case .home:
					return .red
				case .search:
					return .green
				case .settings:
					return .blue
			}
		}
	}
	
	struct MainView: View {
		@State var selected: Tab = .home
		
		var body: some View {
			NavigationView {
				VStack(alignment: .leading, spacing: 16) {
					TopBarView(
						bars: Tab.allCases,
						selected: $selected
					) { tab, selected in
						HStack {
							Rectangle()
								.fill(selected ? self.selected.color : .gray)
								.frame(width: 10, height: 10)
								.clipShape(Circle())
							Text(tab.rawValue)
								.lineLimit(1)
								.foregroundColor(selected ? self.selected.color : .gray)
						}
					} underscore: {
						Capsule()
							.frame(height: 3)
							.foregroundColor(self.selected.color)
					} separator: {
						Divider()
							.background(self.selected.color.opacity(0.7))
					}
					
					ContentView(selected: self.$selected)
				}
				.navigationTitle("Selected: \(self.selected.rawValue)")
				.navigationBarTitleDisplayMode(.inline)
			}
			.previewDisplayName("Separator and Undescore")
		}
	}
	
	struct ContentView: View {
		@Binding var selected: Tab
		
		var body: some View {
			TabView(selection: $selected) {
				VStack {}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(self.selected.color)
				.tag(Tab.home)
				VStack {}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.tag(Tab.search)
					.background(self.selected.color)
				VStack {}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.tag(Tab.settings)
					.background(self.selected.color)
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
		}
	}

	
	static var previews: some View {
		MainView()
	}
}
