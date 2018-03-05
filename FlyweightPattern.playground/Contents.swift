//: Playground - noun: a place where people can play

import Foundation


func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
   return lhs.col == rhs.col && lhs.row == rhs.row
}


class Coordinate: CustomStringConvertible, Hashable {
   let col: Character
   let row: Int
   
   init(col: Character, row: Int) {
      self.col = col
      self.row = row
   }
   
   var hashValue: Int {
      return description.hashValue
   }
   
   var description: String {
      return "\(col)\(row)"
   }
   
}


class Cell {
   var coordinate: Coordinate
   var value: Int
   
   init(col:Character, row:Int, val:Int) {
      self.coordinate = Coordinate(col: col, row: row)
      self.value = val
   }
}

class Spreadsheet {
//   var grid = Dictionary<Coordinate, Cell>()
   var grid: Flyweight
   
   init() {
//      let letters: String = "ABCDEFGHUJKLMNOPQRSTUVWXYZ"
//      var stringIndex = letters.startIndex
//      let rows = 50
//
//      repeat {
//         let colletter = letters[stringIndex]
//         stringIndex = letters.index(after: stringIndex)
//         for rowIndex in 1 ... rows {
//            let cell = Cell(col: colletter, row: rowIndex, val: rowIndex)
//            grid[cell.coordinate] = cell
//         }
//      } while(stringIndex != letters.endIndex)
      grid = FlyweightFactory.createFlywight()
   }
   
   func setValue(coord: Coordinate, value:Int) {
//      grid[coor]?.value = value
      grid[coord] = value
   }
   
   var total:Int {
//      return grid.values.reduce(0) { $0 + $1.value }
      return grid.total
   }
}








protocol Flyweight {
   subscript(index: Coordinate) -> Int? { get set }
   var total:Int { get }
   var count: Int { get }
}


class FlyweightImplementation: Flyweight {
   private let extrinsicData:[Coordinate: Cell]
   private var intrinsicData:[Coordinate: Cell]
   private let queue: DispatchQueue
   
    init(extrinsic:[Coordinate: Cell]) {
      self.extrinsicData = extrinsic
      self.intrinsicData = Dictionary<Coordinate,Cell>()
      self.queue = DispatchQueue(label: "dataQ", attributes: .concurrent)
   }
   
   subscript(key:Coordinate) -> Int? {
      get {
         var result:Int?
         queue.async {
            if let cell = self.intrinsicData[key] {
               result = cell.value
            } else {
               result = self.extrinsicData[key]?.value
            }
         }
        return result
         
      }
      set(value) {
         
         if value != nil {
            queue.async(flags: .barrier){
               self.intrinsicData[key] = Cell(col: key.col, row: key.row, val: value!)
            }
         }
      }
   }
   
   var total: Int {
      var result = 0
      queue.async {
         result =  self.extrinsicData.values.reduce(0) { (total, cell) in
            if let instrinsicCell = self.intrinsicData[cell.coordinate] {
               return total + instrinsicCell.value
            } else {
               return total + cell.value
            }
         }
      }
      return result
   }
   
   var count: Int {
      var result = 0
      queue.async {
         result =  self.intrinsicData.count
      }
      return result
   }
}


extension Dictionary {
   init(setupFunc:(() -> [(Key, Value)])) {
      self.init()
      for item in setupFunc() {
         self[item.0] = item.1
      }
   }
}

class FlyweightFactory {
   class func createFlywight() -> Flyweight {
      return FlyweightImplementation(extrinsic: extrinsicData)
   }
   
   private class var extrinsicData: [Coordinate:Cell] {
      get {
         struct singletonWrapper {
            static let singletonData = Dictionary<Coordinate, Cell> (setupFunc: { () in
                  var results = [(Coordinate,Cell)]()
                  let letters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                  var stringIndex = letters.startIndex
                  let rows = 50
                  repeat {
                     let colletter = letters[stringIndex]
                     stringIndex = letters.index(after: stringIndex)
                     for rowIndex in 1...rows {
                        let cell = Cell(col: colletter, row: rowIndex, val: rowIndex)
                        results.append((cell.coordinate, cell))
                     }
                  } while (stringIndex != letters.endIndex)
                  return results
            })
         }
         return singletonWrapper.singletonData
      }
   }
}


let ss1 = Spreadsheet()
ss1.setValue(coord: Coordinate(col: "A", row: 1), value: 100)
ss1.setValue(coord: Coordinate(col: "J", row: 20), value: 200)
print("SS1 Total: \(ss1.total)")
x

let ss2 = Spreadsheet()
ss2.setValue(coord: Coordinate(col: "F", row: 10), value: 200)
ss2.setValue(coord: Coordinate(col: "G", row: 23), value: 250)
print("SS1 Total: \(ss2.total)")

print("Cells created: \(ss1.grid.count + ss2.grid.count)")


//
//class TestHashValue : Hashable {
//
//   var value = 1
//
//   var hashValue: Int {
//      return "\(value)".hashValue
//   }
//}
//
//class TestValue {
//   let testHasValue: TestHashValue
//   let value: Int
//
//   init(testHasValue: TestHashValue, value: Int ) {
//      self.testHasValue = testHasValue
//      self.value = value
//   }
//}
//
//func == (lhs: TestHashValue, rhs: TestHashValue) -> Bool {
//   return lhs.value == rhs.value
//}
//
//
//
//let test = TestHashValue()
//test.hashValue
//
//
//var dictionary = Dictionary<TestHashValue, TestValue>()
//
//
//
//dictionary[TestHashValue()] = TestValue(testHasValue: TestHashValue(), value: 10)
//dictionary.values.map { $0 }
//
//
//dictionary[TestHashValue()]?.value
//
//var dict = [String: TestValue]()
//
//dict["me"] = TestValue(testHasValue: TestHashValue(), value: 10)
//
//dict["me"]?.value



