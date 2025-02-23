import JSON
import XCTest

final class DictionaryJSONTests: XCTestCase {
    func testValueForKey() throws {
        let original: [String: JSON] = [
            "one": 1,
            "oneoh": 1.0,
            "onenum": 1.001,
            "pie": 3.14,
            "tru": true,
            "fals": [false, true],
        ]

        var json = JSON(original)
//        let dict = try XCTUnwrap(json.dictionaryValue)
//        print(json.one)
        
        json.two = 2
        print(json["two"])
        print(json.two)
        json.two = JSON(original)
        
        print(json.two)
        print(json.fals.1)
        print(json.jsonString)
        
        XCTAssertEqual(1, json["one"].integerValue)
        XCTAssertEqual(1, json["oneoh"].integerValue)
        XCTAssertEqual(1, json["onenum"].integerValue)
        XCTAssertEqual(3.14, json["pie"].doubleValue)

        
        
    }
}
