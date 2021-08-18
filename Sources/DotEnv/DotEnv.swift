import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public final class DotEnv {
    public var all: [String: String] { ProcessInfo.processInfo.environment }

    public init() {}

    public func readFile(at path: String) throws -> File {
        let fileManager = FileManager.default
        guard let data = fileManager.contents(atPath: path) else { throw fileError(.invalidFile, filePath: path) }
        guard let source = String(data: data, encoding: .utf8) else {
            throw fileError(.fileMustBeUTF8Encodable, filePath: path)
        }

        return File(source)
    }

    public func parseFile(_ file: File) throws -> [String: String] {
        try Parser(file: file).parse()
    }

    public func parseFile(at path: String) throws -> [String: String] {
        try parseFile(try readFile(at: path))
    }

    public func load(atPath path: String, overwrite: Bool = false) throws {
        let variables = try parseFile(at: path)
        set(variables, overwrite: overwrite)
    }

    public func get(_ key: String) -> String? {
        guard let value = getenv(key) else { return nil }
        return String(validatingUTF8: value)
    }

    public func set(_ value: String?, forKey key: String, overwrite: Bool = true) {
        setenv(key, value, overwrite ? 1 : 0)
    }

    public func set(_ variables: [String: String], overwrite: Bool = true) {
        for (key, value) in variables { set(value, forKey: key, overwrite: overwrite) }
    }

    public subscript(key: String) -> String? {
        get { get(key) }
        set { set(newValue, forKey: key) }
    }
}
