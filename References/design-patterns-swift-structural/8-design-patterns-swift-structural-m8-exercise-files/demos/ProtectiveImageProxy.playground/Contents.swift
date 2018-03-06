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

// Access level changed from public to fileprivate
// Callers should not access ImageProxy instances directly, but rather through the protective proxy - see SecureImageProxy
fileprivate class ImageProxy: RemoteImage {
    let url: URL
    var hasContent: Bool = false
    fileprivate var counter = 0
    
    required init(url: URL) {
        self.url = url
    }
    
    lazy var image: UIImage? = {
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
//: Protective Proxy
public protocol Authenticating {
    var isAuthenticated: Bool {get}
    func authenticate(user: String) -> Bool
}

public class Authenticator: Authenticating {
    public var isAuthenticated: Bool = false
    fileprivate let userWhiteList = ["John", "Mary", "Steve"]
    fileprivate let syncQueue = DispatchQueue(label: "com.leakka.authQueue")
    static public let shared = Authenticator()
    
    fileprivate init() {}
    
    public func authenticate(user: String) -> Bool {
        var result = false
        syncQueue.sync {
            result = userWhiteList.contains(user) ? true : false
            if result == false {
                print("Error: Unauthorized!")
                isAuthenticated = false
            } else {
                print("Authorized!")
                isAuthenticated = true
            }
        }
        return result
    }
}

// The SecureImageProxy restricts access to the underlying ImageProxy resource
public class SecureImageProxy: RemoteImage {
    public let url: URL
    public var hasContent: Bool = false
    
    fileprivate lazy var imageProxy: ImageProxy = ImageProxy(url: self.url)
    
    required public init(url: URL) {
        self.url = url
    }
    
    public var image: UIImage? {
        get {
            return Authenticator.shared.isAuthenticated ? self.imageProxy.image : nil
        }
    }
}

// Testing
guard let imageURL = URL(string: "https://developer.apple.com/swift/images/swift-og.png") else {
    fatalError("Could not create URL")
}

let secureImageProxy = SecureImageProxy(url: imageURL)
print(secureImageProxy)

// "Jim" was not included in the white list, therefore the authentication will fail
Authenticator.shared.authenticate(user: "Jim")
if let image = secureImageProxy.image {
    print("Proxy has a valid image")
}

// "John" will authenticate successfully. 
// The protective proxy should allow access to the ImageProxy resource
Authenticator.shared.authenticate(user: "John")
if let image = secureImageProxy.image {
    print("Proxy has a valid image")
}

// We can display the image in the playground
let image = secureImageProxy.image

// Enable indefinite execution to let the asynchronous call finish
PlaygroundPage.current.needsIndefiniteExecution = true
