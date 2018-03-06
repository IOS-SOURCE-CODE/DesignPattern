//: 👩🏼‍💻 Design Pattern

import Foundation
//: 🔥 Problem without composite pattern
class Part {
   let name:String
   let price:Float
   
   init(name:String, price:Float) {
      self.name = name
      self.price = price
   }
}


class CompositePart {
   let name:String
   let parts: [Part]
   
   init(name:String, parts:Part...) {
      self.name = name
      self.parts = parts
   }
}

class CustomerOrder {
   let customer:String
   let parts:[Part]
   let compositeParts:[CompositePart]
   
   init(customer:String, parts:[Part], composites:[CompositePart]) {
      self.customer = customer
      self.parts = parts
      self.compositeParts = composites
   }
   var totalPrice:Float {
      let partReducer = {(subtotal:Float, part:Part) -> Float in
         return subtotal + part.price
      }
      
      let total = parts.reduce(0, partReducer)
      return compositeParts.reduce(total, { (subtotal, cpart) -> Float in
         return cpart.parts.reduce(subtotal, partReducer)
      })
   }
   
   func printDetails() {
      print("Order for \(customer): Cost: \(formatCurrencyString(number: totalPrice))")
   }
   
   
   func formatCurrencyString(number:Float) -> String {
      let nsnumber = NSNumber(value: number)
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      return formatter.string(from: nsnumber) ?? ""
   }
}

let doorWindow = CompositePart(name: "DoorWindow",
                               parts:
                                 Part(name: "Window", price: 100.50),
                                 Part(name:"Window Switch", price: 12))

let door = CompositePart(name: "Door", parts:
                                       Part(name: "Window", price: 100.50),
                                       Part(name: "Door Loom", price: 80),
                                       Part(name: "Window Switch", price: 12),
                                       Part(name: "Door Handles", price: 43.40))

let hood = Part(name: "Hood", price: 320)

let order = CustomerOrder(customer: "Seyha", parts: [hood], composites: [door, doorWindow])
order.printDetails()


//:  💁‍♂️  Solution
protocol SCartPart {
   var name:String { get }
   var price:Float { get }
}

class SPart: SCartPart {
   let name: String
   let price: Float
   
   init(name:String, price:Float) {
      self.name = name
      self.price = price
   }
}

class SCompositePart: SCartPart {
   let name: String
   let parts: [SCartPart]
   
   init(name:String, parts:SCartPart...) {
      self.name = name
      self.parts = parts
   }
   
   var price: Float {
      return parts.reduce(0) { $0 + $1.price  }
   }
}



class SCustomerOrder {
   let customer:String
   let parts: [SCartPart]
   
   init(customer:String, parts:[SCartPart]) {
      self.customer = customer
      self.parts = parts
   }
   
   var totalPrice: Float {
      return parts.reduce(0) { $0 + $1.price }
   }
   
   func printDetails() {
      print("Order for \(customer): Cost: \(formatCurrencyString(number: totalPrice))")
   }
   
   func formatCurrencyString(number:Float) -> String {
      let nsnumber = NSNumber(value: number)
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      return formatter.string(from: nsnumber) ?? ""
   }
}



let sdoorWindow = SCompositePart(name: "DoorWindow",
                               parts:
                                 SPart(name: "Window", price: 100.50),
                                 SPart(name:"Window Switch", price: 12))

let sdoor = SCompositePart(name: "Door", parts:
//                           SPart(name: "Window", price: 100.50),
//                           SPart(name: "Window Switch", price: 12),
                           sdoorWindow,
                           SPart(name: "Door Loom", price: 80),
                           SPart(name: "Door Handles", price: 43.40))

let shood = SPart(name: "Hood", price: 320)

let sorder = SCustomerOrder(customer: "Seyha", parts: [shood, sdoor, sdoorWindow])
sorder.printDetails()


var mains:[SCartPart] = [sdoorWindow, shood]

mains.reduce(0) { (total, part) -> Float in
   
   print("\(part.name) with price \(part.price)")
   
  return total + part.price
   
}

/*:
 ☔️ Another Simple of composite pattern
 
 🐍 Example with dir list
 
 */
public class File: CustomStringConvertible {
   fileprivate var nestingLevel: Int  = 0
   fileprivate let name:String
   
   init(name:String) {
      self.name = name
   }
   
   public func nesting(level: Int) {
      self.nestingLevel = level
   }
   
   public var description: String {
      let nesting = String(repeating: "\t", count: nestingLevel) + "- "
      return "\(nesting)\(name) (" + String(format: "%.1f", (Float(size)/1024/1024)) + "MB)"
   }
   
   lazy public var size = arc4random_uniform(1000000)
   
}


