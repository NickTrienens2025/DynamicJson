import Foundation

// This type nests and uses subscripts and dynamic member look up to traverse a JSON structure
// since we are using @dynamicMemberLookup datalookup will happen on .properties or subscripts while any action will be a function on this type, this helps understand the difference between methods and data access

@dynamicMemberLookup
public enum JSON:
    Hashable,
    CustomStringConvertible,
    Sendable
{
    indirect case array([JSON])
    case boolean(Bool)
    indirect case object([String: JSON])
    case double(Double)
    case integer(Int)
    case null
    case string(String)

    public init(_ array: [Any?]) {
        self = array.json
    }

    public init(_ dictionary: [String: Any?]) {
        self = dictionary.json
    }

    // MARK: - Dynamic Member Access
    /// Gets the JSON value for a given key.
    ///
    /// - Complexity: _O(n)_, where _n_ is the number of elements in the JSON array you are accessing object values from.
    ///   More often though, you are accessing object values via key, and that is _O(1)_.
    ///
    /// Most of the time, the member passed in with be a `String` key. This will get a value for an object key:
    ///
    ///     json.user.first_name // .string("Tanner")
    ///
    /// However, `Int` members are also supported in that case of a `JSON` array:
    ///
    ///     json.users.0.age // .number(.int(42))
    ///
    /// - Parameter member: The key for JSON objects or index for JSON arrays of the value to get.
    ///
    /// - Returns: The JSON value for the given key or index. `.null` is returned if the value is not found or
    ///   the JSON value this subscript is called on does not have nested data, i.e. `.string`, `.bool`, etc.
    public subscript(dynamicMember member: String) -> JSON {
        get {
            switch self {
            case let .object(object):
                return object[member] ?? .null
            case let .array(array) where Int(member) != nil:
                guard let index = Int(member), index >= array.startIndex && index < array.endIndex
                else { return .null }
                return array[index]
            default: return .null
            }
        }
        set {
            switch self {
            case var .object(object):
                object[member] = newValue
                self = .object(object)
            case var .array(array) where Int(member) != nil:
                guard let index = Int(member) else { return }
                array[index] = newValue
                self = .array(array)
            default: self = newValue
            }
        }
    }

    // MARK: - Subscript
    public subscript(key: String) -> JSON {
        get {
            guard case let .object(dict) = self else { return nil }
            return dict[key] ?? .null
        }
        set {
            guard case var .object(dict) = self else { return }
            dict[key] = newValue
            self = .object(dict)
        }
    }

    public subscript(index: Int) -> JSON {
        get {
            guard case let .array(arr) = self, index < arr.count
            else { return .null }
            return arr[index]
        }
        set {
            guard case var .array(arr) = self else { return }
            arr[index] = newValue
            self = .array(arr)
        }
    }

    // Accessors

    /// Gets the JSON at a given path.
    ///
    /// - Complexity: _O(n)_ where _n_ is the number of elements in the path.
    ///
    /// If an `.array` case is found, the path key will be converted to an index and
    /// the array element at that index will be returned. If key to index conversion fails,
    /// or the index it outside the range of the array, `.null` is returned.
    ///
    /// - Parameter path: The keys and indexes to the desired JSON value(s).
    /// - Returns: Thw JSON value(s) found at the path passed in. You will get a `.null` case
    ///   if no JSON is found at the given path.
    public func get(_ path: [String]) -> JSON {
        return path.reduce(self) { json, key in
            switch json {
            case let .object(object): return object[key] ?? .null
            case let .array(array) where Int(key) != nil:
                guard let index = Int(key), index >= array.startIndex && index < array.endIndex
                else { return .null }
                return array[index]
            default: return .null
            }
        }
    }

    /// Sets the value of an object key or array index.
    ///
    /// - Complexity: _O(n)_, where _n_ is the number of elements in the `path`. This method is
    ///   recursive, so you may have adverse performance for long paths.
    ///
    /// - Parameters:
    ///   - path: The path of the value to set.
    ///   - json: The JSON value to set the index or key to.
    public mutating func set<Path>(_ path: Path, to json: JSON)
    where Path: Collection, Path.Element == String {
        if let key = path.first {
            switch self {
            case var .object(object):
                if object[key] == nil { object[key] = .null }
                object[key]?.set(path.dropFirst(), to: json)
                self = .object(object)
            case var .array(array) where Int(key) != nil:
                guard let index = Int(key) else { return }
                array[index].set(path.dropFirst(), to: json)
                self = .array(array)
            default:
                var value = JSON.null
                value.set(path.dropFirst(), to: json)
                if let index = Int(key) {
                    self = .array(Array(repeating: .null, count: index) + [value])
                } else {
                    self = .object([key: value])
                }
            }
        } else {
            self = json
        }
    }

    /// Removes a key/value pair from an object at a given path.
    ///
    /// The `JSON` type converts `nil` to it's `.null` case, so if you try to remove a value like this:
    ///
    ///     json["foo", "bar"] = nil
    ///
    /// You just set the object's property to `null`:
    ///
    ///     {
    ///         "foo": {
    ///             "bar": null
    ///         }
    ///     }
    ///
    /// To actually remove a property from an object, you use `.remove(_:)` with the path to the property to remove:
    ///
    ///     json.remove(["foo", "bar"])
    ///
    /// Will result in this json structure:
    ///
    ///     {
    ///         "foo": {}
    ///     }
    ///
    /// - Parameter path: The key path to the json property to remove.
    ///
    /// - Complexity: _O(n)_, where _n_ is the number of elements in the path to remove.
    ///   Keep in mind that this method is recursive, so each succesive eleemnt in the path will
    ///   add another call to the stack.
    public mutating func remove<Path>(_ path: Path) where Path: Collection, Path.Element == String {
        guard path.count > 0 else { return }
        if let key = path.first {

            guard var object = self.asObject() else { return }

            if path.count == 1 {
                object[key] = nil
                self = JSON(object)
            } else {
                if var json = object[key] {
                    json.remove(path.dropFirst())
                    self[key] = json
                }
            }
        }
    }

    // Computed Varaiables

    /// Returns a `Array<Any>` representation of the receiver.
    /// The returned value is suitable for encoding as JSON via
    /// `JSONSerialization.data(withJSONObject:options:)`.
    public func asArray() -> [JSON]? {
        switch self {
        case .array(let double):
            return double
        default:
            return nil
        }
    }
    /// Returns a `Bool` representation of the receiver if the
    /// underlying type is `.boolean`, otherwise `nil`.
    public func asBool() -> Bool? {
        switch self {
        case .boolean(let value):
            return value
        default:
            return nil
        }
    }

    /// Returns a `Double` representation of the receiver if the
    /// underlying type is `.number`, otherwise `nil`.
    public func asDouble() -> Double? {
        switch self {
        case .double(let double):
            return double
        case .integer(let int):
            return Double(int)
        default:
            return nil
        }
    }

    /// Returns a `Dictionary<String, Any>` representation of the receiver.
    /// The returned value is suitable for encoding as JSON via
    /// `JSONSerialization.data(withJSONObject:options:)`.
    public func asObject() -> [String: JSON]? {
        switch self {
        case .object(let double):
            return double
        default:
            return nil
        }
    }

    /// Returns a `Int` representation of the receiver if the
    /// underlying type is `.number`, otherwise `nil`.
    public func asInt() -> Int? {
        switch self {
        case .double(let double):
            return Int(double)
        case .integer(let int):
            return int
        default:
            return nil
        }
    }
    /// Returns a `String` representation of the receiver if the
    /// underlying type is `.string`, otherwise `nil`.
    public func asString() -> String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }

    /// Returns `true` if the receiver is an array, otherwise `false`.
    public func isArray() -> Bool {
        guard case .array = self else { return false }
        return true
    }

    /// Returns `true` if the receiver is a JSON object (a "dictionary"),
    /// otherwise `false`.
    public func isObject() -> Bool {
        guard case .object = self else { return false }
        return true
    }

    /// Returns `true` if the receiver is a string value,
    /// otherwise `false`.
    public func isString() -> Bool {
        guard case .string = self else { return false }
        return true
    }

    /// Returns `true` if the receiver is a double value,
    /// otherwise `false`.
    public func isDouble() -> Bool {
        guard case .double = self else { return false }
        return true
    }

    /// Returns `true` if the receiver is an integer value,
    /// otherwise `false`.
    public func isInt() -> Bool {
        guard case .integer = self else { return false }
        return true
    }

    /// Returns `true` if the receiver is a boolean value,
    /// otherwise `false`.
    public func isBool() -> Bool {
        guard case .boolean = self else { return false }
        return true
    }

    public var description: String {
        switch self {
        case .null: return "null"
        case let .string(string): return #""\#(string)""#
        case let .double(number): return "\(number)"
        case let .integer(number): return "\(number)"
        case let .boolean(bool): return bool.description
        case let .array(array):
            return "[" + array.map { $0.description }.joined(separator: ",") + "]"
        case let .object(object):
            let data = object.map { "\"" + $0.key + "\":" + $0.value.description }.joined(
                separator: ",")
            return "{" + data + "}"
        }
    }

    // MARK:  - Conversions
    public func asJsonString() -> String {
        let encoder = JSONEncoder()
        if #available(macOS 10.15, *) {
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        } else {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        if let data = try? encoder.encode(self),
            let jString = String(data: data, encoding: .utf8)
        {
            return jString
        } else {
            return "\(self)"
        }
    }

    public func asData() throws -> Data {
        let encoder = JSONEncoder()
        if #available(macOS 10.15, *) {
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        } else {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        return try encoder.encode(self)
    }
}

