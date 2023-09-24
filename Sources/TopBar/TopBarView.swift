import Foundation
import SwiftUI

public struct TopBarView<
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
	private let contentIsNotEmpty: Bool
	
	public init(
		data: Data,
		selected: Binding<Data.Element>,
		@ViewBuilder header: @escaping (Data.Element, Bool) -> Header,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) {
		self.data = data
		self._selected = selected
		self.header = header
		self.content = content
		self.contentIsNotEmpty = true
	}
	
	public var body: some View {
		VStack(spacing: 0) {
			HeaderTopBarView(
				isScrollEnabled: false,
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
			if self.contentIsNotEmpty {
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
}

extension TopBarView {
	public init(
		data: Data,
		selected: Binding<Data.Element>,
		@ViewBuilder header: @escaping (Data.Element, Bool) -> Header
	) where Content == EmptyView {
		self.data = data
		self._selected = selected
		self.header = header
		self.content = { _ in EmptyView() }
		self.contentIsNotEmpty = false
	}
}

extension TopBarView {
	public init(
		data: Data,
		selected: Binding<Data.Element>,
		@ViewBuilder header: @escaping (Data.Element) -> Header,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) {
		self.data = data
		self._selected = selected
		self.header = { element, _ in header(element) }
		self.content = content
		self.contentIsNotEmpty = true
	}
	
	public init(
		data: Data,
		selected: Binding<Data.Element>,
		header: @escaping (Data.Element) -> Header
	) where Content == EmptyView {
		self.data = data
		self._selected = selected
		self.header = { element, _ in header(element) }
		self.content = { _ in EmptyView() }
		self.contentIsNotEmpty = false
	}
	
}
