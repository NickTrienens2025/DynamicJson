import JSON
import XCTest

final class JSONSetTests: XCTestCase {
    func testSetWithPath() {
        var json: JSON = [
            "user": [
                "name": "John",
                "age": 30,
                "address": [
                    "city": "New York",
                ],
            ],
        ]

        // Test setting nested value with path
        json.set(["user", "address", "country"], to: "USA")
        XCTAssertEqual(json["user"]["address"]["country"].asString(), "USA")

        // Test setting value that creates new nested structure
        json.set(["company", "name"], to: "Apple")
        XCTAssertEqual(json["company"]["name"].asString(), "Apple")

        // Test overwriting existing value
        json.set(["user", "name"], to: "Jane")
        XCTAssertEqual(json["user"]["name"].asString(), "Jane")

        // Test setting array
        json.set(["scores"], to: [100, 85, 95])
        XCTAssertEqual(json["scores"].asArray()?.count, 3)
        XCTAssertEqual(json["scores"][0].asInt(), 100)
        XCTAssertEqual(json["scores"][2].asInt(), 95)
    }

    func testSetWithDynamicMemberLookup() {
        var json: JSON = [
            "user": [
                "profile": [
                    "name": "John",
                ],
            ],
        ]

        // Test setting with subscript
        json["user"]["profile"]["name"] = "Jane"
        XCTAssertEqual(json["user"]["profile"]["name"].asString(), "Jane")

        // Test creating new nested structure
        json["user"]["settings"] = ["theme": "dark"]
        XCTAssertEqual(json["user"]["settings"]["theme"].asString(), "dark")

        // Test setting array values
        json["user"]["scores"] = [90, 85, 95]
        XCTAssertEqual(json["user"]["scores"][0].asInt(), 90)
        XCTAssertEqual(json["user"]["scores"][1].asInt(), 85)
        XCTAssertEqual(json["user"]["scores"][2].asInt(), 95)
    }

    func testSetWithSubscript() {
        var json: JSON = [
            "config": [
                "version": 1,
                "features": ["a", "b", "c"],
            ],
        ]

        // Test setting object values
        json["config"]["version"] = 2
        XCTAssertEqual(json["config"]["version"].asInt(), 2)

        // Test setting array values
        json["config"]["features"][1] = "updated"
        XCTAssertEqual(json["config"]["features"][1].asString(), "updated")

        // Test setting new key in existing object
        json["config"]["features"] = .null

        json["config"]["newKey"] = true
        
        if let value: Bool = json["config"]["newKey"].asBool() {
            XCTAssertEqual(value, true)
        }
        XCTAssertEqual(json.config.newKey.asBool(), true)

        // Test setting nested object
        json["config"]["database"] = ["host": "localhost", "port": 5432]
        XCTAssertEqual(json["config"]["database"]["host"].asString(), "localhost")
        XCTAssertEqual(json["config"]["database"]["port"].asInt(), 5432)
    }

    func testSetEdgeCases() {
        var json: JSON = .null

        // Test setting on null JSON
        json.set(["key"], to: "value")
        XCTAssertEqual(json["key"].asString(), "value")

        // Test setting on primitive value
        var primitiveJson: JSON = "string"
        primitiveJson.set(["key"], to: "value")
        XCTAssertEqual(primitiveJson["key"].asString(), "value")

        // Test setting empty path
        var emptyPathJson: JSON = ["existing": "value"]
        emptyPathJson.set([], to: ["new": "value"])
        XCTAssertEqual(emptyPathJson["new"].asString(), "value")

        // Test setting various JSON types
        var typesJson: JSON = [:]
        typesJson.set(["string"], to: "text")
        typesJson.set(["number"], to: 42)
        typesJson.set(["boolean"], to: true)
        typesJson.set(["null"], to: .null)
        typesJson.set(["array"], to: [1, 2, 3])
        typesJson.set(["object"], to: ["key": "value"])

        XCTAssertEqual(typesJson["string"].asString(), "text")
        XCTAssertEqual(typesJson["number"].asInt(), 42)
        XCTAssertEqual(typesJson["boolean"].asBool(), true)
        XCTAssertEqual(typesJson["null"], .null)
        XCTAssertEqual(typesJson["array"][0].asInt(), 1)
        XCTAssertEqual(typesJson["object"]["key"].asString(), "value")
    }
}
