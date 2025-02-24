//
//  JSON+Search.swift
//
//
//  Created by Nicholas Trienens on 8/7/23.
//

import Foundation

public struct JSONNodeWithPath {
    public let path: [String]
    public let value: JSON
    public let parent: JSON?
}

public extension JSON {
    func findNodes(
        withKey key: String,
        path: [String] = [],
        parent _: JSON? = nil
    ) -> [JSONNodeWithPath] {
        var results: [JSONNodeWithPath] = []
        switch self {
        case .null, .boolean, .string, .double, .integer:
            break // leaf node, no children
        case let .array(array):
            for (index, child) in array.enumerated() {
                let childPath = path + [String(index)]
                let childResults = child.findNodes(withKey: key, path: childPath, parent: self)
                results.append(contentsOf: childResults)
            }
        case let .object(object):
            for (childKey, child) in object {
                let childPath = path + [childKey]
                if childKey == key {
                    let matchingNode = JSONNodeWithPath(
                        path: childPath,
                        value: child,
                        parent: self
                    )
                    results.append(matchingNode)
                }
                let childResults = child.findNodes(withKey: key, path: childPath, parent: self)
                results.append(contentsOf: childResults)
            }
        }
        return results
    }

    func findFirstNode(
        include: (String?, JSON) -> Bool,
        path: [String] = [],
        parent _: JSON? = nil
    ) -> JSONNodeWithPath? {
        switch self {
        case .null, .boolean, .string, .double, .integer:
            break // leaf node, no children
        case let .array(array):
            for (index, child) in array.enumerated() {
                let childPath = path + [String(index)]
                if include(nil, child) {
                    return JSONNodeWithPath(path: childPath, value: child, parent: self)
                }
                if let childResult = child.findFirstNode(
                    include: include,
                    path: childPath,
                    parent: self
                ) {
                    return childResult
                }
            }
        case let .object(object):
            for (childKey, child) in object {
                let childPath = path + [childKey]
                if include(childKey, child) {
                    return JSONNodeWithPath(path: childPath, value: child, parent: self)
                }
                if let childResult = child.findFirstNode(
                    include: include,
                    path: childPath,
                    parent: self
                ) {
                    return childResult
                }
            }
        }
        return nil
    }

    func findNodes(
        include: (String?, JSON) -> Bool,
        path: [String] = [],
        parent _: JSON? = nil
    ) -> [JSONNodeWithPath] {
        var results: [JSONNodeWithPath] = []
        switch self {
        case .null, .boolean, .string, .double, .integer:
            break // leaf node, no children
        case let .array(array):
            for (index, child) in array.enumerated() {
                let childPath = path + [String(index)]
                if include(nil, child) {
                    let matchingNode = JSONNodeWithPath(
                        path: childPath,
                        value: child,
                        parent: self
                    )
                    results.append(matchingNode)
                }
                let childResults = child.findNodes(
                    include: include,
                    path: childPath,
                    parent: self
                )
                results.append(contentsOf: childResults)
            }
        case let .object(object):
            for (childKey, child) in object {
                let childPath = path + [childKey]
                if include(childKey, child) {
                    let matchingNode = JSONNodeWithPath(
                        path: childPath,
                        value: child,
                        parent: self
                    )
                    results.append(matchingNode)
                }
                let childResults = child.findNodes(
                    include: include,
                    path: childPath,
                    parent: self
                )
                results.append(contentsOf: childResults)
            }
        }
        return results
    }
}
