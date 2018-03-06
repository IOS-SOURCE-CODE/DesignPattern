/*: The Bridge Pattern solves the problem of exploding class hierarchies
 The Bridge pattern separates the functionality that is specific to a given type from the functionality that is shared between types.
 We can separate the common, message sending functionality from the functionality that is specific to message handling.
 Let's introduce two abstractions:
 1. MessageSending - for the common functionality
 2. MessageHandler - for specific functionality
*/

protocol MessageSending {
    func send(messageHandler: MessageHandler, message: String, completionHandler: @escaping (Error?) -> Void)
}

public protocol MessageHandler {
    func modify(message: String) -> String
}

// Instead of introducing a new subclass for each new feature, we only have to add a new MessageHandler implementation class

public class PlainMessageHandler: MessageHandler {
    public func modify(message: String) -> String {
        // returns unmodified message
        return message
    }
}

public class SecureMessageHandler: MessageHandler {
    fileprivate func encrypt(message: String, key: UInt8) -> String {
        return String( describing: message.utf8.map{$0 ^ key} )
    }
    
    public func modify(message: String) -> String {
        return self.encrypt(message: message, key: 0xcc)
    }
}

public class SelfDestructingMessageHandler: MessageHandler {
    public func modify(message: String) -> String {
        return "☠" + message
    }
}

// We only have to add new message handlers whenever there is a new requirement for modifying the message before it is sent. The Message sender classes remain unaffected.

class QuickMessageSender: MessageSending {
    public func send(messageHandler:MessageHandler, message: String, completionHandler: @escaping (Error?) -> Void) {
        let modifiedMessage = messageHandler.modify(message: message)
        print("Message \"\(modifiedMessage)\" sent via e-mail")
        completionHandler(nil)
    }
}

class VIPMessageSender: MessageSending {
    public func send(messageHandler:MessageHandler, message: String, completionHandler: @escaping (Error?) -> Void) {
        let modifiedMessage = messageHandler.modify(message: message)
        print("Message \"\(modifiedMessage)\"  sent via P2P")
        completionHandler(nil)
    }
}

class EZMessageSender: MessageSending {
    public func send(messageHandler:MessageHandler, message: String, completionHandler: @escaping (Error?) -> Void) {
        let modifiedMessage = messageHandler.modify(message: message)
        print("Message \"\(modifiedMessage)\"  sent via P2P")
        completionHandler(nil)
    }
}


// Testing
let message = "Hello"

// Send plain messages
let quickMessageHandler = QuickMessageSender()
quickMessageHandler.send(messageHandler: PlainMessageHandler(), message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

let vipMessageHandler = VIPMessageSender()
vipMessageHandler.send(messageHandler: PlainMessageHandler(), message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

// Send encrypted messages
quickMessageHandler.send(messageHandler: SecureMessageHandler(), message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

vipMessageHandler.send(messageHandler: SecureMessageHandler(), message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

// Send self-destructing messages
quickMessageHandler.send(messageHandler: SelfDestructingMessageHandler(), message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

vipMessageHandler.send(messageHandler: SelfDestructingMessageHandler(), message: message) { (error) in
    guard error == nil else {
        print("Could not send message")
        return
    }
}