// MARK:  - ExpressibleByLiteral
extension JSON:
    ExpressibleByArrayLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByDictionaryLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByNilLiteral,
    ExpressibleByStringLiteral
{
    public typealias ArrayLiteralElement = Any?
    public typealias FloatLiteralType = Double
    public typealias IntegerLiteralType = Int
    public typealias Key = String
    public typealias StringLiteralType = String
    public typealias Value = Any?

    public init(arrayLiteral elements: Any?...) {
        var array = [JSON]()
        for value in elements {
            guard let v = value.json else { continue }
            array.append(v)
        }
        self = .array(array)
    }

    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }

    public init(dictionaryLiteral elements: (String, Any?)...) {
        var dictionary = [String: JSON]()
        for (key, value) in elements {
            guard let v = value.json else { continue }
            dictionary[key] = v
        }
        self = .object(dictionary)
    }

    public init(floatLiteral value: Double) {
        self = .double(value)
    }

    public init(integerLiteral value: Int) {
        self = .integer(value)
    }

    public init(nilLiteral _: ()) {
        self = .null
    }

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

// MARK: - Equatable
extension JSON: Equatable {
    public static func == (_ arg1: JSON, _ arg2: JSON) -> Bool {
        switch (arg1, arg2) {
        case let (.array(one), .array(two)):
            let value = one == two
            return value

        case let (.boolean(one), .boolean(two)):
            return one == two

        case let (.object(one), .object(two)):
            let value = one == two
            return value

        case let (.double(one), .double(two)):
            return one == two

        case let (.integer(one), .integer(two)):
            return one == two
            
        case (.null, .null):
            return true

        case let (.string(one), .string(two)):
            return one == two

        default:
            return false
        }
    }
}

