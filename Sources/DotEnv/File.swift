public struct File: CustomStringConvertible, Equatable, ExpressibleByStringLiteral {
    public let source: String
    public let path: String?
    public var description: String { source }

    public init(stringLiteral source: String) {
        self.source = source
        path = nil
    }

    public init(_ source: String, path: String? = nil) {
        self.source = source
        self.path = path
    }
}
