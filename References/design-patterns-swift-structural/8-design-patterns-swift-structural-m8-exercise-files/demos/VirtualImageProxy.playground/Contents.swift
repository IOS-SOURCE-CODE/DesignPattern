import UIKit
import PlaygroundSupport

// !!!: We must initialize the shared URLCache in a playground, otherwise we get loads of warnings
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
//: Virtual Proxy
public protocol RemoteImage: CustomStringConvertible {
    init(url: URL)
    var image: UIImage? {get}
    var url: URL {get}
    var hasContent: Bool {get}
}

extension RemoteImage {
    public var description: String {
        let description = hasContent ? "Image available. Retrieved from \(self.url.absoluteString)" : "No image available yet!"
        return description
    }
}

public class ImageProxy: RemoteImage {
    public let url: URL
    public var hasContent: Bool = false
    fileprivate var counter = 0
    
    required public init(url: URL) {
        self.url = url
    }
    
    // The expensive object creation is deferred until we first access the lazy image property
    public lazy var image: UIImage? = {
        [unowned self] in
        self.counter += 1
        print("image property accessed \(self.counter) time(s)")
        
        var result: UIImage?
        if let img = try? UIImage(data: Data(contentsOf: self.url)) {
            result = img
            self.hasContent = true
        }
        return result
    }()
}

guard let imageURL = URL(string: "https://developer.apple.com/swift/images/swift-og.png") else {
    fatalError("Could not create URL")
}

// Testing
let imageProxy = ImageProxy(url: imageURL)

// The image property is uninitialized at this point
print(imageProxy)

// We access the (lazy) image property, which executes the closure
let image = imageProxy.image

// Now we have a valid image - assuming the closure code ran without issues
print(imageProxy)

// Lazy properties are only initialized once
// The counter value should not go above 1
for _ in 0..<10 {
    imageProxy.image
}

// Enable indefinite execution to let the asynchronous call finish
PlaygroundPage.current.needsIndefiniteExecution = true
