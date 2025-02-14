//
//  composed.swift
//  JSON
//
//  Created by Nick Trienens on 1/19/25.
//

/// A type that can be converted to a `JSON` instance without any loss or errors.
public protocol JSONRepresentable {
    
    /// The `JSON` representation of the instance.
    ///
    ///     42.json // JSON.number(Number.int(42))
    var json: JSON { get }
    
    init?(json: JSON)

}

extension JSON: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return self
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        self = json
    }
}

extension String: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .string(self)
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.stringValue else { return nil }
        self = string
    }
}

extension Optional: JSONRepresentable where Wrapped: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        switch self {
        case .none: return .null
        case let .some(value): return value.json
        }
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        switch json {
        case .null: self = nil
        default: self = Wrapped(json: json)
        }
    }
}

extension Bool: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .boolean(self)
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.boolValue else { return nil }
        self = string
    }
}

//
//extension Array: JSONRepresentable where Element: JSONRepresentable {
//    
//    /// See `SafeJSONRepresentable.json`.
//    public var json: JSON {
//        return .array(self.map { $0.json })
//    }
//    
//    /// See `LosslessJSONConvertible.init(json:)`.
//    public init?(json: JSON) {
//        guard let array = json.arrayValue else { return nil }
//        self = array.compactMap(Element.init(json:))
//    }
//}
//
//extension Dictionary: JSONRepresentable where Key == String, Value: JSONRepresentable {
//    
//    /// See `SafeJSONRepresentable.json`.
//    public var json: JSON {
//        return .dictionary(self.reduce(into: [:]) { data, element in data[element.key] = element.value.json })
//    }
//    
//    /// See `LosslessJSONConvertible.init(json:)`.
//    public init?(json: JSON) {
//        guard let object = json.dictionaryValue else { return nil }
//        self = object.reduce(into: [:]) { result, pair in
//            if let value = Value(json: pair.value.json) {
//                result[pair.key] = value
//            }
//        }
//    }
//}

//
//extension Int8: JSONRepresentable { }
//extension Int16: JSONRepresentable { }
//extension Int32: JSONRepresentable { }
//extension Int64: JSONRepresentable { }
//extension UInt8: JSONRepresentable { }
//extension UInt16: JSONRepresentable { }
//extension UInt32: JSONRepresentable { }
//extension UInt64: JSONRepresentable { }

