//
//  URLSessionViewController.swift
//  Http同步请求
//
//  Created by 郑小燕 on 2018/1/16.
//  Copyright © 2018年 郑小燕. All rights reserved.
//

import UIKit

class URLSessionViewController: UIViewController {
    
    var defaultConfiguration: URLSessionConfiguration!
    var ephemeralConfiguration: URLSessionConfiguration!
    var backgroundConfiguration: URLSessionConfiguration!
    var defaultSession: URLSession!
    var ephemeralSession: URLSession!
    var backgroundSession: URLSession!
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setConfigration()
        let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let cacheURL = try! cachesDirectoryURL?.appendingPathComponent("MyCache")
        var diskPath = cacheURL?.path
        let cache = URLCache(memoryCapacity: 16384, diskCapacity: 268435456, diskPath: diskPath)
        defaultConfiguration.urlCache = cache
        let delegate = MySessionDelegate()
        let operationQueue = OperationQueue.main
        defaultSession = URLSession(configuration: defaultConfiguration, delegate: delegate, delegateQueue: operationQueue)
        ephemeralSession = URLSession(configuration: ephemeralConfiguration, delegate: delegate, delegateQueue: operationQueue)
        backgroundSession = URLSession(configuration: backgroundConfiguration, delegate: delegate, delegateQueue: operationQueue)
        
        //不允许蜂窝网
        ephemeralConfiguration.allowsCellularAccess = false
        let ephemeralSessionWiFiOnly = URLSession(configuration: ephemeralConfiguration, delegate: delegate, delegateQueue: operationQueue)
//                self.systemDelegate()
//        self.customDelegate()
        self.downloadFile()

       let originalString = "color-#708090"
        var allowedCharacters = NSCharacterSet.urlFragmentAllowed
        let encodedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        print("allowedCharacters =\(allowedCharacters) encodedString = \(encodedString)")
        
        let url = URL(string: "https://example.com/#color-%23708090")!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let fragment = components?.fragment
        print("fragment = \(fragment)")
        let error = AFError.jsonEncodingFailed
        print(error.errorType())
        if case AFError.jsonEncodingFailed = error {
            print("1111111111111")
        }
        
        
        let urlComponent = URLComponents(url: URL(string: "http://www.aspxfans.com:8080/news/index.asp?boardID=5&ID=24618&page=1#name")!, resolvingAgainstBaseURL: false)
        let percentEncodedQuery = urlComponent?.percentEncodedQuery.map{ return $0 + "&"
        }
//        URLSessionTaskDelegate
        print("percentEncodedQuery = \(percentEncodedQuery)")
        //反转
        var letter = CharacterSet.lowercaseLetters
        let decimalDigit = CharacterSet.decimalDigits
        letter.formUnion(decimalDigit)
        let string1 = "g8!hgr3@09#23uiq%^78sjn453t78&13gesg*wt53(545y45)q3at"
      letter = letter.inverted
        print(string1.components(separatedBy: letter))
        
        
        
        
        
        
        let string = "list[][classid]"
        
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacters.remove(charactersIn:  "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        print("string = \(string)===")
        
        var escaped = ""
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                
                let substring = string[range]
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
                
                index = endIndex
            }
        }
        print("str = \(escaped)")
        
        
        
    }
    
    //下载文件
    func downloadFile()  {
        if let url = URL(string: "https://image2.cqcb.com/d/file/p/2017-12-18/56e2481b86f89a5f033942bd51247a1c.jpg") {
            let dataTask = backgroundSession.downloadTask(with: url)

        }
    }
    
    func setConfigration() {
        self.defaultConfiguration = URLSessionConfiguration.default
        self.ephemeralConfiguration = URLSessionConfiguration.ephemeral
        self.backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "com.myapp.networking.background")
    }
    
    ///通过自定义的方法获取数据
    func customDelegate() {
        if let url = URL(string: "https://www.cqcb.com/newlist42.html") {
            let dateTask = defaultSession.dataTask(with: url)
            dateTask.resume()
        }
    }
    
    
    ///通过系统提供的协议获取数据
    func systemDelegate() {
        let sessionWithoutADelegate = URLSession(configuration: defaultConfiguration)
        if let url = URL(string: "https://www.cqcb.com/newlist42.html") {
            sessionWithoutADelegate.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let response = response {
                    let string = String(data: data!, encoding: String.Encoding.utf8)
                    print("Response: \(response)")
                    print("Data: \n\(string)\nEND data\n")
                    
                    
                }
            }).resume()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

typealias CompletionHandler = () -> Void
class MySessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("url = \(location)")
    }
    
    //下载任务的进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //进度
        let progress: Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("progress = \(progress)")
    }
    //后台下载
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
            appDelegate.backgroundSessionCompletionHandler = nil
            completionHandler()
        }

    }
    //重定向
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        var newRequest = request
//        if response != nil {
//            newRequest = nil
//        }
        completionHandler(newRequest)
        
    }
    var taskWillPerformHTTPRedirection: ((URLSession, URLSessionTask, HTTPURLResponse, URLRequest) -> URLRequest?)?
    //身份认证
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.previousFailureCount  == 0 else {
            challenge.sender?.cancel(challenge)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let preferencesName = "78"
        let preferencesPassword = "123456"
        
        
        let proposedCredential = URLCredential(user: preferencesName, password: preferencesPassword, persistence: .none)
        completionHandler(.useCredential, proposedCredential)
        
    }
    
    //缓存
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
       
        
    }
    
    
    var completionHandlers: [String: CompletionHandler] = [:]
    
    
}
enum AFError: Error {
    case missingURL
    case jsonEncodingFailed
    case propertyListEncodingFailed
    func errorType() -> String {
        switch self {
        case .missingURL:
            return "missingURL"
        case .jsonEncodingFailed:
            return "jsonEncodingFailed"
        case .propertyListEncodingFailed:
            return "propertyListEncodingFailed"
        }
    }
}
extension AFError {
    public var isMissingURL: Bool {
        if case .missingURL = self {
            return true
        }
        return false
    }
}
