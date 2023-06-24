import SwiftUI
import TopBar

enum Tab: String, CaseIterable {
	case home
	case search
	case settings
	case profile
}

struct ContentView: View {
	@State var selectedTab: Tab = .home
	
	var body: some View {
		VStack {
			TopBarView(
				bars: Tab.allCases,
				selected: self.$selectedTab
			) { tab in
				Text(tab.rawValue)
			}
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundColor(.accentColor)
			Text("Hello, world!")
		}
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
