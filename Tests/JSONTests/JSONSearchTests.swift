import JSON
import XCTest

final class JSONSearchTests: XCTestCase {
    func testFindNodesWithKey() throws {
        let json = JSON.object([
            "name": .string("John"),
            "age": .integer(30),
            "address": .object([
                "street": .string("123 Main St"),
                "city": .string("name"), // same key as root level
                "zip": .integer(12_345),
            ]),
            "contacts": .array([
                .object(["name": .string("Alice"), "phone": .string("123-456-7890")]),
                .object(["name": .string("Bob"), "phone": .string("098-765-4321")]),
            ]),
        ])

        // Test finding all "name" nodes
        let nameNodes = json.findNodes(withKey: "name")
        XCTAssertEqual(nameNodes.count, 3)
        XCTAssertEqual(nameNodes[0].value, .string("John"))
        XCTAssertEqual(nameNodes[1].value, .string("Alice"))
        XCTAssertEqual(nameNodes[2].value, .string("Bob"))

        // Test paths are correct
        XCTAssertEqual(nameNodes[0].path, ["name"])
        XCTAssertEqual(nameNodes[1].path, ["contacts", "0", "name"])
        XCTAssertEqual(nameNodes[2].path, ["contacts", "1", "name"])

        // Test finding "phone" nodes
        let phoneNodes = json.findNodes(withKey: "phone")
        XCTAssertEqual(phoneNodes.count, 2)
        XCTAssertEqual(phoneNodes[0].value, .string("123-456-7890"))
        XCTAssertEqual(phoneNodes[1].value, .string("098-765-4321"))
    }

    func testFindFirstNode() throws {
        let json = JSON.object([
            "items": [
                ["id": 1, "value": 100],
                ["id": 2, "value": 200],
                ["id": 3, "value": 300],
            ],
            "metadata": [
                "total": 600,
            ],
        ])

        // Find first node where value > 150
        let firstLargeValue = json.findFirstNode { _, value in
            if let num = value.asInt() {
                return num > 150
            }
            return false
        }

        XCTAssertNotNil(firstLargeValue)
        XCTAssertEqual(firstLargeValue?.value, .integer(200))
        XCTAssertEqual(firstLargeValue?.path, ["items", "1", "value"])

        // Find first node with specific key and value
        let specificNode = json.findFirstNode { key, value in
            key == "id" && value == .integer(3)
        }

        XCTAssertNotNil(specificNode)
        XCTAssertEqual(specificNode?.value, .integer(3))
        XCTAssertEqual(specificNode?.path, ["items", "2", "id"])
    }

    func testFindNodes() throws {
        let json = JSON.object([
            "products": .array([
                .object(["price": .integer(10), "inStock": .boolean(true)]),
                .object(["price": .integer(20), "inStock": .boolean(false)]),
                .object(["price": .integer(30), "inStock": .boolean(true)]),
            ]),
            "stats": .object([
                "totalProducts": .integer(3),
                "inStock": .integer(2),
            ]),
        ])

        // Find all nodes with true values
        let inStockNodes = json.findNodes { _, value in
            value == .boolean(true)
        }

        XCTAssertEqual(inStockNodes.count, 2)
        XCTAssertEqual(inStockNodes[0].path, ["products", "0", "inStock"])
        XCTAssertEqual(inStockNodes[1].path, ["products", "2", "inStock"])

        // Find all price nodes above 15
        let highPriceNodes = json.findNodes { key, value in
            key == "price" && value.asInt() ?? 0 > 15
        }

        XCTAssertEqual(highPriceNodes.count, 2)
        XCTAssertEqual(highPriceNodes[0].value, .integer(20))
        XCTAssertEqual(highPriceNodes[1].value, .integer(30))
    }

    func testSearchEdgeCases() throws {
        // Test searching in leaf nodes
        let leafNode = JSON.string("test")
        XCTAssertTrue(leafNode.findNodes(withKey: "any").isEmpty)
        XCTAssertNil(leafNode.findFirstNode { _, _ in true })
        XCTAssertTrue(leafNode.findNodes { _, _ in true }.isEmpty)

        // Test searching in empty structures
        let emptyObject = JSON.object([:])
        XCTAssertTrue(emptyObject.findNodes(withKey: "any").isEmpty)

        let emptyArray = JSON.array([])
        XCTAssertTrue(emptyArray.findNodes(withKey: "any").isEmpty)

        // Test searching with non-existent key
        let json = JSON.object(["key": .string("value")])
        XCTAssertTrue(json.findNodes(withKey: "nonexistent").isEmpty)

        // Test parent references
        let nested = JSON.object([
            "parent": .object([
                "child": .string("value"),
            ]),
        ])

        let childNodes = nested.findNodes(withKey: "child")
        XCTAssertEqual(childNodes.count, 1)
        XCTAssertNotNil(childNodes[0].parent)
        XCTAssertEqual(childNodes[0].parent?["child"], .string("value"))
    }
}
