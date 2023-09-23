import SwiftUI
import TopBar

struct ContentView: View {
	@State var selected: Tab = .home
	
	var body: some View {
		NavigationView {
			MainTopBarView(
				data: Tab.allCases,
				selected: self.$selected,
				content: { element in
					VStack {
						Text(element.rawValue)
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(element.color)
				},
				header: { element, selected in
					HStack {
						Rectangle()
							.fill(selected ? self.selected.color : .gray)
							.frame(width: 10, height: 10)
							.clipShape(Circle())
						Text(element.rawValue)
							.lineLimit(1)
							.foregroundColor(selected ? self.selected.color : .gray)
					}
				}
			)
			.navigationTitle("Selected: \(self.selected.rawValue)")
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
				return "Settings muy grande"
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
	
	var id: Self { self }
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
	@State private var direction: ProgressDirection
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
		self._direction = State(initialValue: .zero)
		self.header = header
		self.content = content
	}
	
	var body: some View {
		VStack {
			TopBarView(
				isScrollEnabled: true,
				bars: self.data,
				selected: self.$selected,
				direction: self.$direction
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
			PageViewController(
				data: self.data,
				selected: self.$selected,
				direction: self.$direction
			) { element in
				self.content(element)
			}
		}
	}
}

struct PageViewController<Data: Hashable, Content: View>: UIViewControllerRepresentable where Data: RandomAccessCollection, Data.Element: Equatable {
	private let data: Data
	@Binding private var selected: Data.Element
	@Binding private var direction: ProgressDirection
	private let content: (Data.Element) -> Content
	private let pageViewController = UIPageViewController(
		transitionStyle: .scroll,
		navigationOrientation: .horizontal
	)
	private var index: Int {
		guard let index = self.data.firstIndex(where: { $0 == self.selected }) as? Int
		else { return 0 }
		return index
	}
	
	init(
		data: Data,
		selected: Binding<Data.Element>,
		direction: Binding<ProgressDirection>,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) {
		self.data = data
		self._selected = selected
		self._direction = direction
		self.content = content
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self, self.pageViewController)
	}
	
	func makeUIViewController(context: Context) -> UIPageViewController {
		pageViewController.dataSource = context.coordinator
		pageViewController.delegate = context.coordinator
		for subview in pageViewController.view.subviews {
			if let scrollView = subview as? UIScrollView {
				scrollView.delegate = context.coordinator
			}
		}
		return pageViewController
	}
	
	func updateUIViewController(
		_ pageViewController: UIPageViewController,
		context: Context
	) {
		pageViewController.setViewControllers(
			[context.coordinator.controllers[self.index]],
			direction: .forward,
			animated: true
		)
	}
	
	func updateDirectionPageViewController(direction: ProgressDirection) {
		self.direction = direction
	}
	
	func changePageViewController(index: Int) {
		guard let index = index as? Data.Index else { return }
		self.selected = self.data[index]
	}
	
	class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
		var parent: PageViewController
		var controllers = [UIViewController]()
		var pageViewController: UIPageViewController
		
		init(
			_ parent: PageViewController,
			_ view: UIPageViewController
		) {
			self.parent = parent
			self.pageViewController = view
			self.controllers = self.parent.data
				.map { RestrictedController(rootView: parent.content($0)) }
		}
		
		func pageViewController(
			_ pageViewController: UIPageViewController,
			viewControllerBefore viewController: UIViewController) -> UIViewController? {
				guard
					let index = controllers.firstIndex(of: viewController),
					index != 0 else {
					return nil
				}
				return controllers[index - 1]
			}
		
		func pageViewController(
			_ pageViewController: UIPageViewController,
			viewControllerAfter viewController: UIViewController
		) -> UIViewController? {
			guard
				let index = controllers.firstIndex(of: viewController),
				index + 1 != controllers.count else {
				return nil
			}
			return controllers[index + 1]
		}
		
		func pageViewController(
			_ pageViewController: UIPageViewController,
			didFinishAnimating finished: Bool,
			previousViewControllers: [UIViewController],
			transitionCompleted completed: Bool
		) {
			if completed,
				let visibleViewController = pageViewController.viewControllers?.first,
				let index = controllers.firstIndex(of: visibleViewController) {
				self.parent.changePageViewController(index: index)
			}
		}
		
		public func scrollViewDidScroll(
			_ scrollView: UIScrollView
		) {
			let point = scrollView.contentOffset
			var percentComplete: CGFloat
			
			percentComplete = (point.x - pageViewController.view.frame.size.width)/pageViewController.view.frame.size.width
			
			print("scrolling ", percentComplete)
			if percentComplete > 0 && percentComplete < 1 {
				
				self.parent.updateDirectionPageViewController(direction: .right(abs(percentComplete)))
			} else if percentComplete > -1 && percentComplete < 0 {
				self.parent.updateDirectionPageViewController(direction: .left(abs(percentComplete)))
			}
		}
	}
}

final public class RestrictedController<Content>: UIHostingController<Content> where Content: View {
	public override var navigationController: UINavigationController? {
		nil
	}
}
