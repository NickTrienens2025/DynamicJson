import JSON
import XCTest

final class JSONTests: XCTestCase {

    func testGetSubscript() throws {
        let object: JSON = [
            "one": 1,
            "bool": true,
            "dict": [
                "key": "value"
            ],
        ]
        XCTAssertEqual("value", object["dict"]["key"].asString())
        XCTAssertTrue(object["one"].asInt() == Int(1))
        XCTAssertEqual(1, object["one"].asInt())
        XCTAssertFalse(object["one"] == "one")
        XCTAssertNotEqual("one", object["one"])
        XCTAssertTrue(object["bool"] == true)
        XCTAssertEqual(true, object["bool"])
        XCTAssertFalse(object["bool"] == 2.0)
        XCTAssertNotEqual(2.0, object["bool"])
        XCTAssertTrue(JSON(["key": "value"]) == object["dict"])
        XCTAssertFalse(JSON.array([.string("one"), .boolean(false)]) == object["dict"])
        XCTAssertEqual(object["doesNotExist"], JSON.null)
        XCTAssertEqual("value", object["dict"]["key"].asString())

        let array = JSON(["one", 2, false])
        XCTAssertTrue(array[0] == "one")
        XCTAssertEqual(array[1].asInt(), 2)
        XCTAssertTrue(array[2] == false)
        XCTAssertEqual(array[3], JSON.null )

        let string: JSON = .string("text")
        //        XCTAssertNil(string["text"] as JSON?)
        XCTAssertEqual(string["text"], JSON.null)
    }

    func testRemovals() throws {
        var object: JSON = [
            "one": 1,
            "bool": true,
            "dict": [
                "test": "value"
            ],
            "array": ["ine", "two", "three"],
        ]

        let g = JSON(
            object.array.map { j in
                var updatedJson: JSON = JSON(["test": j])
                return updatedJson
            })
        print(g.jsonString)

        let j = object.removeKey("test")
        print(j.jsonString)

        object.removingKey("test")
        print(object.jsonString)

    }

    func testSetSubscript() throws {
        var object: JSON = [
            "one": 1,
            "bool": true,
            "dict": [
                "key": "value"
            ],
        ]

        object["dict"]["key"] = 123
        XCTAssertEqual(JSON(["one": 1, "bool": true, "dict": ["key": 123]]), object)
        //        XCTAssertTrue(JSON(["one": 1, "bool": true, "dict": ["key": 123]]) == object)

        object["new"] = .null
        //        XCTAssertEqual(
        //            ["one": 1, "bool": true, "new": nil, "dict": ["key": 123]],
        //            object
        //        )

        var array: JSON = ["one", nil, 3.14, false]

        array[3] = true
        XCTAssertEqual(["one", nil, 3.14, true], array)

        array[1] = ["bingo", nil, 3]
        XCTAssertEqual(
            ["one", ["bingo", nil, 3] as [Any?], 3.14, true],
            array
        )
    }

    func testOptionalSpecializedValues() throws {
        let arr: JSON = JSON(["one", 123, 1.23])
        XCTAssertEqual(3, arr.asArray()?.count)
        XCTAssertEqual("one", arr[0].asString())
        XCTAssertEqual(123, arr[1].asInt())
        XCTAssertEqual(1.23, arr[2].asDouble())

        let dict: JSON = JSON(["one": "one", "two": 1.23])
        XCTAssertEqual(2, dict.asObject()?.count)
        XCTAssertEqual("one", dict["one"].asString())
        XCTAssertEqual(1.23, dict["two"].asDouble())
    }

