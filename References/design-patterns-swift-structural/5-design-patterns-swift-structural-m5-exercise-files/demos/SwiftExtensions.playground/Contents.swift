//: Swift Extensions
import UIKit
//: - Add computed instance properties and computed type properties
extension Double {
    public var celsius: Double { return self }
    public var fahrenheit: Double { return (self * 1.8) + 32 }
}

// Testing
let boilingWater = 100.0
print("Water boils at \(boilingWater)°C / \(boilingWater.fahrenheit)°F")
//: - Define instance methods and type methods
extension String {
    public func isLowercase() -> Bool {
        return self == self.lowercased()
    }
}

// Testing
let string = "abcdef"
print("String \(string) is lowercase: \(string.isLowercase())")
let string2 = "Abcdef"
print("String \(string2) is lowercase: \(string2.isLowercase())")
//: - Provide new initializers
extension CGVector {
    public init(point: CGPoint) {
        self.init(dx: point.x, dy: point.y)
    }
}

// Testing
let vec2D = CGVector(point: CGPoint(x: 2, y: 5))
print("CGVector \(vec2D) initialized with CGPoint")
//: - Define subscripts
extension String {
    public subscript (index: Int) -> Character {
        guard index >= 0 else {
            return "☠"
        }
        
        guard let idx = self.index(self.startIndex, offsetBy: index, limitedBy: self.endIndex) else {
            return "☠"
        }
        
        return self[idx]
    }
}

// Testing
let message = "Swift extensions are cool!"
print("String subscript example:")
for i in 0..<message.lengthOfBytes(using: .utf8) {
    print(message[i])
}
//: - Define and use new nested types
extension String {
    public enum CaseType {
        case lowerCase, upperCase, mixedCase
    }
    
    public var caseType: CaseType {
        switch self {
        case let str where str == str.uppercased():
            return .upperCase
        case let str where str == str.lowercased():
            return .lowerCase
        default:
            return .mixedCase
        }
    }
}

// Testing
let strLower = "abcdef"
print("\(strLower) is \(strLower.caseType)")
let strMixed = "Abcdef"
print("\(strMixed) is \(strMixed.caseType)")
let strUpper = "ABCDEF"
print("\(strUpper) is \(strUpper.caseType)")