//: Demonstrate the problem of exploding class hierarchies
import Foundation

protocol Messaging {
    func send(message: String, completionHandler: @escaping (Error?) -> Void)
}

class QuickMessenger: Messaging {
    public func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        print("Message \"\(message)\" sent via e-mail")
        completionHandler(nil)
    }
}

class VIPMessenger: Messaging {
    public func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        print("Message \"\(message)\"  sent via P2P")
        completionHandler(nil)
    }
}

// Later, we need to add the ability of sending encrypted messages.

class SecureQuickMessenger: QuickMessenger {
    fileprivate func encrypt(message: String, key: UInt8) -> String {
        for codeUnit in message.utf8 {
            print("\(codeUnit) ", terminator: "")
        }
        print("Original: \(message) UTF8: \(message.utf8) encoded:\(String( describing: message.utf8.map{$0 ^ key} ))")
        
        return String( describing: message.utf8.map{$0 ^ key} )
    }
    
    public override func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        let secure = self.encrypt(message: message, key: 0xcc)
        super.send(message: secure, completionHandler: completionHandler)
    }
}

class SecureVIPMessenger: VIPMessenger {
    fileprivate func encrypt(message: String, key: UInt8) -> String {
        return String( describing: message.utf8.map{$0 ^ key} )
    }
    
    public override func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        let secure = self.encrypt(message: message, key: 0xcc)
        super.send(message: secure, completionHandler: completionHandler)
    }
}

// Testing
// We send messages using the QuickMessenger and the VIPMessenger, both plain text and encrypted
let message = "Hello"
let quickMessenger = QuickMessenger()
quickMessenger.send(message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

let secureQuickMessenger = SecureQuickMessenger()
secureQuickMessenger.send(message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

let vipMessenger = VIPMessenger()
vipMessenger.send(message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

let secureVIPMessenger = SecureVIPMessenger()
secureVIPMessenger.send(message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

// Next, we need to support the feature of self-destructing messages
// We add two more subclasses, SelfDestructingQuickMessenger and SelfDestructingVIPMessenger
class SelfDestructingQuickMessenger: QuickMessenger {
    public override func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        let selfDestructingMessage = "☠" + message
        super.send(message: selfDestructingMessage, completionHandler: completionHandler)
    }
}

class SelfDestructingVIPMessenger: VIPMessenger {
    public override func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        let selfDestructingMessage = "☠" + message
        super.send(message: selfDestructingMessage, completionHandler: completionHandler)
    }
}

// The number of classes keeps increasing as we implement a new requirement.
class EZMessenger: Messaging {
    public func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        print("Self-destructing message \"\(message)\" sent")
        completionHandler(nil)
    }
}

class SecureEZMessenger: EZMessenger {
    fileprivate func encrypt(message: String, key: UInt8) -> String {
        return String( describing: message.utf8.map{$0 ^ key} )
    }
    
    public override func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        let secure = self.encrypt(message: message, key: 0xcc)
        super.send(message: secure, completionHandler: completionHandler)
    }
}

class SelfDestructingEZMessenger: EZMessenger {
    public override func send(message: String, completionHandler: @escaping (Error?) -> Void) {
        let selfDestructingMessage = "☠" + message
        super.send(message: selfDestructingMessage, completionHandler: completionHandler)
    }
}


let ezMessenger = EZMessenger()
ezMessenger.send(message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

let secureEZMessenger = SecureEZMessenger()
secureEZMessenger.send(message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}