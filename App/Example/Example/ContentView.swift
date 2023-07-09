import SwiftUI
import TopBar

struct ContentView: View {
	@State var selected: Tab = .home
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 8) {
				TopBarView(
					isScrollEnabled: true,
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
