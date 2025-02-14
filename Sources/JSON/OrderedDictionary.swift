//
//  OrderedDictionary.swift
//  JSON
//
//  Created by Nick Trienens on 2/13/25.
//

public struct OrderedDictionary<Key: Hashable & Codable, Value: Codable>: Codable {
    private var keys: [Key] = []
    private var values: [Key: Value] = [:]

    public var count: Int {
        return keys.count
    }

    public var isEmpty: Bool {
        return keys.isEmpty
    }
    // MARK: - Initializer from Standard Dictionary
    public init(_ dictionary: [Key: Value]) {
        self.keys = Array(dictionary.keys) // Capture order at initialization
        self.values = dictionary
    }

    public init() {}
    
    public subscript(key: Key) -> Value? {
        get { values[key] }
        set {
            if let newValue = newValue {
                if values[key] == nil {
                    keys.append(key)  // Only add key if it's new
                }
                values[key] = newValue
            } else {
                removeValue(forKey: key)
            }
        }
    }

    public mutating func removeValue(forKey key: Key) {
        values[key] = nil
        keys.removeAll { $0 == key }
    }

    public func index(of key: Key) -> Int? {
        return keys.firstIndex(of: key)
    }

    public func value(at index: Int) -> Value? {
        let key = keys[index]
        return values[key]
    }

    public func key(at index: Int) -> Key {
        return keys[index]
    }

    // MARK: - Codable Conformance
    enum CodingKeys: String, CodingKey {
        case pairs
    }

    struct KeyValuePair: Codable {
        let key: Key
        let value: Value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pairs = try container.decode([KeyValuePair].self, forKey: .pairs)
        
        for pair in pairs {
            self[pair.key] = pair.value
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let pairs = keys.compactMap { key -> KeyValuePair? in
            guard let value = values[key] else { return nil }
            return KeyValuePair(key: key, value: value)
        }
        try container.encode(pairs, forKey: .pairs)
    }
}