public class Directory: CustomStringConvertible {
   fileprivate var entries = Array<AnyObject>()
   fileprivate var nestingLevel: Int = 0
   fileprivate let name:String
   
   public func nesting(level: Int) {
      self.nestingLevel = level
   }
   
   public required init(name:String) {
      self.name = name
   }
   
   public func add(entry: AnyObject) {
      if let fileEntry = entry as? File {
         fileEntry.nesting(level: self.nestingLevel + 1 )
      } else if let directoryEntry = entry as? Directory {
         directoryEntry.nesting(level: self.nestingLevel + 1)
      }
      entries.append(entry)
   }
   
   public var description: String {
       var result = String(repeating: "\t", count: nestingLevel) + "[+] \(name) (" + String(format: "%.1f", (Float(size)/1024/1024)) + "MB)"
      
      for entry in self.entries {
         if let fileEntry = entry as? File {
            result += "\n\(fileEntry)"
         } else if let directoryEntry = entry as? Directory {
            result += "\n\(directoryEntry)"
         }
      }
      return result
   }
   
   
   public var size: UInt32 {
      var result: UInt32 = 0
      
      for entry in self.entries {
         if let fileEntry = entry as? File {
            result += fileEntry.size
         } else if let directoryEntry = entry as? Directory {
            result += directoryEntry.size
         }
      }
      return result
   }
}



var parentDir = Directory(name: "Music")
var subDir1 = Directory(name: "Red Hot Chili Peppers - Greatest Hits")
parentDir.add(entry: subDir1)

// files
var file11 = File(name: "Parallel Universe.mp3")
subDir1.add(entry: file11)
var file12 = File(name: "Dani California.mp3")
subDir1.add(entry: file12)
var file13 = File(name: "By The Way.mp3")
subDir1.add(entry: file13)

print(parentDir)




//: 🦋 Solution




public protocol FileSystemEntry: CustomStringConvertible {
   
   init(name:String)
   var size:UInt32 { get }
   func nesting(level: Int)
}





public class SFile: FileSystemEntry {
   fileprivate var nestingLevel: Int  = 0
   fileprivate let name:String
   
   public required init(name:String) {
      self.name = name
   }
   
   public func nesting(level: Int) {
      self.nestingLevel = level
   }
   
   public var description: String {
      let nesting = String(repeating: "\t", count: nestingLevel) + "- "
      return "\(nesting)\(name) (" + String(format: "%.1f", (Float(size)/1024/1024)) + "MB)"
   }
   
   lazy public var size = arc4random_uniform(1000000)
   
}


public class SDirectory: FileSystemEntry {
   fileprivate var entries = Array<FileSystemEntry>()
   fileprivate var nestingLevel: Int = 0
   fileprivate let name:String
   
   public func nesting(level: Int) {
      self.nestingLevel = level
   }
   
   public required init(name:String) {
      self.name = name
   }
   
   public func add(entry: FileSystemEntry) {
//      if let fileEntry = entry as? File {
//         fileEntry.nesting(level: self.nestingLevel + 1 )
//      } else if let directoryEntry = entry as? Directory {
//         directoryEntry.nesting(level: self.nestingLevel + 1)
//      }
      entry.nesting(level: self.nestingLevel + 1)
      entries.append(entry)
   }
   
   public var description: String {
      var result = String(repeating: "\t", count: nestingLevel) + "[+] \(name) (" + String(format: "%.1f", (Float(size)/1024/1024)) + "MB)"
      
      for entry in self.entries {
//         if let fileEntry = entry as? File {
//            result += "\n\(fileEntry)"
//         } else if let directoryEntry = entry as? Directory {
//            result += "\n\(directoryEntry)"
//         }
         
          result += "\n\(entry)"
      }
     
      return result
   }
   
   
   public var size: UInt32 {
      var result: UInt32 = 0
      
      for entry in self.entries {
//         if let fileEntry = entry as? File {
//            result += fileEntry.size
//         } else if let directoryEntry = entry as? Directory {
//            result += directoryEntry.size
//         }
         result += entry.size
      }
      return result
   }
}






var sparentDir = SDirectory(name: "Music")
var ssubDir1 = SDirectory(name: "Red Hot Chili Peppers - Greatest Hits")
sparentDir.add(entry: ssubDir1)

// files
var sfile11 = SFile(name: "Parallel Universe.mp3")
ssubDir1.add(entry: sfile11)
var sfile12 = SFile(name: "Dani California.mp3")
ssubDir1.add(entry: sfile12)
var sfile13 = SFile(name: "By The Way.mp3")
ssubDir1.add(entry: sfile13)

print(parentDir)

















































