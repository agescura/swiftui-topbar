import SwiftUI
import TopBar

extension TopBarView {
	func topBarStyle(_ modifier: some TopBarModifier) -> some View {
		self.modifier(modifier)
	}
}

protocol TopBarModifier: ViewModifier {}

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
//				.topBarStyle(.defaultValue)
				.pickerStyle(.inline)
				Spacer()
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
