//
//  OrderedDictionaryTests.swift
//  JSON
//
//  Created by Nick Trienens on 2/13/25.
//

import JSON
import XCTest

final class OrderedDictionaryTests: XCTestCase {

    func testInitializationFromDictionary() {
        let dict: [String: Int] = ["apple": 10, "banana": 20, "cherry": 30]
        let orderedDict = OrderedDictionary(dict)

        // Order is not guaranteed in Swift dictionaries, but we check keys are present
        XCTAssertEqual(orderedDict.count, dict.count)
        XCTAssertTrue(dict.keys.allSatisfy { orderedDict[$0] != nil })
    }

    func testInsertionOrder() {
        var orderedDict = OrderedDictionary<String, Int>()
        orderedDict["apple"] = 10
        orderedDict["banana"] = 20
        orderedDict["cherry"] = 30

        XCTAssertEqual(orderedDict.key(at: 0), "apple")
        XCTAssertEqual(orderedDict.key(at: 1), "banana")
        XCTAssertEqual(orderedDict.key(at: 2), "cherry")

        XCTAssertEqual(orderedDict.value(at: 0), 10)
        XCTAssertEqual(orderedDict.value(at: 1), 20)
        XCTAssertEqual(orderedDict.value(at: 2), 30)
        
        XCTAssertEqual(orderedDict["apple"], 10)
        XCTAssertEqual(orderedDict["banana"], 20)
        XCTAssertEqual(orderedDict["cherry"], 30)
    }

    func testValueRetrieval() {
        var orderedDict = OrderedDictionary<String, String>()
        orderedDict["first"] = "Swift"
        orderedDict["second"] = "iOS"
        orderedDict["third"] = "XCTest"

        XCTAssertEqual(orderedDict["first"], "Swift")
        XCTAssertEqual(orderedDict["second"], "iOS")
        XCTAssertEqual(orderedDict["third"], "XCTest")
    }

    func testRemoval() {
        var orderedDict = OrderedDictionary<String, Int>()
        orderedDict["one"] = 1
        orderedDict["two"] = 2
        orderedDict["three"] = 3

        orderedDict.removeValue(forKey: "two")

        XCTAssertNil(orderedDict["two"])
        XCTAssertEqual(orderedDict.count, 2)
        XCTAssertEqual(orderedDict.key(at: 0), "one")
        XCTAssertEqual(orderedDict.key(at: 1), "three")
    }

    func testCodableConformance() throws {
        var orderedDict = OrderedDictionary<String, Int>()
        orderedDict["apple"] = 10
        orderedDict["banana"] = 20
        orderedDict["cherry"] = 30

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(orderedDict)

        let decoder = JSONDecoder()
        let decodedDict = try decoder.decode(OrderedDictionary<String, Int>.self, from: jsonData)

        XCTAssertEqual(decodedDict.count, orderedDict.count)
        XCTAssertEqual(decodedDict.key(at: 0), "apple")
        XCTAssertEqual(decodedDict.key(at: 1), "banana")
        XCTAssertEqual(decodedDict.key(at: 2), "cherry")

        XCTAssertEqual(decodedDict["apple"], 10)
        XCTAssertEqual(decodedDict["banana"], 20)
        XCTAssertEqual(decodedDict["cherry"], 30)
    }
}
