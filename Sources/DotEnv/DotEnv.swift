import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Manages environment files and variables.
public final class DotEnv {
    /// All system and user-defined environment variables.
    public var all: [String: String] { ProcessInfo.processInfo.environment }

    /// A configuration for `DotEnv`.
    public var configuration: Configuration

    private var fileCache = Cache<String, File>()
    private var variablesCache = Cache<File, [String: String]>()

    /// Initializes a new instance of `DotEnv` with the default configuration.
    ///
    /// - Parameter configuration: A configuration for `DotEnv`.
    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        fileCache.costLimit = configuration.caching.costLimit
        fileCache.countLimit = configuration.caching.countLimit
        variablesCache.costLimit = configuration.caching.costLimit
        variablesCache.countLimit = configuration.caching.countLimit
    }

    /// Reads the content of an environment file or throws `FileError`.
    ///
    /// - Parameter path: An absolute path to an environment file in the file system.
    /// - Parameters:
    ///   - path: An absolute path to an environment file in the file system.
    ///   - encoding: A content encoding. Defaults to `utf8`.
    /// - Throws: `FileError` if an environment file being loaded either doesn't exist or is not encodable.
    /// - Returns: An instance of `File`.
    public func readFile(at path: String, encoding: String.Encoding = .utf8) throws -> File {
        if configuration.caching.isEnabled, let file = fileCache.getValue(forKey: path) { return file }
        let fileManager = FileManager.default
        guard let data = fileManager.contents(atPath: path) else { throw fileError(.fileNotFound, filePath: path) }
        guard let source = String(data: data, encoding: encoding) else {
            throw fileError(.fileNotEncodable, filePath: path)
        }
        let file = File(source, path: path)
        if configuration.caching.isEnabled { fileCache.setValue(file, forKey: path) }

        return file
    }

    /// Parses and extracts environment variables from the content of an environment file or throws `SyntaxError`.
    ///
    /// - Parameter file: An instance of `File`.
    /// - Throws: `SyntaxError` if the content of an environment file is invalid.
    /// - Returns: A list of all environment variables from an environment file.
    public func parseFile(_ file: File) throws -> [String: String] {
        if configuration.caching.isEnabled, let variables = variablesCache.getValue(forKey: file) { return variables }
        let variables = try Parser(file: file).parse()
        if configuration.caching.isEnabled { variablesCache.setValue(variables, forKey: file) }

        return variables
    }

    /// Reads, parses, and extracts environment variables from the content of an environment file or throws either `FileError` or `SyntaxError`.
    ///
    /// - Parameter path: An absolute path to an environment file.
    /// - Throws: `FileError` if an environment file being loaded either doesn't exist or is not encodable or `SyntaxError` if the content of
    /// an environment file is invalid.
    /// - Returns: A list of all environment variables in an environment file.
    public func parseFile(at path: String) throws -> [String: String] {
        try parseFile(try readFile(at: path))
    }

    /// Reads, parses, extracts, and set enviroment variables from the content of an environment file or throws either `FileError` or `SyntaxError`.
    ///
    /// - Parameters:
    ///   - path: An absolute path to an environment file.
    ///   - overwrite: A boolean value to indicate whether to overwrite the value of the existing environment variable or not. Defaults to `true`.
    /// - Throws: `FileError` if an environment file being loaded either doesn't exist or is not encodable or `SyntaxError` if the content of
    /// an environment file is invalid.
    public func load(atPath path: String, overwrite: Bool = true) throws {
        let variables = try parseFile(at: path)
        set(variables, overwrite: overwrite)
    }

    /// Gets an environment variable.
    ///
    /// - Parameters:
    ///     - key: The key of an environment variable.
    ///     - encoding: A value encoding. Defaults to `utf8`.
    /// - Returns: The value of an environment variable if an environment variable exists.
    public func get(_ key: String, encoding: String.Encoding = .utf8) -> String? {
        guard let value = getenv(key) else { return nil }
        return String(cString: value, encoding: encoding)
    }

    /// Sets an environment variable.
    ///
    /// - Parameters:
    ///   - value: The value of an environment variable. Providing `nil` or an empty string results in an empty string value.
    ///   - key: The key of an environment variable.
    ///   - overwrite: A boolean value to indicate whether to overwrite the value of the existing environment variable or not. Defaults to `true`.
    public func set(_ value: String?, forKey key: String, overwrite: Bool = true) {
        let value = value ?? ""
        setenv(key, value, overwrite ? 1 : 0)
    }

    /// Sets multiple environment variables.
    ///
    /// - Parameters:
    ///   - variables: `[key: value]` pairs of environment variables.
    ///   - overwrite: A boolean value to indicate whether to overwrite values of the existing environment variables or not. Defaults to `true`.
    public func set(_ variables: [String: String], overwrite: Bool = true) {
        for (key, value) in variables { set(value, forKey: key, overwrite: overwrite) }
    }

    /// Removes a user-defined environment variable.
    ///
    /// - Parameter key: The key of an environment variable.
    public func unset(_ key: String) {
        unsetenv(key)
    }

    /// Removes all user-defined environment variables.
    public func reset() {
        for key in all.keys { unset(key) }
    }

    /// Gets or sets an environment variable.
    ///
    /// - Parameter key: The key of an environment variable.
    /// - Returns: The value of an environment variable if an environment variable exists.
    public subscript(key: String) -> String? {
        get { get(key) }
        set { set(newValue, forKey: key) }
    }

    /// Clears memory cache.
    public func clearCache() {
        fileCache.clear()
        variablesCache.clear()
    }
}

extension DotEnv {
    /// A configuration for `DotEnv`.
    public struct Configuration {
        /// A caching configuration.
        public let caching: CachingConfiguration

        /// Initializes a new instance of `Configuration` with the default caching configuration.
        ///
        /// - Parameter caching: A caching configuration.
        public init(caching: CachingConfiguration = .init()) {
            self.caching = caching
        }
    }
}

extension DotEnv {
    /// A caching configuration.
    public struct CachingConfiguration {
        /// Limits the amount of memory usage in RAM.
        public let costLimit: Int

        /// Limits the number of objects in RAM.
        public let countLimit: Int

        /// Indicates whether caching is enabled or not.
        public let isEnabled: Bool

        /// Initializes a new instance of `CachingConfiguration` with the `costLimit` and `countLimit` parameters.
        ///
        /// - Parameters:
        ///   - costLimit: Limits the amount of memory usage in RAM. Defaults to `0` that means unlimited until the OS evicts itself due to memory
        ///   pressure.
        ///   - countLimit: Limits the number of objects in RAM. Defaults to `0` that means unlimited until the OS evicts itself due to memory
        ///   pressure.
        ///   - isEnabled: Indicates whether caching is enabled or not. Defaults to `true`.
        public init(costLimit: Int = 0, countLimit: Int = 0, isEnabled: Bool = true) {
            self.costLimit = costLimit
            self.countLimit = countLimit
            self.isEnabled = isEnabled
        }
    }
}
