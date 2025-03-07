//
//  JSONTests+ResultBuilder.swift
//  JSON
//
//  Created by Nick Trienens on 1/19/25.
//

import JSON
import XCTest

final class ResultBuilderJSONTests: XCTestCase {
    func testBasicValues() throws {
        let json = JSON {
            "string value"
            42
            3.14
            true
        }

        XCTAssertEqual(json[0].asString(), "string value")
        XCTAssertEqual(json[1].asDouble(), 42.0)
        XCTAssertEqual(json[2].asDouble(), 3.14)
        XCTAssertEqual(json[3].asBool(), true)
    }

    func testObjectCreation() throws {
        let json = JSON {
            ["string": "value"]
            ["int": 42]
            ["double": 3.14]
            ["bool": true]
            ["float": 1.23]
        }

        XCTAssertEqual(json[0]["string"].asString(), "value")
        XCTAssertEqual(json[1]["int"].asDouble(), 42.0)
        XCTAssertEqual(json[2]["double"].asDouble(), 3.14)
        XCTAssertEqual(json[3]["bool"].asBool(), true)
        XCTAssertEqual(json[4]["float"].asDouble(), 1.23)
    }

    func testArrayCreation() throws {
        let json = JSON {
            "first"
            "second"
            "third"
        }

        XCTAssertTrue(json.isArray())
        let array = json.asArray()
        XCTAssertEqual(array?.count, 3)
        XCTAssertEqual(array?[0].asString(), "first")
        XCTAssertEqual(array?[1].asString(), "second")
        XCTAssertEqual(array?[2].asString(), "third")
    }

    func testNestedStructures() throws {
        let json = JSON {
            [
                "outer": [
                    "inner": "value",
                    "array": JSON {
                        "item1"
                        "item2"
                    },
                ],
            ]
        }

        XCTAssertEqual(json["outer"]["inner"].asString(), "value")
        XCTAssertEqual(json["outer"]["array"][0].asString(), "item1")
        XCTAssertEqual(json["outer"]["array"][1].asString(), "item2")
        XCTAssertNil(json["outer"]["array"][3].asString())
    }

    func testOptionalHandling() throws {
        let includeOptional = true
        let json = JSON {
            if includeOptional {
                "included"
            }
        }

        XCTAssertEqual(json.asString(), "included")

        let json2 = JSON {
            if !includeOptional {
                "not included"
            }
        }

        XCTAssertEqual(json2, .null)
    }

    func testConditionalBuilding() throws {
        let condition = true
        let json = JSON {
            if condition {
                "true case"
            } else {
                "false case"
            }
        }

        XCTAssertEqual(json.asString(), "true case")
    }

    func testDictionaryInitialization() throws {
        let stringDict = ["key": "value"]
        let intDict = ["key": 42]
        let doubleDict = ["key": 3.14]
        let boolDict = ["key": true]

        let json = JSON {
            stringDict
            intDict
            doubleDict
            boolDict
        }

        XCTAssertEqual(json[0]["key"].asString(), "value")
        XCTAssertEqual(json[1]["key"].asDouble(), 42.0)
        XCTAssertEqual(json[2]["key"].asDouble(), 3.14)
        XCTAssertEqual(json[3]["key"].asBool(), true)
    }

    func testGlobalJsonFunction() throws {
        let result = json {
            ["key": "value"]
        }

        XCTAssertEqual(result["key"].asString(), "value")

        // Test throwing version
        let throwingResult = json {
            ["key": "value"]
        }

        XCTAssertEqual(throwingResult["key"].asString(), "value")
    }
}