extension JSON: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .boolean(bool)
        } else if let integer = try? container.decode(Int.self) {
            self = .integer(integer)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSON].self) {
            self = .array(array)
        } else if let dictionary = try? container.decode([String: JSON].self) {
            self = .object(dictionary)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid JSON value."
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .null:
            try container.encodeNil()

        case let .boolean(bool):
            try container.encode(bool)

        case let .double(double):
            try container.encode(double)

        case let .integer(int):
            try container.encode(int)

        case let .string(string):
            try container.encode(string)

        case let .array(array):
            try container.encode(array)

        case let .object(dictionary):
            try container.encode(dictionary)
        }
    }
}

extension [Any?] {
    var json: JSON {
        .array(compactMap(\.json))
    }
}

extension [String: Any?] {
    public var json: JSON {
        var dictionary = [String: JSON]()
        for (key, value) in self {
            if let v = value.json {
                dictionary[key] = v
            } else {
                dictionary[key] = .null
            }
        }
        return .object(dictionary)
    }
}

extension Any? {
    fileprivate var json: JSON? {
        guard case let .some(element) = self else { return .null }

        switch element {
        case let e as [Any?]: return e.json
        case let e as [String: Any?]: return e.json
        case is NSNull: return .null
        case let e as String: return .string(e)
        // The above cases should catch everything, but, in case they
        // don't, we try remaining types here.
        case let e as Bool: return .boolean(e)
        case let e as Double: return .double(e)
        case let e as Float: return .double(Double(e))
        case let e as Float32: return .double(Double(e))
        case let e as Int: return .integer(e)
        case let e as Int8: return .integer(Int(e))
        case let e as Int16: return .integer(Int(e))
        case let e as Int32: return .integer(Int(e))
        case let e as Int64: return .integer(Int(e))
        case let e as UInt: return .integer(Int(e))
        case let e as UInt8: return .integer(Int(e))
        case let e as UInt16: return .integer(Int(e))
        case let e as UInt32: return .integer(Int(e))
        case let e as UInt64: return .integer(Int(e))
        case let e as JSON: return e
        default: return nil
        }
    }
}
