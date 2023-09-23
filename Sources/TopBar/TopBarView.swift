import SwiftUI

public enum ProgressDirection: Equatable {
	case zero
	case left(CGFloat)
	case right(CGFloat)
}

public struct TopBarView<Data: RandomAccessCollection, Content: View, Separator: View, Underscore: View>: View where Data.Element: Equatable & Hashable {
	private let isScrollEnabled: Bool
	private let bars: Data
	@Binding private var selected: Data.Element
	@Binding private var direction: ProgressDirection
	private let content: (Data.Element, Bool) -> Content
	private let separator: Separator
	private let underscore: Underscore
	@State private var barSize: BarSize = .zero
	
	@State private var viewFrames: [CGRect]
	
	public init(
		isScrollEnabled: Bool = false,
		bars: Data,
		selected: Binding<Data.Element>,
		direction: Binding<ProgressDirection>,
		content: @escaping (Data.Element, Bool) -> Content,
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
		self._direction = direction
		self.content = content
		self.underscore = underscore()
		self.separator = separator()
		self._viewFrames = State(
			initialValue: Array<CGRect>(
				repeating: CGRect(),
				count: self.bars.count
			)
		)
	}
	
	public var body: some View {
		VStack(spacing: 8) {
			ScrollViewReader { proxy in
				HStack(spacing: 0) {
					Spacer()
					ForEach(Array(self.bars.enumerated()), id: \.offset) { index, type in
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
						.background(
							GeometryReader { geometry in
								Color.clear.onAppear {
									self.viewFrames[safe: index] = geometry.frame(in: .global)
								}
							}
						)
						Spacer()
					}
				}
				.onChange(of: self.selected) { newValue in
					withAnimation {
						proxy.scrollTo(newValue)
					}
				}
			}
		}
		.isScroll(enabled: self.isScrollEnabled)
		.coordinateSpace(name: CoordinateSpace.topBar)
		ZStack(alignment: .leading) {
			Color.clear
				.frame(height: 0)
			self.separator
			self.underscore
				.frame(width: self.barSize.width)
				.offset(x: self.barSize.originX)
		}
		.onChange(of: self.direction) { direction in
			guard let index = self.bars.firstIndex(where: { $0 == self.selected }) as? Int
			else { return }
			
			switch direction {
				case .zero:
					print("zero")
					break
				case let .left(progress):
					guard self.selected != self.bars.first
					else {
						let frame = self.viewFrames[index]
						withAnimation {
							print("is first")
							self.barSize = BarSize(
								width: frame.width,
								originX: frame.origin.x
							)
						}
						return
					}
					let frames = self.viewFrames[index-1]
					print("to left")
					self.barSize = BarSize(
						width: self.barSize.width - (self.barSize.width - frames.width) * progress / 10.0,
						originX: self.barSize.originX - (self.barSize.originX - frames.origin.x) * progress / 10.0
					)
				case let .right(progress):
					guard self.selected != self.bars.last
					else {
						let frame = self.viewFrames[index]
						print("is last")
						withAnimation {
							self.barSize = BarSize(
								width: frame.width,
								originX: frame.origin.x
							)
						}
						return
					}
					let frames = self.viewFrames[index+1]
					print("to right")
					self.barSize = BarSize(
						width: self.barSize.width + (frames.width - self.barSize.width) * progress / 10.0,
						originX: self.barSize.originX + (frames.origin.x - self.barSize.originX) * progress / 10.0
					)
			}
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
				VStack(alignment: .leading, spacing: 8) {
					TopBarView(
						isScrollEnabled: true,
						bars: Tab.allCases,
						selected: $selected,
						direction: .constant(.zero)
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
	}
	
	struct ContentView: View {
		@Binding var selected: Tab
		
		var body: some View {
			TabView(selection: $selected) {
				ScrollView {
					VStack {
						ForEach(0..<1_000) { id in
							Text("Index \(id)")
						}
					}
				}
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

extension Collection {
	 subscript (safe index: Index) -> Element? {
		  return indices.contains(index) ? self[index] : nil
	 }
}

extension MutableCollection {
	 subscript(safe index: Index) -> Element? {
		  get {
				return indices.contains(index) ? self[index] : nil
		  }

		  set(newValue) {
				if let newValue = newValue, indices.contains(index) {
					 self[index] = newValue
				}
		  }
	 }
}
