//
//  Downloader.swift
//  Downloader - Design Patterns in Swift: Structural
//
//  Created by Károly Nyisztor on 2017. 03. 05.
//

import Foundation

public enum DownloaderError: Error {
    case fileCopyError
}

/// Facade for URLSession and Filemanager
public struct Downloader {
    fileprivate static let session = URLSession(configuration: URLSessionConfiguration.default)
    fileprivate static let syncDownloadToFileQueue = DispatchQueue(label: "Downloader.downloadToFile.syncQueue")
    
    /// Downloads large payloads to a local file
    ///
    /// - Parameters:
    ///   - url: URL of the remote resource
    ///   - localURL: location of the file to store the downloaded payloded
    ///   - completionHandler: invoked after the download completes
    public static func download(from url: URL, to localURL: URL, completionHandler:@escaping (URLResponse?, Error?) -> Void) {
        syncDownloadToFileQueue.sync {
            let request = URLRequest(url: url)
            
            let downloadTask = session.downloadTask(with: request) {tempURL, response, error in
                guard error == nil else {
                    print("Failed to download from \(url), reason \(error?.localizedDescription)")
                    completionHandler(response, error)
                    return
                }
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Download successful from \(url), status \(statusCode)")
                }
                
                if let tempLocalURL = tempURL {
                    do {
                        if let fileExists = try? localURL.checkResourceIsReachable() {
                            if fileExists {
                                print("Warning! File exists at path \(localURL)")
                                
                                do {
                                    try FileManager.default.removeItem(at: localURL)
                                } catch let deleteError {
                                    print("Failed to delete file \(localURL), reason \(deleteError)")
                                    completionHandler(response, deleteError)
                                }
                            }
                        }
                        
                        try FileManager.default.copyItem(at: tempLocalURL, to: localURL)
                        completionHandler(response, nil)
                    } catch let copyError {
                        print("Error copying file to \(localURL), reason \(copyError)")
                        completionHandler(response, copyError)
                    }
                } else {
                    completionHandler(response, DownloaderError.fileCopyError)
                }
            }
            
            downloadTask.resume()
        }
    }
}