    func testEquatable() throws {
        let arr = JSON(["one", 0, 123, 1.23])
        print(type(of: arr)) // Check its actual type
        print(type(of: JSON(["one"])))
//        XCTAssertTrue(arr == JSON(["one", 0, 123, 1.23]) )
//        XCTAssertEqual(arr, JSON(["one", 0, 123, 1.23]) )
//
//        XCTAssertTrue(JSON(["one", 0, 123, 1.23]) == arr)
        XCTAssertTrue(arr[0] == "one")
        XCTAssertTrue(arr[0] == "one")
        XCTAssertTrue(arr[2].asInt() == 123)
        XCTAssertTrue(arr[2].asInt() == 123)
        XCTAssertTrue(arr[3] == 1.23)
        XCTAssertTrue(arr[3] == 1.23)

        XCTAssertTrue(JSON.boolean(true) as JSON? == true)
        XCTAssertTrue(JSON.boolean(false) as JSON? == false)
        XCTAssertTrue(JSON.boolean(true) as JSON? == true)
        XCTAssertTrue(JSON.boolean(false) as JSON? == false)
        XCTAssertFalse(JSON.double(0) as JSON? == false)
        XCTAssertFalse(JSON.double(1) as JSON? == true)

        let dict: JSON = JSON(["one": "one", "two": 1.23])
        XCTAssertTrue(dict == JSON(["one": "one", "two": 1.23]))
        XCTAssertTrue(JSON(["one": "one", "two": 1.23]) == dict)
        XCTAssertTrue(dict["one"] == "one")
        XCTAssertTrue(dict["one"] == "one")
        XCTAssertTrue(dict["two"] == 1.23)
        XCTAssertTrue(dict["two"] == 1.23)

        XCTAssertTrue(JSON.double(3.14) as JSON? == 3.14)
        XCTAssertTrue(JSON.double(3.14) as JSON? == 3.14)
//        XCTAssertTrue(JSON.double(1234) as JSON? == 1234)

        XCTAssertTrue(JSON.string("boom") as JSON? == "boom")
        XCTAssertTrue(JSON.string("boom") as JSON? == "boom")
    }

    func testCodable() throws {
        let json: JSON = [
            "one": 2,
            "two_text": "two",
            "pi": 3.14,
            "yes": true,
            "null": nil,
            "object": [
                "three": 3,
                "four_text": "four",
                "null": JSON.null,
                "inner_array": [
                    "index_0",
                    false,
                    4.20,
                ]
            ]
        ]

        let encoded = try JSONEncoder().encode(json)
        let decoded = try JSONDecoder().decode(JSON.self, from: encoded)

        print(json.asJsonString())
        print(decoded.asJsonString())
        XCTAssertTrue(decoded.asObject() == json.asObject())
//        XCTAssertEqual(decoded.asObject(), json.asObject())
    }

    func testInitWithLiteralTypes() throws {
        XCTAssertEqual(
            JSON.array([.boolean(true), .double(3.14), .null]),
            [true, 3.14, nil]
        )

        XCTAssertEqual(JSON.boolean(false), false)
        XCTAssertEqual(JSON.boolean(true), true)

        XCTAssertEqual(
            JSON.object(["one": .integer(1), "two": .string("2")]),
            ["one": 1, "two": "2"]
        )

        XCTAssertEqual(JSON.double(3.14), 3.14)
        XCTAssertEqual(JSON.double(1234), 1234.0)

        XCTAssertEqual(JSON.null, nil)

        XCTAssertEqual(JSON.string("😊"), "😊")
    }

    func testInitWithMixedTypesIncludingJSON() throws {
        let mixed = [
            "one": 1,
            "two": 2.0,
            "a": "a",
            "b": JSON.string("b"),
            "array": [
                10, true, JSON.null, JSON.boolean(false),
            ],
            "json_array": JSON.array([
                .double(10), .boolean(true), .null, .boolean(false),
            ]),
            "dictionary": [
                "z": "Z",
                "true": JSON.boolean(true),
                "true2": true,
                "number": 123.0,
            ],
            "json_dictionary": JSON.object([
                "z": .string("Z"),
                "true": .boolean(true),
                "true2": .boolean(true),
                "number": .double(123.0),
            ]),
        ]

        let json = JSON(mixed)

        guard case let .object(dict) = json else {
            return XCTFail()
        }
        XCTAssertEqual(dict, mixed)
    }

    func testIsArray() throws {
        let array: JSON = ["one", 2, 3.0, true, nil]
        XCTAssertTrue(array.isArray())

        let object: JSON = ["one": 1, "two": 2, "three": 3]
        XCTAssertFalse(object.isArray())

        let string: JSON = "string"
        XCTAssertFalse(string.isArray())

        let number: JSON = 123
        XCTAssertFalse(number.isArray())

        let bool: JSON = true
        XCTAssertFalse(bool.isArray())

        let null: JSON = nil
        XCTAssertFalse(null.isArray())

    }

    func testIsObject() throws {
        let array: JSON = ["one", 2, 3.0, true, nil]
        XCTAssertFalse(array.isObject())

        let object: JSON = ["one": 1, "two": 2, "three": 3]
        XCTAssertTrue(object.isObject())

        let string: JSON = "string"
        XCTAssertFalse(string.isObject())

        let number: JSON = 123
        XCTAssertFalse(number.isObject())

        let bool: JSON = true
        XCTAssertFalse(bool.isObject())

        let null: JSON = nil
        XCTAssertFalse(null.isObject())

    }
}
