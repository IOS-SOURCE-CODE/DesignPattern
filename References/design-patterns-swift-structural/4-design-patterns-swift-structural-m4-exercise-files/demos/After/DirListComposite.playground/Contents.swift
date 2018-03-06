//: Applying the Composite pattern
import Foundation

// We introduce a common, FileSystemEntry protocol and make our types conform to it
// The common protocol lets us remove the type checks
public protocol FileSystemEntry: CustomStringConvertible {
    init(name: String)
    func nesting(level: Int)
    var size: UInt32 {get}
}

public class File: FileSystemEntry {
    
    fileprivate var nestingLevel: Int = 0
    fileprivate let name: String
    
    public func nesting(level: Int) {
        self.nestingLevel = level
    }
    
    public required init(name: String) {
        self.name = name
    }
    
    public var description: String {
        let nesting = String(repeating: "\t", count: nestingLevel) + "- "
        return "\(nesting)\(name) (" + String(format: "%.1f", (Float(size)/1024/1024)) + "MB)"
    }
    
    lazy public var size = arc4random_uniform(1000000)
}

public class Directory: FileSystemEntry {
    fileprivate var entries = Array<FileSystemEntry>()
    fileprivate var nestingLevel: Int = 0
    fileprivate let name: String
    
    public func nesting(level: Int) {
        self.nestingLevel = level
    }
    
    public required init(name: String) {
        self.name = name
    }
    
    public func add( entry: FileSystemEntry) {
        entry.nesting(level: self.nestingLevel + 1)
        entries.append(entry)
    }
    
    public var description: String {
        var result = String(repeating: "\t", count: nestingLevel) + "[+] \(name) (" + String(format: "%.1f", (Float(size)/1024/1024)) + "MB)"
        
        for entry in self.entries {
            result += "\n\(entry)"
        }
        return result
    }
    
    public var size: UInt32 {
        var result: UInt32 = 0
        
        for entry in self.entries {
            result += entry.size
        }
        return result
    }
}

// Testing
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
        var file14 = File(name: "Love Rollercoaster.mp3")
        subDir1.add(entry: file14)
        var file15 = File(name: "Aeroplane.mp3")
        subDir1.add(entry: file15)
        var file16 = File(name: "Under The Bridge.mp3")
        subDir1.add(entry: file16)
        var file17 = File(name: "Road Trippin'.mp3")
        subDir1.add(entry: file17)
        var file18 = File(name: "The Zephyr Song.mp3")
        subDir1.add(entry: file18)
        var file19 = File(name: "Otherside.mp3")
        subDir1.add(entry: file19)
        var file20 = File(name: "Dosed.mp3")
        subDir1.add(entry: file20)

    var subDir2 = Directory(name: "Muse")
parentDir.add(entry: subDir2)
        var subDir21 = Directory(name: "The 2nd Law")
    subDir2.add(entry: subDir21)
            // files
            var file211 = File(name: "Supremacy.mp3")
            subDir21.add(entry: file211)
            var file212 = File(name: "Madness.mp3")
            subDir21.add(entry: file212)
            var file213 = File(name: "Panic Station.mp3")
            subDir21.add(entry: file213)
            var file214 = File(name: "Prelude.mp3")
            subDir21.add(entry: file214)
            var file215 = File(name: "Survival.mp3")
            subDir21.add(entry: file215)

        var subDir22 = Directory(name: "Drones")
    subDir2.add(entry: subDir22)
            // files
            var file221 = File(name: "Dead Inside.mp3")
            subDir22.add(entry: file221)
            var file222 = File(name: "Aftermath.mp3")
            subDir22.add(entry: file222)
            var file223 = File(name: "Drones.mp3")
            subDir22.add(entry: file223)
            var file224 = File(name: "Mercy.mp3")
            subDir22.add(entry: file224)

print(parentDir)