//
//  JSONRemove.swift
//  JSON
//
//  Created by Nick Trienens on 2/22/25.
//

import JSON
import XCTest

final class JSONRemoveTests: XCTestCase {
    func testRemoveTopLevelKey() {
        var json: JSON = ["name": "John", "age": 30]
        json.remove(["name"])

        XCTAssertEqual(json.asObject()?.count, 1)
        XCTAssertEqual(json["name"], JSON.null)
        
        XCTAssertEqual(json.age.asInt(), 30)
        XCTAssertEqual(json["age"].asInt(), 30)
    }

    func testRemoveNestedKey() {
        var json: JSON = [
            "user": [
                "profile": [
                    "name": "John",
                    "email": "john@example.com",
                ]
            ]
        ]

        json.remove(["user", "profile", "email"])

        print( json.jsonString)
        
        XCTAssertNotNil(json["user"]["profile"])
        XCTAssertEqual(json["user"]["profile"]["name"].asString(), "John")
        XCTAssertEqual(json["user"]["profile"]["email"], JSON.null)
    }

    func testRemoveFromNonObject() {
        var json: JSON = .array([1, 2, 3])
        json.remove(["key"])

        XCTAssertTrue(json.isArray())
        XCTAssertEqual(json.asArray()?.count, 3)

        json = json.removeKey("0")

        XCTAssertTrue(json.isArray())
        XCTAssertEqual(json.asArray()?.count, 3)
    }

    func testRemoveWithEmptyPath() {
        var json: JSON = ["name": "John"]
        json.remove([])

        XCTAssertEqual(json["name"].asString(), "John")
    }

    func testRemoveNonExistentKey() {
        var json: JSON = ["name": "John"]
        json.remove(["age"])

        XCTAssertEqual(json.asObject()?.count, 1)
        XCTAssertEqual(json["name"].asString(), "John")
    }

    func testRemoveFromNullValue() {
        var json: JSON = .null
        json.remove(["key"])

        XCTAssertEqual(json, .null)
    }

    func testRemoveNestedNonExistentPath() {
        var json: JSON = [
            "user": [
                "name": "John"
            ]
        ]

        json.remove(["user", "profile", "email"])

        XCTAssertEqual(json["user"]["name"].asString(), "John")
        XCTAssertEqual(json.asObject()?.count, 1)
    }

    func testRemoveAllNestedContent() {
        var json: JSON = [
            "user": [
                "profile": [
                    "name": "John",
                    "email": "john@example.com",
                ]
            ]
        ]

        json.remove(["user", "profile"])

        XCTAssertNotNil(json["user"])
        XCTAssertEqual(json["user"]["profile"], JSON.null)
    }
}
