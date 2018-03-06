import UIKit
import PlaygroundSupport

// !!!: We must initialize the shared URLCache in a playground, otherwise we get loads of warnings
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

//: Remote Proxy
public protocol RemoteData {
    func data(url: URL, completionHandler: @escaping(Error?, Data?) -> Void) -> RemoteData
    func run()
}

/// Separates expensive the operation execution from using the result of the execution
public class RemoteDataProxy: RemoteData {
    fileprivate var callback: ((Error?, Data?) -> Void)?
    fileprivate var url: URL?
    
    public init() {}
    
    public func data(url: URL, completionHandler: @escaping(Error?, Data?) -> Void) -> RemoteData {
        self.url = url
        self.callback = completionHandler
        return self
    }
    
    public func run() {
        if let callback = self.callback, let url = self.url {
            URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                guard let data = data, error == nil else {
                    print("Could not download data from URL \(url.absoluteString). Reason: \(error!.localizedDescription)")
                    callback(error, nil)
                    return
                }
                print("Data successfully fetched from URL \(url.absoluteString)")
                callback(nil, data)
            }.resume()
            print("Downloading data from URL \(url.absoluteString)")
        } else {
            print("run() called before invoking data(url: completionHandler:")
        }
    }
}

// Testing
guard let dataURL = URL(string: "https://developer.apple.com/swift/images/swift-og.png") else {
    fatalError("Could not create URL")
}

// Here's where we use the returned data
// No network call is made at this point
let dataProxy = RemoteDataProxy().data(url: dataURL) { (error, data) in
    guard error == nil else {
        print("Could not retrieve data from URL \(dataURL.absoluteString)")
        return
    }
    
    print("\(data?.count ?? 0) bytes retrieved from URL \(dataURL.absoluteString)")
}

// ...

// Deferred execution of the expensive operation
dataProxy.run()

// Enable indefinite execution to let the asynchronous call finish
PlaygroundPage.current.needsIndefiniteExecution = true