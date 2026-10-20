import XCTest

@testable import DynamicJson

final class JSONFoundationConversionTests: XCTestCase {
    private let json: JSON = [
        "name": "CGY",
        "count": 3,
        "ratio": 1.5,
        "active": true,
        "tags": ["a", "b"],
        "nested": ["key": "value"],
        "missing": nil,
    ]

    func testAsDictionaryConvertsEveryCase() throws {
        let dictionary = try XCTUnwrap(json.asDictionary())

        XCTAssertEqual(dictionary["name"] as? String, "CGY")
        XCTAssertEqual(dictionary["count"] as? Int, 3)
        XCTAssertEqual(dictionary["ratio"] as? Double, 1.5)
        XCTAssertEqual(dictionary["active"] as? Bool, true)
        XCTAssertEqual(dictionary["tags"] as? [String], ["a", "b"])
        XCTAssertEqual((dictionary["nested"] as? [String: Any])?["key"] as? String, "value")
        XCTAssertTrue(dictionary["missing"] is NSNull)
    }

    func testAsDictionaryIsNilForNonObjects() {
        XCTAssertNil(JSON.string("x").asDictionary())
        XCTAssertNil(JSON.null.asDictionary())
        XCTAssertNil(JSON.array([]).asDictionary())
    }

    func testAsAnyIsValidForJSONSerialization() {
        XCTAssertTrue(JSONSerialization.isValidJSONObject(json.asAny()))
    }

    func testAsAnyRoundTripsThroughDictionaryInit() throws {
        let dictionary = try XCTUnwrap(json.asDictionary())
        XCTAssertEqual(JSON(dictionary), json)
    }
}
