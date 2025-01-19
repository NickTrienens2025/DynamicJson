//
//  JSON+findNodes.swift
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
    
    func findNodes(forKey key: String, path: [String] = [], parent: JSON? = nil) -> [JSONNodeWithPath] {
        var results: [JSONNodeWithPath] = []
        switch self {
        case .null, .boolean, .string, .number:
            break // leaf node, no children
        case .array(let array):
            for (index, child) in array.enumerated() {
                let childPath = path + [String(index)]
                let childResults = child.findNodes(forKey: key, path: childPath, parent: self)
                results.append(contentsOf: childResults)
            }
        case .dictionary(let object):
            for (childKey, child) in object {
                let childPath = path + [childKey]
                if childKey == key {
                    let matchingNode = JSONNodeWithPath(path: childPath, value: child, parent: self)
                    results.append(matchingNode)
                }
                let childResults = child.findNodes(forKey: key, path: childPath, parent: self)
                results.append(contentsOf: childResults)
            }
        }
        return results
    }
    
    func findFirstNode(include: (String?, JSON) -> Bool, path: [String] = [], parent: JSON? = nil) -> JSONNodeWithPath? {
        switch self {
        case .null, .boolean, .string, .number:
            break // leaf node, no children
        case .array(let array):
            for (index, child) in array.enumerated() {
                let childPath = path + [String(index)]
                if include(nil, child) {
                    return JSONNodeWithPath(path: childPath, value: child, parent: self)
                }
                if let childResult = child.findFirstNode(include: include, path: childPath, parent: self) {
                    return childResult
                }
            }
        case .dictionary(let object):
            for (childKey, child) in object {
                let childPath = path + [childKey]
                if include(childKey, child) {
                    return JSONNodeWithPath(path: childPath, value: child, parent: self)
                }
                if let childResult = child.findFirstNode(include: include, path: childPath, parent: self) {
                    return childResult
                }
            }
        }
        return nil
    }

        
    func findNodes(include: (String?, JSON) -> Bool, path: [String] = [], parent: JSON? = nil) -> [JSONNodeWithPath] {
        var results: [JSONNodeWithPath] = []
        switch self {
        case .null, .boolean, .string, .number:
            break // leaf node, no children
        case .array(let array):
            for (index, child) in array.enumerated() {
                let childPath = path + [String(index)]
                if include(nil, child) {
                    let matchingNode = JSONNodeWithPath(path: childPath, value: child, parent: self)
                    results.append(matchingNode)
                }
                let childResults = child.findNodes(include: include, path: childPath, parent: self)
                results.append(contentsOf: childResults)
            }
        case .dictionary(let object):
            for (childKey, child) in object {
                let childPath = path + [childKey]
                if include(childKey, child) {
                    let matchingNode = JSONNodeWithPath(path: childPath, value: child, parent: self)
                    results.append(matchingNode)
                }
                let childResults = child.findNodes(include: include, path: childPath, parent: self)
                results.append(contentsOf: childResults)
            }
        }
        return results
    }
}

