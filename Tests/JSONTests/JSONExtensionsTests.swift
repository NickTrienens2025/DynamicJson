import XCTest

@testable import JSON

final class JSONExtensionsTests: XCTestCase {
    func testOptional() {
        let nullJSON = JSON.null
        let numberJSON = JSON.double(42.0)

        XCTAssertNil(nullJSON.optional)
        XCTAssertNotNil(numberJSON.optional)
    }

    func testRemovingEmptyArrays() {
        // Test array with empty arrays
        let arrayJSON: JSON = [
            [],
            [1.0],
            2.0,
        ]
        let cleanedArray = arrayJSON.removingEmptyArrays()
        XCTAssertEqual(cleanedArray.asArray()?.count, 2)

        // Test object with empty arrays
        let objectJSON: JSON = [
            "empty": [],
            "nonEmpty": [1.0],
            "number": 2.0,
        ]
        let cleanedObject = objectJSON.removingEmptyArrays()
        XCTAssertEqual(cleanedObject.asObject()?.count, 2)
        XCTAssertNil(cleanedObject.asObject()?["empty"])
    }

    func testRemoveEmptyArraysDeep() {
        let jsonArray: JSON = [
            [],
            [1.0],
            ["empty": []],
        ]
        print(jsonArray.asJsonString())
        
        let cleaned = jsonArray.removingEmptyArrays()
        print(cleaned.asJsonString())
        XCTAssertEqual(cleaned.asArray()?.count, 2)
    }

    func testFuzzyFloat() {
        let doubleJSON = JSON.double(42.5)
        let stringJSON = JSON.string("not a number")

        XCTAssertEqual(doubleJSON.fuzzyFloat, 42.5)
        XCTAssertEqual(stringJSON.fuzzyFloat, 0.0)
    }

    func testArrayInitialization() {
        let array = [JSON.double(1.0), JSON.string("test")]
        let json = JSON(array: array)

        XCTAssertEqual(json.asArray()?.count, 2)
    }

    func testTransformed() {
        let originalJSON: JSON = [
            "name": "John",
            "age": 30,
        ]

        let mapping = [
            "fullName": "name",
            "years": "age",
        ]

        let transformed = originalJSON.transformed(using: mapping)

        XCTAssertEqual(transformed["fullName"].asString(), "John")
        XCTAssertEqual(transformed["years"].asDouble(), 30)
    }

    func testArrayTransformed() {
        let jsonArray: [JSON] = [
            ["name": "John"],
            ["name": "Jane"],
        ]

        let mapping = ["fullName": "name"]
        let transformed = jsonArray.transformed(using: mapping)

        XCTAssertEqual(transformed.count, 2)
        XCTAssertEqual(transformed[0]["fullName"].asString(), "John")
        XCTAssertEqual(transformed[1]["fullName"].asString(), "Jane")
    }

    func testMap() {
        let arrayJSON: JSON = [1.0, 2.0, 3.0]
        let doubles: [Double] = arrayJSON.map { $0.asDouble() ?? 0.0 }
        XCTAssertEqual(doubles, [1.0, 2.0, 3.0])

        let mapped = arrayJSON.map { $0.asDouble() ?? 0.0 }
        XCTAssertEqual(mapped.count, 3)
    }

    func testRemoveKey() {
        var json: JSON = [
            "keep": "value",
            "remove": "bye",
            "nested": [
                "remove": "nested bye",
                "keep": "nested value",
            ],
        ]

        json.removingKey("remove")

        XCTAssertNotNil(json["keep"].asString())
        XCTAssertNil(json["remove"].asString())
        XCTAssertNotNil(json["nested"]["keep"].asString())
        XCTAssertNil(json["nested"]["remove"].asString())
    }

    func testRemoveKeyInArray() {
        let json: JSON = [
            ["remove": "bye", "keep": "value"],
            ["remove": "bye", "keep": "value2"],
        ]

        let cleaned = json.removeKey("remove")

        XCTAssertEqual(cleaned.asArray()?.count, 2)
        XCTAssertNil(cleaned[0]["remove"].asString())
        XCTAssertNotNil(cleaned[0]["keep"].asString())
        XCTAssertNil(cleaned[1]["remove"].asString())
        XCTAssertNotNil(cleaned[1]["keep"].asString())
    }
}
