import JSON
import XCTest

final class JSONSetTests: XCTestCase {
    func testSetWithPath() {
        var json: JSON = [
            "user": [
                "name": "John",
                "age": 30,
                "address": [
                    "city": "New York"
                ],
            ]
        ]

        // Test setting nested value with path
        json.set(["user", "address", "country"], to: "USA")
        XCTAssertEqual(json["user"]["address"]["country"].stringValue, "USA")

        // Test setting value that creates new nested structure
        json.set(["company", "name"], to: "Apple")
        XCTAssertEqual(json["company"]["name"].stringValue, "Apple")

        // Test overwriting existing value
        json.set(["user", "name"], to: "Jane")
        XCTAssertEqual(json["user"]["name"].stringValue, "Jane")

        // Test setting array
        json.set(["scores"], to: [100, 85, 95])
        XCTAssertEqual(json["scores"].arrayValue?.count, 3)
        XCTAssertEqual(json["scores"][0].integerValue, 100)
        XCTAssertEqual(json["scores"][2].integerValue, 95)
    }

    func testSetWithDynamicMemberLookup() {
        var json: JSON = [
            "user": [
                "profile": [
                    "name": "John"
                ]
            ]
        ]

        // Test setting with subscript
        json["user"]["profile"]["name"] = "Jane"
        XCTAssertEqual(json["user"]["profile"]["name"].stringValue, "Jane")

        // Test creating new nested structure
        json["user"]["settings"] = ["theme": "dark"]
        XCTAssertEqual(json["user"]["settings"]["theme"].stringValue, "dark")

        // Test setting array values
        json["user"]["scores"] = [90, 85, 95]
        XCTAssertEqual(json["user"]["scores"][0].integerValue, 90)
        XCTAssertEqual(json["user"]["scores"][1].integerValue, 85)
        XCTAssertEqual(json["user"]["scores"][2].integerValue, 95)
    }

    func testSetWithSubscript() {
        var json: JSON = [
            "config": [
                "version": 1,
                "features": ["a", "b", "c"],
            ]
        ]

        // Test setting object values
        json["config"]["version"] = 2
        XCTAssertEqual(json["config"]["version"].integerValue, 2)

        // Test setting array values
        json["config"]["features"][1] = "updated"
        XCTAssertEqual(json["config"]["features"][1].stringValue, "updated")

        // Test setting new key in existing object
        print(json["config"])
        
        json["config"]["features"] = .null
        
        json["config"]["newKey"] = true
        print(json.config.newKey.boolValue)
        print(json["config"]["newKey"].asBool())
        print(json.jsonString)
        if let value: Bool = json["config"]["newKey"].asBool() {
            XCTAssertEqual(value, true)
        }
        XCTAssertEqual(json.config.newKey.asBool(), true)

        // Test setting nested object
        json["config"]["database"] = ["host": "localhost", "port": 5432]
        XCTAssertEqual(json["config"]["database"]["host"].stringValue, "localhost")
        XCTAssertEqual(json["config"]["database"]["port"].integerValue, 5432)
    }

    func testSetEdgeCases() {
        var json: JSON = .null

        // Test setting on null JSON
        json.set(["key"], to: "value")
        XCTAssertEqual(json["key"].stringValue, "value")

        // Test setting on primitive value
        var primitiveJson: JSON = "string"
        primitiveJson.set(["key"], to: "value")
        XCTAssertEqual(primitiveJson["key"].stringValue, "value")

        // Test setting empty path
        var emptyPathJson: JSON = ["existing": "value"]
        emptyPathJson.set([], to: ["new": "value"])
        XCTAssertEqual(emptyPathJson["new"].stringValue, "value")

        // Test setting various JSON types
        var typesJson: JSON = [:]
        typesJson.set(["string"], to: "text")
        typesJson.set(["number"], to: 42)
        typesJson.set(["boolean"], to: true)
        typesJson.set(["null"], to: .null)
        typesJson.set(["array"], to: [1, 2, 3])
        typesJson.set(["object"], to: ["key": "value"])

        XCTAssertEqual(typesJson["string"].stringValue, "text")
        XCTAssertEqual(typesJson["number"].integerValue, 42)
        XCTAssertEqual(typesJson["boolean"].boolValue, true)
        XCTAssertEqual(typesJson["null"], .null)
        XCTAssertEqual(typesJson["array"][0].integerValue, 1)
        XCTAssertEqual(typesJson["object"]["key"].stringValue, "value")
    }
}
