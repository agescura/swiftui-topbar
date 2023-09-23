import Foundation

public struct BarSize: Equatable {
	public let width: CGFloat
	public let originX: Double
	
	public init(
		width: CGFloat,
		originX: Double
	) {
		self.width = width
		self.originX = originX
	}
}
