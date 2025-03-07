import XCTest
@testable import JSON

final class JSONComparableTests: XCTestCase {
    // MARK: - String Tests
    func testStringComparison() {
        // Test string ordering
        XCTAssertLessThan(JSON.string("a"), JSON.string("b"))
        XCTAssertLessThan(JSON.string("hello"), JSON.string("world"))
        XCTAssertFalse(JSON.string("z") < JSON.string("a"))
        
        // Test equality
        XCTAssertEqual(JSON.string("test"), JSON.string("test"))
    }
    
    // MARK: - Number Tests
    func testNumberComparison() {
        // Test integer ordering
        XCTAssertLessThan(JSON.integer(1), JSON.integer(2))
        XCTAssertFalse(JSON.integer(5) < JSON.integer(3))
        XCTAssertEqual(JSON.integer(42), JSON.integer(42))
        
        // Test double ordering
        XCTAssertLessThan(JSON.double(1.5), JSON.double(2.5))
        XCTAssertFalse(JSON.double(3.14) < JSON.double(2.71))
        XCTAssertEqual(JSON.double(3.14), JSON.double(3.14))
    }
    
    // MARK: - Boolean Tests
    func testBooleanComparison() {
        // Test boolean ordering (false < true)
        XCTAssertLessThan(JSON.boolean(false), JSON.boolean(true))
        XCTAssertFalse(JSON.boolean(true) < JSON.boolean(false))
        XCTAssertEqual(JSON.boolean(true), JSON.boolean(true))
        XCTAssertEqual(JSON.boolean(false), JSON.boolean(false))
    }
    
    // MARK: - Array Tests
    func testArrayComparison() {
        // Test empty arrays
        XCTAssertEqual(JSON.array([]), JSON.array([]))
        
        // Test arrays with same length
        let arr1: JSON = [1, 2, 3]
        let arr2: JSON = [1, 2, 4]
        XCTAssertLessThan(arr1, arr2)
        
        // Test arrays with different lengths
        let arr3: JSON = [1, 2]
        let arr4: JSON = [1, 2, 3]
        XCTAssertLessThan(arr3, arr4)
        
        // Test nested arrays
        let nested1: JSON = [[1], [2]]
        let nested2: JSON = [[1], [3]]
        XCTAssertLessThan(nested1, nested2)
    }
    
    // MARK: - Object Tests
    func testObjectComparison() {
        // Test empty objects
        XCTAssertEqual(JSON.object([:]), JSON.object([:]))
        
        // Test objects with same keys
        let obj1: JSON = ["a": 1, "b": 2]
        let obj2: JSON = ["a": 1, "b": 3]
        XCTAssertLessThan(obj1, obj2)
        
        // Test objects with different keys
        let obj3: JSON = ["a": 1]
        let obj4: JSON = ["b": 1]
        XCTAssertLessThan(obj3, obj4) // "a" < "b"
        
        // Test nested objects
        let nested1: JSON = ["outer": ["inner": 1]]
        let nested2: JSON = ["outer": ["inner": 2]]
        XCTAssertLessThan(nested1, nested2)
    }
    
    // MARK: - Null Tests
    func testNullComparison() {
        // Test null equality
        XCTAssertEqual(JSON.null, JSON.null)
        
        // Test null is not less than itself
        XCTAssertFalse(JSON.null < JSON.null)
    }
    
    // MARK: - String to Number Conversion Tests
    func testStringToNumberConversion() {
        // Test string to integer conversions
        XCTAssertLessThan(JSON.string("5"), JSON.integer(10))
        XCTAssertLessThan(JSON.integer(5), JSON.string("10"))
        XCTAssertFalse(JSON.string("20") < JSON.integer(10))
        XCTAssertFalse(JSON.integer(20) < JSON.string("10"))
        
        // Test string to double conversions
        XCTAssertLessThan(JSON.string("3.14"), JSON.double(3.15))
        XCTAssertLessThan(JSON.double(3.14), JSON.string("3.15"))
        XCTAssertFalse(JSON.string("3.16") < JSON.double(3.15))
        XCTAssertFalse(JSON.double(3.16) < JSON.string("3.15"))
        
        // Test non-numeric strings (should fall back to string comparison)
        XCTAssertLessThan(JSON.string("abc"), JSON.integer(123))
        XCTAssertLessThan(JSON.string("abc"), JSON.double(123.45))
        XCTAssertFalse(JSON.string("123") > JSON.double(123.45))
        
        // Test integer and double comparisons
        XCTAssertLessThan(JSON.integer(3), JSON.double(3.14))
        XCTAssertFalse(JSON.integer(4) < JSON.double(3.14))
        XCTAssertLessThan(JSON.double(3.14), JSON.integer(4))
        XCTAssertFalse(JSON.double(4.14) < JSON.integer(4))
        
        // Test equality cases
        XCTAssertEqual(JSON.string("42"), JSON.integer(42))
        XCTAssertEqual(JSON.string("3.14"), JSON.double(3.14))
        XCTAssertEqual(JSON.integer(3), JSON.double(3.0))
        
        // Test non-equality cases
        XCTAssertNotEqual(JSON.string("abc"), JSON.integer(42))
        XCTAssertNotEqual(JSON.string("abc"), JSON.double(3.14))
        XCTAssertNotEqual(JSON.string("42.0"), JSON.integer(42)) // Integer won't parse decimal string
        XCTAssertNotEqual(JSON.string("3.14"), JSON.integer(3)) // Integer won't parse decimal string
        
        // Test edge cases
        XCTAssertEqual(JSON.string("0"), JSON.integer(0))
        XCTAssertEqual(JSON.string("0.0"), JSON.double(0.0))
        XCTAssertEqual(JSON.string("-42"), JSON.integer(-42))
        XCTAssertEqual(JSON.string("-3.14"), JSON.double(-3.14))
        
        // Test that string representation doesn't affect equality
        XCTAssertEqual(JSON.string("42.0"), JSON.double(42.0))
        XCTAssertEqual(JSON.string("42."), JSON.double(42.0))
        XCTAssertEqual(JSON.string(".0"), JSON.double(0.0))
        
        // Test that whitespace affects equality
        XCTAssertNotEqual(JSON.string(" 42"), JSON.integer(42))
        XCTAssertNotEqual(JSON.string("42 "), JSON.integer(42))
        XCTAssertNotEqual(JSON.string(" 3.14"), JSON.double(3.14))
        XCTAssertNotEqual(JSON.string("3.14 "), JSON.double(3.14))
    }
    
//    // MARK: - Complex Nested Structure Tests
//    func testComplexNestedStructures() {
//        let complex1: JSON = [
//            "array": [1, 2, ["nested": true]],
//            "object": ["a": 1, "b": ["deep": false]]
//        ]
//        
//        let complex2: JSON = [
//            "array": [1, 2, ["nested": true]],
//            "object": ["a": 1, "b": ["deep": true]]
//        ]
//        
//        XCTAssertLessThan(complex1, complex2)
//        
//        // Test equality with identical complex structures
//        XCTAssertEqual(complex1, complex1)
//    }
} 
