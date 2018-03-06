//: Naive attempt to integrate a third-party type without the Adapter pattern
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
// This is a naive approach to integrate the third-party RedditPoster type, which has an incompatible interface
public class Sharer {
    private let shareServices: [SharerType: Sharing] = [SharerType.facebook: FBSharer(), SharerType.twitter: TwitterSharer()]

    private lazy var redditPoster = RedditPoster()

    public func share(message: String, serviceType: SharerType, completionHandler: @escaping (Error?) -> Void) {
        if serviceType == SharerType.reddit {
            redditPoster.post(text: message, completion: { (error, uuid) in
                completionHandler(error)
            })
        } else if let service = shareServices[serviceType] {
            service.share(message: message, completionHandler: completionHandler)
        }
    }

    public func shareEverywhere(message: String) {
        for (serviceType, sharer) in shareServices {
            sharer.share(message: message, completionHandler: { (error) in
                if(error != nil) {
                    print("Error occured while trying to share message \(message) via \(serviceType)")
                }
            })
        }
        // Also share on Reddit
        redditPoster.post(text: message, completion: { (error, uuid) in
            guard error == nil else {
                print("Error occured while trying to share message \(message) via \(SharerType.reddit)")
                return
            }
        })
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