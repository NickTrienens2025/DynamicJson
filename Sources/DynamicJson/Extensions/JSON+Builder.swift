//
//  JSON+Builder.swift
//
//
//  Created by Nicholas Trienens on 5/10/23.
//

import Foundation

extension String.SubSequence {
    var asString: String {
        String(self)
    }
}

// Public function to create a JSON object.
// Usage: json { ...definition of JSON object... }
public func json(@JSONBuilder conditions makeResult: () -> JSON) -> JSON {
    makeResult()
}

public func json(@JSONBuilder conditions makeResult: () throws -> JSON) rethrows -> JSON {
    try makeResult()
}

// Extension to JSON struct to initialize it with a JSONBuilder.
public extension JSON {
    init(@JSONBuilder statements: () -> JSON) {
        self = statements()
    }

    init(_ array: [JSON]) {
        self = .array(array)
    }

    init(_ string: String.SubSequence) {
        self = .string(string.asString)
    }

    init(_ dictionary: [String: JSONRepresentable]) {
        self = .object(dictionary.mapValues { $0.json })
    }
}

// JSONBuilder is a Swift result builder utilizing the new @resultBuilder directive in Swift.
// It allows the creation of JSON structures using Swift syntax.
// It supports JSON objects, JSON arrays, strings, numbers (Int, Float, Double), booleans and
// `null` JSON values.
@resultBuilder
public enum JSONBuilder {
    public static func buildBlock(_ components: JSON...) -> JSON {
        if components.count == 1 {
            return components[0]
        }
        return .array(components)
    }

    public static func buildExpression(_ expression: [String: JSON]) -> JSON {
        .object(expression)
    }

    public static func buildExpression(_ expression: [String: JSONRepresentable]) -> JSON {
        .object(
            expression.mapValues { value in
                value.json
            }
        )
    }

    public static func buildFinalResult(_ component: JSON) -> JSON {
        component
    }

    public static func buildOptional(_ component: JSON?) -> JSON {
        component ?? .null
    }

    public static func buildEither(first: JSON) -> JSON {
        first
    }

    public static func buildEither(second: JSON) -> JSON {
        second
    }

    public static func buildArray(_ components: [JSON]) -> JSON {
        .array(components)
    }

    public static func buildExpression(_ expression: String) -> JSON {
        .string(expression)
    }

    public static func buildExpression(_ expression: Int) -> JSON {
        .double(Double(expression))
    }

    public static func buildExpression(_ expression: Double) -> JSON {
        .double(expression)
    }

    public static func buildExpression(_ expression: Float) -> JSON {
        .double(Double(expression))
    }

    public static func buildExpression(_ expression: Bool) -> JSON {
        .boolean(expression)
    }

    static func buildExpression(_ expression: [String: String]) -> JSON {
        .object(
            expression.mapValues { value in
                JSON.string(value)
            }
        )
    }

    public static func buildExpression(_ expression: [String: Int]) -> JSON {
        .object(
            expression.mapValues { value in
                JSON.integer(value)
            }
        )
    }

    public static func buildExpression(_ expression: [String: Double]) -> JSON {
        .object(
            expression.mapValues { value in
                JSON.double(value)
            }
        )
    }

    public static func buildExpression(_ expression: [String: Float]) -> JSON {
        .object(
            expression.mapValues { value in
                JSON.double(Double(value))
            }
        )
    }

    //    public static func buildExpression(_ expression: [String: Decimal]) -> JSON {
    //        .object(expression.mapValues { value in
    //            JSON.number(.decimal(value))
    //        })
    //    }

    public static func buildExpression(_ expression: [String: Bool]) -> JSON {
        .object(
            expression.mapValues { value in
                JSON.boolean(value)
            }
        )
    }
}
