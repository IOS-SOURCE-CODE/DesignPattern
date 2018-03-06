//: RedditPoster Adapter via Swift Extension
import Foundation

protocol Sharing {
    func share(message: String, completionHandler: @escaping (Error?) -> Void)
}

class FBSharer: Sharing {
    public func share(message: String, completionHandler: @escaping (Error?) -> Void) {
        print("Message \(message) shared on Facebook")
        completionHandler(nil)
    }
}

class TwitterSharer: Sharing {
    public func share(message: String, completionHandler: @escaping (Error?) -> Void) {
        print("Message \(message) shared on Twitter")
        completionHandler(nil)
    }
}


/// Third-party class - we cannot modify its implementation
public class RedditPoster {
    public func post(text: String, completion: @escaping (Error?, UUID?) -> Void) {
        print("Message \(text) posted to Reddit")
        completion(nil, UUID())
    }
}

// We add Sharing protocol conformance to the RedditPoster type without modifying the original implementation
extension RedditPoster: Sharing {
    public func share(message: String, completionHandler: @escaping (Error?) -> Void) {
        self.post(text: message, completion: { (error, uuid) in
            completionHandler(error)
        })
    }
}

public enum SharerType: String, CustomStringConvertible {
    case facebook = "Facebook"
    case twitter = "Twitter"
    case reddit = "Reddit"
    
    public var description: String {
        switch self {
        case .facebook:
            return "Facebook Sharer"
        case .twitter:
            return "Twitter Sharer"
        case .reddit:
            return "Reddit Poster"
        }
    }
}
//: Sharer utility
public class Sharer {
    private let shareServices: [SharerType: Sharing] = [SharerType.facebook: FBSharer(), SharerType.twitter: TwitterSharer(), SharerType.reddit: RedditPoster()]
    
    public func share(message: String, serviceType: SharerType, completionHandler: @escaping (Error?) -> Void) {
        if let service = shareServices[serviceType] {
            service.share(message: message, completionHandler: completionHandler)
        }
    }
    
    public func shareEverywhere(message: String) {
        for (serviceType, sharer) in shareServices {
            sharer.share(message: message, completionHandler: { (error) in
                guard error == nil else {
                    print("Error occured while trying to share message \(message) via \(serviceType)")
                    return
                }
            })
        }
    }
}

// Testing
let sharer = Sharer()
sharer.share(message: "Hey there", serviceType: SharerType.facebook, completionHandler: { (error) in
    guard error == nil else {
        print("Error occured while trying to share message")
        return
    }
})

sharer.shareEverywhere(message: "Hello World!")
