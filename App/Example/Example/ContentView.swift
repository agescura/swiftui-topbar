import SwiftUI
import TopBar

struct ContentView: View {
	@State var selected: Tab = .home
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 8) {
				MainTopBarView(
					data: Tab.allCases,
					selected: self.$selected,
					content: { item in
						VStack {}
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.background(item.color)
					},
					header: { tab, selected in
						HStack {
							Rectangle()
								.fill(selected ? self.selected.color : .gray)
								.frame(width: 10, height: 10)
								.clipShape(Circle())
							Text(tab.rawValue)
								.lineLimit(1)
								.foregroundColor(selected ? self.selected.color : .gray)
						}
					}
				)
			}
			.navigationTitle("Selected: \(self.selected.rawValue)")
			.navigationBarTitleDisplayMode(.inline)
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
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

enum Tab: CaseIterable, Identifiable {
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
	
	var id: Self {
		self
	}
}

struct MainTopBarView<
	Data: Hashable,
	Content,
	Header
>: View where
Data: RandomAccessCollection,
Data.Element: Identifiable & Hashable,
Content: View,
Header: View
{
	private let data: Data
	@Binding private var selected: Data.Element
	private let content: (Data.Element) -> Content
	private let header: (Data.Element, Bool) -> Header
	
	public init(
		data: Data,
		selected: Binding<Data.Element>,
		@ViewBuilder content: @escaping (Data.Element) -> Content,
		@ViewBuilder header: @escaping (Data.Element, Bool) -> Header
	) {
		self.data = data
		self._selected = selected
		self.header = header
		self.content = content
	}
	
	var body: some View {
		VStack {
			TopBarView(
				isScrollEnabled: true,
				bars: self.data,
				selected: self.$selected
			) { tab, selected in
				self.header(tab, selected)
			} underscore: {
				Capsule()
					.frame(height: 3)
					.foregroundColor(.green)
			} separator: {
				Divider()
					.background(Color.gray.opacity(0.7))
			}
			TabView(
				selection: self.$selected
			) {
				ForEach(self.data) { element in
					self.content(element)
						.tag(element.id)
				}
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
		}
	}
}
