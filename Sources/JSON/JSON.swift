import Foundation

/// This type nests and uses subscripts and dynamic member look up to traverse a JSON structure
/// since we are using @dynamicMemberLookup datalookup will happen on .properties or subscripts
/// while any action will be a function on this type, this helps understand the difference
/// between methods and data access, the big exception is `.description` returns the
/// CustomStringConvertible value for debugging, if you need to get a property with the name
/// "description" use a subscript
///
/// let objectDescription: JSON = ["description" : "Hello, world!"]
/// ❌  objectDescription.description      XCTAssertEqual(objectDescription.description,
/// #"{"description":"Hello, world!"}"#)
/// ✔️objectDescription["description"] XCTAssertEqual(objectDescription["description"], "Hello,
/// world!")
///
///
@dynamicMemberLookup
public enum JSON:
    Hashable,
    CustomStringConvertible,
    Sendable,
    Comparable
{
    
    indirect case array([JSON])
    indirect case object([String: JSON])
    case string(String)
    case double(Double)
    case integer(Int)
    case boolean(Bool)
    case null

    public init(_ array: [Any?]) {
        self = array.json
    }

    public init(_ dictionary: [String: Any?]) {
        self = dictionary.json
    }

    // MARK: - Dynamic Member Access

    /// Gets the JSON value for a given key.
    ///
    /// - Complexity: _O(n)_, where _n_ is the number of elements in the JSON array you are
    /// accessing object values from.
    ///   More often though, you are accessing object values via key, and that is _O(1)_.
    ///
    /// Most of the time, the member passed in with be a `String` key. This will get a value for
    /// an object key:
    ///
    ///     json.user.first_name // .string("Tanner")
    ///
    /// However, `Int` members are also supported in that case of a `JSON` array:
    ///
    ///     json.users.0.age // .number(.int(42))
    ///
    /// - Parameter member: The key for JSON objects or index for JSON arrays of the value to
    /// get.
    ///
    /// - Returns: The JSON value for the given key or index. `.null` is returned if the value
    /// is not found or
    ///   the JSON value this subscript is called on does not have nested data, i.e. `.string`,
    /// `.bool`, etc.
    public subscript(dynamicMember member: String) -> JSON {
        get {
            switch self {
            case let .object(object):
                return object[member] ?? .null
            case let .array(array) where Int(member) != nil:
                guard let index = Int(member), index >= array.startIndex, index < array.endIndex
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

    // MARK: - Accessors

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
        path.reduce(self) { json, key in
            switch json {
            case let .object(object): return object[key] ?? .null
            case let .array(array) where Int(key) != nil:
                guard let index = Int(key), index >= array.startIndex, index < array.endIndex
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
    public mutating func set(_ path: some Collection<String>, to json: JSON) {
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
    /// The `JSON` type converts `nil` to it's `.null` case, so if you try to remove a value
    /// like this:
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
    /// To actually remove a property from an object, you use `.remove(_:)` with the path to the
    /// property to remove:
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
    public mutating func remove(_ path: some Collection<String>) {
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
    
    // MARK: - Typed Comparable
    public static func < (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, _):
            return false
        case (_, .null):
            return true
        case (.string(let l), .string(let r)):
            return l < r
        case (.double(let l), .double(let r)):
            return l < r
        case (.integer(let l), .integer(let r)):
            return l < r
        case (.boolean(let l), .boolean(let r)):
            return l == false && r == true
        case (.array(let l), .array(let r)):
            return l.lexicographicallyPrecedes(r)
        case (.object(let l), .object(let r)):
            return l.lexicographicallyPrecedes(r, by: { $0.key == $1.key ? $0.value < $1.value : $0.key < $1.key })
        case (.string(let s), .integer(let i)):
            if let num = Int(s) {
                return num < i
            }
            return "\(lhs)" < "\(rhs)"
        case (.integer(let i), .string(let s)):
            if let num = Int(s) {
                return i < num
            }
            return "\(lhs)" < "\(rhs)"
        case (.string(let s), .double(let d)):
            if let num = Double(s) {
                return num < d
            }
            return "\(lhs)" < "\(rhs)"
        case (.double(let d), .string(let s)):
            if let num = Double(s) {
                return d < num
            }
            return "\(lhs)" < "\(rhs)"
        case (.integer(let i), .double(let d)):
            return Double(i) < d
        case (.double(let d), .integer(let i)):
            return d < Double(i)
        default:
            // Sort by enum case order if types don't match
            return "\(lhs)" < "\(rhs)"
        }
    }
    

    // MARK: - Typed Accessors

    /// Returns a `Array<Any>` representation of the receiver.
    /// The returned value is suitable for encoding as JSON via
    /// `JSONSerialization.data(withJSONObject:options:)`.
    public func asArray() -> [JSON]? {
        switch self {
        case let .array(value):
            value
        default:
            nil
        }
    }

    /// Returns a `Bool` representation of the receiver if the
    /// underlying type is `.boolean`, otherwise `nil`.
    public func asBool() -> Bool? {
        switch self {
        case let .boolean(value):
            value
        default:
            nil
        }
    }

    /// Returns a `Double` representation of the receiver if the
    /// underlying type is `.number`, otherwise `nil`.
    public func asDouble() -> Double? {
        switch self {
        case let .double(double):
            double
        case let .integer(int):
            Double(int)
        default:
            nil
        }
    }

    /// Returns a `Dictionary<String, Any>` representation of the receiver.
    /// The returned value is suitable for encoding as JSON via
    /// `JSONSerialization.data(withJSONObject:options:)`.
    public func asObject() -> [String: JSON]? {
        switch self {
        case let .object(value):
            value
        default:
            nil
        }
    }

    /// Returns a `Int` representation of the receiver if the
    /// underlying type is `.number`, otherwise `nil`.
    public func asInt() -> Int? {
        switch self {
        case let .double(double):
            Int(double)
        case let .integer(int):
            int
        default:
            nil
        }
    }

    /// Returns a `String` representation of the receiver if the
    /// underlying type is `.string`, otherwise `nil`.
    public func asString() -> String? {
        switch self {
        case let .string(value):
            value
        default:
            nil
        }
    }
    
    public func asStringDefaulting( to: String = "") -> String {
        asString() ?? to
    }
    public func asIntDefaulting( to: Int = 0) -> Int {
        asInt() ?? to
    }
    public func asObjectDefaulting( to: [String: JSON]) -> [String: JSON] {
        asObject() ?? to
    }
    public func asArrayDefaulting( to: [JSON]) -> [JSON] {
        asArray() ?? to
    }
    public func asDoubleDefaulting( to: Double = 0) -> Double {
        asDouble() ?? to
    }
    public func asBoolDefaulting( to: Bool = true) -> Bool {
        asBool() ?? to
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
            return "[" + array.map(\.description).joined(separator: ",") + "]"
        case let .object(object):
            let data = object.map { "\"" + $0.key + "\":" + $0.value.description }.joined(separator: ",")
            return "{" + data + "}"
        }
    }

    // MARK: - Conversions

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

// MARK: - ExpressibleByLiteral

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
    public static func == (_ lhs: JSON, _ rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
            
        case let (.boolean(l), .boolean(r)):
            return l == r
            
        case let (.string(l), .string(r)):
            return l == r
            
        case let (.double(l), .double(r)):
            return l == r
            
        case let (.integer(l), .integer(r)):
            return l == r
            
        case let (.array(l), .array(r)):
            return l == r
            
        case let (.object(l), .object(r)):
            return l == r
            
        // String to number conversions
        case let (.string(s), .integer(i)):
            guard let num = Int(s) else { return false }
            return num == i
            
        case let (.integer(i), .string(s)):
            guard let num = Int(s) else { return false }
            return i == num
            
        case let (.string(s), .double(d)):
            guard let num = Double(s) else { return false }
            return num == d
            
        case let (.double(d), .string(s)):
            guard let num = Double(s) else { return false }
            return d == num
            
        // Integer and double conversions
        case let (.integer(i), .double(d)):
            return Double(i) == d
            
        case let (.double(d), .integer(i)):
            return d == Double(i)
            
        default:
            return false
        }
    }
}

// MARK: - Codable
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

// MARK - Any extensions
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

private extension Any? {
    var json: JSON? {
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
