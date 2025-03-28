//
//  JSON+Extensions.swift
//
//
//  Created by Nicholas Trienens on 10/26/23.
//

import Foundation

public extension JSON {
    var optional: Optional<JSON> {
        switch self {
        case .null: nil
        default: self
        }
    }

    func removingEmptyArrays() -> JSON {
        switch self {
        case let .array(arr):
            var newArray: [JSON] = []
            for value in arr {
                if case let .array(innerArray) = value, innerArray.isEmpty {
                    continue
                } else {
                    newArray.append(value.removingEmptyArrays())
                }
            }
            return .array(newArray)
        case let .object(obj):
            var newObject: [String: JSON] = [:]
            for (key, value) in obj {
                if case let .array(innerArray) = value, innerArray.isEmpty {
                    continue
                } else {
                    newObject[key] = value.removingEmptyArrays()
                }
            }
            return .object(newObject)
        default:
            return self
        }
    }
}

public extension [JSON] {
    func removingEmptyArrays() -> [JSON] {
        map { json -> JSON in
            return json.removingEmptyArrays()
        }
    }
}

public extension JSON {
    var fuzzyFloat: Double {
        switch self {
        case let .double(number):
            number

        default:
            0
        }
    }

    init(array: [JSON]) {
        self = .array(array)
    }
}

public extension [JSON] {
//
//    func removeKey(_ key: String) -> JSON {
//        var json = JSON(self)
//        json = json.removeKey(key)
//        return json
//    }

    func transformed(using mapping: [String: String]) -> [JSON] {
        map { jsonElement in
            jsonElement.transformed(using: mapping)
        }
    }
}

public extension JSON {
    @inlinable
    func map<T>(_ transform: (JSON) throws -> T) rethrows -> [T] {
        switch self {
        case let .array(jsonList):
            return try jsonList.map(transform)
        default: break
        }
        return []
    }

//    @inlinable
//    func map(_ transform: (JSON) throws -> some Any) rethrows -> JSON {
//        switch self {
//        case let .array(jsonList):
//            return try JSON(jsonList.map(transform))
//        default: break
//        }
//        return JSON([])
//    }

    func transformed(using mapping: [String: String]) -> JSON {
        switch self {
        case let .array(jsonList):
            return JSON(jsonList.transformed(using: mapping))
        default: break
        }

        var resultObject: [String: JSON] = [:]

        for (key, path) in mapping {
            var values: [JSON] = []

            let value = get(path.components(separatedBy: "."))
            if value.optional != nil {
                values.append(value)
            }
            if values.count == 1 {
                resultObject[key] = values[0]
            } else if values.count > 1 {
                resultObject[key] = JSON(values)
            }
        }
        return JSON(resultObject)
    }

    mutating func removingKey(_ key: String) {
        removeKey(key, from: &self)
    }

    func removeKey(_ key: String) -> JSON {
        var json = self
        removeKey(key, from: &json)
        return json
    }

    func removeKey(_ key: String, from json: inout JSON) {
        // If the JSON is an object, check each key
        if let object = json.asObject() {
            for currentKey in object.keys {
                // If the current key matches the key to remove, then remove it
                if currentKey == key {
                    json.remove([currentKey])
                } else {
                    // Otherwise, go deeper into the structure
                    var nestedJSON = json[currentKey]
                    removeKey(key, from: &nestedJSON)
                    json.set([currentKey], to: nestedJSON)
                }
            }
        }
        // If the JSON is an array, iterate over each element
        else if let array = json.asArray() {
            for (index, var item) in array.enumerated() {
                removeKey(key, from: &item)
                json.set([String(index)], to: item)
            }
        }
    }
}
