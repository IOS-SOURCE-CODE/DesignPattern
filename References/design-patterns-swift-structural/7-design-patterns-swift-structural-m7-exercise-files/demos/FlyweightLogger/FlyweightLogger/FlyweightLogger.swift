//
//  FlyweightLogger.swift
//  FlyweightLogger - Design Patterns in Swift: Structural
//
//  Created by Károly Nyisztor on 2017. 03. 05.
//

import Foundation
import os.log

public protocol FlyweightLogger: class {
    var subsystem: String {get}
    var category: String {get}
    
    init(subsystem: String, category: String)
    
    func log(_ message: String, type: OSLogType, file: String, function: String, line: Int)
}

// We provide default argument values via a protocol extension
extension FlyweightLogger {
    public func log(_ message: String, type: OSLogType, file: String = #file, function: String = #function, line: Int = #line) {
        return log(message, type: type, file: file, function: function, line: line)
    }
}

// Log levels
extension OSLogType: CustomStringConvertible {
    public var description: String {
        switch self {
        case OSLogType.info:
            return "INFO"
        case OSLogType.debug:
            return "DEBUG"
        case OSLogType.error:
            return "ERROR"
        case OSLogType.fault:
            return "FAULT"
        default:
            return "DEFAULT"
        }
    }
}

// FlyweightLogger relies on the Unified System Logger introduced with iOS10
public class Logger: FlyweightLogger {
    public let subsystem: String
    public let category: String
    fileprivate let logger: OSLog
    fileprivate let syncQueue = DispatchQueue(label: "com.leakka.logger")
    
    public required init(subsystem: String, category: String = "") {
        self.subsystem = subsystem
        self.category = category
        self.logger = OSLog(subsystem: subsystem, category: category)
    }
    
    public func log(_ message: String, type: OSLogType, file: String, function: String, line: Int) {
        syncQueue.sync {
            os_log("%@ [%@ %@ line%d] %@", log: logger, type: type, type.description, file, function, line, message)
        }
    }
}

// The FlyweightLoggerFactory ensures the Flyweight behavior: the same logger instance
// is returned for a particular identifier (subsystem + category pair)
// The Flyweight pattern separates the intrinsic, shared state - the logger ID - from the extrinsic set of attributes, that is, the log message and the log level   
public class FlyweightLoggerFactory {
    fileprivate var loggersByID = Dictionary<String, FlyweightLogger>()
    fileprivate let syncQueue = DispatchQueue(label: "com.leakka.flyweightLoggerFactory")
    public static var shared = FlyweightLoggerFactory()
    
    fileprivate init() {}
    
    public func logger(subsystem: String, category: String = "") -> FlyweightLogger? {
        var result: FlyweightLogger?
        syncQueue.sync {
            let key = subsystem + category
            if let logger = loggersByID[key] {
                result = logger
            } else {
                result = Logger(subsystem: subsystem, category: category)
                loggersByID[key] = result
            }
        }
        return result
    }
}
