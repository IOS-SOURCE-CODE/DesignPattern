//: Playground - noun: a place where people can play

import Foundation

import PlaygroundSupport

protocol NetworkConnection {
   func connect()
   func disconnect()
   func sendCommand(command:String)
}


class NetworkConnectionFactory {
   class func createNetworkConnection() -> NetworkConnection {
      return connectionProxy
   }
   private class var connectionProxy: NetworkConnection {
      get {
         struct singletonWrapper {
            static let singleton = NetworkRequestProxy()
         }
         return singletonWrapper.singleton
      }
   }
}

class NetworkRequestProxy: NetworkConnection {
   private let wrapperRequest: NetworkConnection
   private let queue = DispatchQueue(label: "commandQ")
   private var referenceCount:Int = 0
   private var connected = false
   
   init() {
      wrapperRequest = NetworkConnectionImplementation()
   }
   
   func connect() {
      
   }
   func disconnect() {
      
   }
   
   func sendCommand(command: String) {
      self.referenceCount += 1
      queue.async {
         if !self.connected && self.referenceCount > 0 {
            self.wrapperRequest.connect()
            self.connected = true
         }
         self.wrapperRequest.sendCommand(command: command)
         self.referenceCount -= 1
         if self.connected && self.referenceCount == 0 {
            self.wrapperRequest.disconnect()
            self.connected = false
         }
      }
   }
}

private class NetworkConnectionImplementation: NetworkConnection {
   typealias  me = NetworkConnectionImplementation
   
   func connect() {
      me.writeMessage(msg: "Connect")
   }
   
   func disconnect() {
      me.writeMessage(msg: "disconnect")
   }
   
   func sendCommand(command: String) {
      me.writeMessage(msg: "Command: \(command)")
      Thread.sleep(forTimeInterval: 1)
      me.writeMessage(msg: "Command completed: \(command)")
   }
   
   private class func writeMessage(msg: String) {
      queue.async {
         print(msg)
      }
   }
   
   private class var queue: DispatchQueue {
      get {
         struct singletonWrapper {
            static let singleton = DispatchQueue(label: "writeQ")
         }
         return singletonWrapper.singleton
      }
   }
}



protocol HttpHeaderRequest {
   init(url: String)
   func getHeader(header:String, callback:@escaping (String, String?) -> Void)
   func execute()
}


private class HttpHeaderRequestProxy: HttpHeaderRequest {
   
   private let queue = DispatchQueue(label: "httpQ")
   private let semaphore = DispatchSemaphore(value: 0)
   let url:String
   var headersRequired:[String:(String, String?) -> Void]
   
   required init(url: String) {
      self.url = url
     self.headersRequired = [String:(String, String?) -> Void]()
   }

   func getHeader(header:String, callback: @escaping (String, String?) -> Void) {
      self.headersRequired[header] = callback
   }
   
   func execute() {
      let urlRequest = URL(string: url)
      let request = URLRequest(url: urlRequest!)
      
      URLSession.shared.dataTask(with: request) { (data, response, error) in
         if let httpResponse = response as? HTTPURLResponse {
            let headers = httpResponse.allHeaderFields as? [String: String]
            for(header, callback) in self.headersRequired {
               callback(header, headers?[header])
            }
         }
         self.semaphore.signal()
      }.resume()
      
      self.semaphore.wait(timeout: .distantFuture)
   }

}


class UserAuthentication {
   
   var user:String?
   var authenticated:Bool = false
   
   static let share = UserAuthentication()
   private init() {}
   
   func authenticate(user:String, password:String) {
      if (password == "seyha") {
         self.user = user
         self.authenticated = true
      } else {
         self.user = nil
         self.authenticated = false
      }
   }
   
}

class AccessControlProxy: HttpHeaderRequest {
   
   private let wrapperObject: HttpHeaderRequest
   
   required init(url: String) {
      wrapperObject = HttpHeaderRequestProxy(url: url)
   }
   
   func getHeader(header: String, callback: @escaping (String, String?) -> Void) {
      wrapperObject.getHeader(header: header, callback: callback)
   }
   
   func execute() {
      if UserAuthentication.share.authenticated {
         wrapperObject.execute()
      } else {
         fatalError("Unauthorized")
      }
   }
}


let url = "http://www.apress.com"
let headers = ["Content-Type", "Connection"]

let proxy = AccessControlProxy(url: url)

for header in headers {
   proxy.getHeader(header: header, callback: { (header, val) in
      if (val != nil) {
         print("\(header): \(val!)")
      }
   })
}

UserAuthentication.share.authenticate(user: "seyha", password: "seyha")

proxy.execute()


let queue = DispatchQueue(label: "requestQ", attributes: .concurrent)

for count in 0 ..< 3 {
   let connection = NetworkConnectionFactory.createNetworkConnection()
   queue.async {
      connection.connect()
      connection.sendCommand(command: "\(count)")
      connection.disconnect()
   }
}





//
//class TestTypealias {
//
//   typealias me = TestTypealias
//
//   func instanceFunc() {
//      me.hello()
//   }
//
//    private static func hello() {
//      print("Hello")
//   }
//}
//
//
//var testalias = TestTypealias()
//testalias.instanceFunc()





//typealias completion = (_ value:String) -> ()
//
//var completionHandler: completion!
//
//func execute( value: String, callBack: @escaping completion) {
//   completionHandler = callBack
//}
//
//
//execute(value: "10") { print($0) }
//
//
//completionHandler("100")
//





//let higherPriority = DispatchQueue.global(qos: .userInitiated)
//let lowerPriority = DispatchQueue.global(qos: .utility)

//let semaphore = DispatchSemaphore(value: 1)

//func asyncPrint(queue: DispatchQueue, symbol: String) {
//   queue.async {
////      print("\(symbol) waiting")
////      semaphore.wait()  // requesting the resource
//
//      for i in 0...10 {
//         print(symbol, i)
//      }
//
//      print("\(symbol) signal")
////      semaphore.signal() // releasing the resource
//   }
//}

//asyncPrint(queue: higherPriority, symbol: "🔴")
//asyncPrint(queue: lowerPriority, symbol: "🔵")
//

PlaygroundPage.current.needsIndefiniteExecution = true















