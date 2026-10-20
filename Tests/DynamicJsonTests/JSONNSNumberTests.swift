import XCTest

@testable import DynamicJson

final class JSONNSNumberTests: XCTestCase {
    func testNSNumberIntegersStayIntegers() {
        XCTAssertEqual(JSON(["v": NSNumber(value: 0)]).v, .integer(0))
        XCTAssertEqual(JSON(["v": NSNumber(value: 1)]).v, .integer(1))
        XCTAssertEqual(JSON(["v": NSNumber(value: 2)]).v, .integer(2))
        XCTAssertEqual(JSON(["v": NSNumber(value: -7)]).v, .integer(-7))
    }

    func testNSNumberBooleansStayBooleans() {
        XCTAssertEqual(JSON(["v": NSNumber(value: true)]).v, .boolean(true))
        XCTAssertEqual(JSON(["v": NSNumber(value: false)]).v, .boolean(false))
    }

    func testNSNumberFloatsStayDoubles() {
        XCTAssertEqual(JSON(["v": NSNumber(value: 2.5)]).v, .double(2.5))
        XCTAssertEqual(JSON(["v": NSNumber(value: Float(1.5))]).v, .double(1.5))
    }

    func testSwiftValuesAreUnchanged() {
        let json = JSON(["int": 1, "zero": 0, "double": 2.5, "bool": true] as [String: Any])
        XCTAssertEqual(json.int, .integer(1))
        XCTAssertEqual(json.zero, .integer(0))
        XCTAssertEqual(json.double, .double(2.5))
        XCTAssertEqual(json.bool, .boolean(true))
    }

    func testJSONSerializationMatchesJSONDecoder() throws {
        let text = #"{"one":1,"zero":0,"two":2,"half":0.5,"t":true,"f":false,"list":[1,0,true]}"#
        let serialized = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(text.utf8)) as? [String: Any]
        )
        XCTAssertEqual(JSON(serialized), try JSON(jsonString: text))
    }
}
