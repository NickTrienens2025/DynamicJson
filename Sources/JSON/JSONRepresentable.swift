//
//  JSONRepresentable.swift
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
        self
    }

    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        self = json
    }
}

extension String: JSONRepresentable {
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        .string(self)
    }

    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.asString() else { return nil }
        self = string
    }
}

extension Optional: JSONRepresentable where Wrapped: JSONRepresentable {
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        switch self {
        case .none: .null
        case let .some(value): value.json
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
        .boolean(self)
    }

    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.asBool() else { return nil }
        self = string
    }
}
