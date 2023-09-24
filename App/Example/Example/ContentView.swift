import SwiftUI
import TopBar

struct ContentView: View {
	@State var selected: Tab = .home
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 8) {
				TopBarView(
					data: Tab.allCases,
					selected: self.$selected,
					header: { tab in
						Text(tab.rawValue)
					}
				)
				Spacer()
			}
			.navigationTitle("Selected: \(self.selected.rawValue)")
			.navigationBarTitleDisplayMode(.inline)
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
