//
//  ViewController.swift
//  Http同步请求
//
//  Created by 郑小燕 on 2017/12/18.
//  Copyright © 2017年 郑小燕. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLConnectionDataDelegate {
    
    var responseNew: HTTPURLResponse?
    var progressFloat: Float = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //最简单的同步请求
        let data = NSData(contentsOf: URL(string: "http://domain.com/a.png")!)
        //http同步请求
        //        self.requestBySync()
        // http异步队列请求
        //        self.requestByAsyncQueue()
        //        self.nornalHttpRequest()
//                self.download()
//        self.upload()
        print("1")
        print("2")
        defer {
            print("3")
        }
        print("4")
        print("5")
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.present(URLSessionViewController(), animated: true, completion: nil)
    }
    
    
    
    
    func requestBySync() {
        let req = URLRequest(url: URL(string: "https://www.cqcb.com/newlist42.html")!)
        var resp: URLResponse?
        do {
            let data = try NSURLConnection.sendSynchronousRequest(req, returning: &resp)
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(prinfLog), userInfo: nil, repeats: true)
            self.sleep(time: 10)
            print( try JSONSerialization.jsonObject(with: data, options: .allowFragments))
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    func requestByAsyncQueue() {
        let req = URLRequest(url: URL(string: "https://www.cqcb.com/newlist42.html")!)
        let queue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(req, queue: queue) { (response, data, error) in
            
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.prinfLog), userInfo: nil, repeats: true)
            self.sleep(time: 10)
            if error != nil {
                print("错误 = \(error)")
                return
            } else {
                
                do {
                    let jsonData = try  JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    print("jsonData = \(jsonData)")
                } catch let error as NSError {
                    print("error = \(error)")
                }
            }
            
        }
        
        
        
    }
    
    //普通http请求
    func nornalHttpRequest() {
        let urlString = "https://www.cqcb.com/newlist42.html"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        let request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        //        let configuration = URLSessionConfiguration()
        //        configuration.
        //        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: <#T##OperationQueue?#>)
        let connection = NSURLConnection(request: request, delegate: self)
        connection?.start()
        
        
        
        
        
    }
    
    //下载文件流
    func download() {
        let urlString = "https://image2.cqcb.com/d/file/p/2017-12-18/56e2481b86f89a5f033942bd51247a1c.jpg"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        let request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        let connection = NSURLConnection(request: request, delegate: self)
        connection?.start()
        
        
        
    }
    
    //上传文件和进度
    func upload() {
        let dataurl = URL(fileURLWithPath: Bundle.main.path(forResource: "IMG_0006", ofType: "JPG")!)
        let data = try? Data(contentsOf: dataurl)
        //string 转 url编码
        let urlString = "https://image.cqcb.com/e/member/upload_userpic.php"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        //设置请求头
        var body = Data()
        let dic: NSDictionary = ["enews": "uploadimg", "formFile": data, "size": data?.count]
        let dataNew: Data = try!JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        
        body.append(dataNew)
        /*
         /文件参数
         // 参数开始的标志
         [body appendData:Encode(@"--YY\r\n")];
         // name : 指定参数名(必须跟服务器端保持一致)
         // filename : 文件名
         NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", @"1.jpg"];
         [body appendData:Encode(disposition)];
         NSString *type = [NSString stringWithFormat:@"Content-Type: %@\r\n", @"multipart/form-data"];
         [body appendData:Encode(type)];
         [body appendData:Encode(@"\r\n")];
         
         //添加图片数据
         [body appendData:data];
         [body appendData:Encode(@"\r\n")];
         //结束符
         [body appendData:Encode(@"--YY--\r\n")];
         */
        //把body添加到request中
        request.httpBody = body
        
        //请求体的长度
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        //声明这个POST请求是个文件上传
        //        request.setValue("multipart/form-data; boundary=YY", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let connection = NSURLConnection(request: request, delegate: self)
        connection?.start()
    }
    
    
    
    //delegate
    //请求失败
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("error = \(error)")
    }
    
    //重定向
    func connection(_ connection: NSURLConnection, willSend request: URLRequest, redirectResponse response: URLResponse?) -> URLRequest? {
        print("request: \(request)")
        return request
    }
    
    //接收响应
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        if let resp = response as? HTTPURLResponse {
            print("response == \(resp)")
            self.responseNew = resp
            print("======\(resp.allHeaderFields)")
        }
    }
    
    //接收响应
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        print("==============didReceiveData========")
        print("data.length: \(data.count)")
        let progress = self.downloadProgress(length: data.count)
        print("------progress = \(progress)--------")
        //        do {
        //            let jsonData = try  JSONSerialization.jsonObject(with: data, options: .allowFragments)
        //            print("jsonData = \(jsonData)")
        //        } catch let error as NSError {
        //            print("error = \(error)")
        //        }
    }
    
    //上传数据委托，用于显示上传进度
    func connection(_ connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        print("==========totalBytesWritten==========")
        print("didSendBodyData:bytesWritten = \(bytesWritten) --totalBytesWritten = \(totalBytesWritten)--totalBytesExpectedToWrite = \(totalBytesExpectedToWrite)")
        //进度
        let progress: Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
    }
    
    //完成请求
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        print("===============connectionDidFinishLoading===============")
    }
    
    //MARK: - https认证
    func connectionShouldUseCredentialStorage(_ connection: NSURLConnection) -> Bool {
        print("==============connectionShouldUseCredentialStorage==========")
        return true
    }
    
    func connection(_ connection: NSURLConnection, willSendRequestFor challenge: URLAuthenticationChallenge) {
        print("==============willSendRequestForAuthenticationChallenge=======")
        print("didReceiveAuthenticationChallenge \(challenge.protectionSpace.authenticationMethod)====\(challenge.previousFailureCount)")
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            challenge.sender?.use(URLCredential(trust: challenge.protectionSpace.serverTrust!), for: challenge)
            challenge.sender?.continueWithoutCredential(for: challenge)
        }
        
    }
    
    func downloadProgress(length: Int) -> Float {
        self.progressFloat = self.progressFloat + Float(length)
        if responseNew != nil {
            
            if let allLength = responseNew?.allHeaderFields["Content-Length"]  {
                
                let str: String = (allLength as? String)!
                print("======\(allLength)===")
                
                return self.progressFloat / Float(str)!
                //                return 0
            }
            return 1.0
        }
        return 2.0
        
        
    }
    
    //cookie
    func getCookie() {
        //获取服务端返回的cookie
        let headers = responseNew?.allHeaderFields
        print("headers: \(headers)")
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers as! [String : String], for: URL(string: "https://www.cqcb.com/")!)
        
        //获取客户端存储的cookie
        let httpCookiesStorage = HTTPCookieStorage.shared
        let cookiesSave = httpCookiesStorage.cookies(for: URL(string: "https://www.cqcb.com/")!)
        for cookie in cookiesSave! {
            print("cookie: \(cookie)")
        }
        
        let prop1 = [HTTPCookiePropertyKey.name: "a", HTTPCookiePropertyKey.value: "aaa", HTTPCookiePropertyKey.path: "/", HTTPCookiePropertyKey.originURL: URL(string: "https://www.cqcb.com/")!, HTTPCookiePropertyKey.expires: Date(timeIntervalSinceNow: 60)] as [HTTPCookiePropertyKey : Any]
        
        let prop2 = [HTTPCookiePropertyKey.name: "b", HTTPCookiePropertyKey.value: "bbb", HTTPCookiePropertyKey.path: "/", HTTPCookiePropertyKey.originURL: URL(string: "https://www.cqcb.com/")!, HTTPCookiePropertyKey.expires: Date(timeIntervalSinceNow: 60)] as [HTTPCookiePropertyKey : Any]
        let cookie1 = HTTPCookie(properties: prop1)
        let cookie2 = HTTPCookie(properties: prop2)
        //批量设置
        let cookiesCreate = [cookie1, cookie2]
        HTTPCookieStorage.shared.setCookies(cookiesCreate as! [HTTPCookie], for: URL(string: "https://www.cqcb.com/")!, mainDocumentURL: nil)
    }
    
    //客户端删除cookie
    func deleteCookie(cookieName: String, url: URL) {
        let cookies = HTTPCookieStorage.shared.cookies(for: url)
        for cookie in cookies! {
            if cookie.name == cookieName {
               HTTPCookieStorage.shared.deleteCookie(cookie)
                print("删除cookie: \(cookieName)")
            }
        }
        
    }
//    func deleteCookies() {
//        let cookies = HTTPCookieStorage.shared.cookies
//        
//        for cookie in cookies! {
//            HTTPCookieStorage.shared.deleteCookie(cookie)
//        }
//    }
    
    
    
    
    
    
    func sleep(time: TimeInterval) {
        print("=====================================")
        Thread.sleep(forTimeInterval: time)
    }
    @objc func prinfLog() {
        print("===================================间歇")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

