import JSON
import XCTest

final class DictionaryJSONTests: XCTestCase {
    func testEquality() throws {
        let original: [String: JSON] = [
            "one": 1.4,
            "oneoh": 1.0,
            "tru": true,
        ]
        let original2: [String: JSON] = [
            "one": 1.4,
            "oneoh": 1.0,
            "tru": true,
        ]
        XCTAssertEqual(JSON(original).asJsonString(), JSON(original2).asJsonString())

        XCTAssertTrue(original == original2)

        XCTAssertEqual(original, original2)
    }

    func testValueForKey() throws {
        let original: [String: JSON] = [
            "one": 1,
            "oneoh": 1.0,
            "onenum": 1.001,
            "pie": 3.14,
            "tru": true,
//            "fals": [false, true],
        ]
        let original2: [String: JSON] = [
            "one": 1,
            "oneoh": 1.0,
            "onenum": 1.001,
            "pie": 3.14,
            "tru": true,
            //            "fals": [false, true],
        ]
        var json = JSON(original)
        XCTAssertEqual(original, original2)
        XCTAssertEqual(JSON(original).asJsonString(), json.asJsonString())
//        let dict = try XCTUnwrap(json.dictionaryValue)
        print(json.asJsonString())

        json.two = 2
        print(json["two"])
        print(json.two)
        json.two = JSON(original)

        print(json.two)
        print(json.fals.1)
        print(json.jsonString)

        XCTAssertEqual(1, json["one"].asInt())
        XCTAssertEqual(1, json["oneoh"].asInt())
        XCTAssertEqual(1, json["onenum"].asInt())
        XCTAssertEqual(3.14, json["pie"].asDouble())
    }
}
