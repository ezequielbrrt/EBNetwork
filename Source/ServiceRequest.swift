//
//  ServiceRequest.swift
//  EBNetwork
//
//  Created by beTech CAPITAL on 6/21/19.
//

import UIKit
import Foundation
import SystemConfiguration

//Requiered Protocl methods
public protocol ResponseServicesProtocol: class
{
    func onSucces(result : Any, name : String, httpStatus: Int?)
    
    func onError(error : String, name : String, httpStatus: Int?)
    
    func slowConnection()
}

public class ServiceRequest: NSObject{
    weak var delegate : ResponseServicesProtocol?
    weak var controller : UIViewController?
    var currentService : String?
    var timer : Timer?
    var seconds : Int?
    var requestDone = false
    
    static var SECONDS_TO_SHOW_SLOW_CONNECTION = 6
    
    override init(){
        super.init()
    }
    
    public init(delegate: ResponseServicesProtocol, service : String){
        self.delegate = delegate;
        self.currentService = service
        self.controller = delegate as? UIViewController
        super.init()
    }
    
    //GET Method
    public func RequestGET(URLString : String){
        print("\n")
        print("Request(GET) " + URLString)
        var Request = URLRequest(url: URL(string: URLString)!)
        Request.httpMethod = "GET"

        if hasInternet(){
            requestTimer()
            ExecuteTask(Request: Request)
        }
        else {
            notInternetAlert()
        }
    }
    
    //POST Method
    public func RequestPOST(Parameters : NSDictionary, URLString : String){
        print("\n")
        print("Request(POST) " + URLString);
        var Request = URLRequest(url: URL(string: URLString)!)
        Request.httpMethod = "POST"
        Request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postString : String? = "";
        
        if Parameters.count != 0{
            postString! = try! DictionaryToJSONData(jsonObject: Parameters)!
            print("with Body:\n"+postString!)
        }
        
        Request.httpBody = postString?.data(using: .utf8)
        
        if hasInternet(){
            requestTimer()
            ExecuteTask(Request: Request)
        }
        else {
            notInternetAlert()
        }
        
    }
    
    //PUT Method
    func RequestPUT(Parameters : NSDictionary, URLString : String){
        print("\n")
        print("Request(PUT) " + URLString);
        var Request = URLRequest(url: URL(string: URLString)!)
        Request.httpMethod = "PUT"
        Request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postString : String? = "";
        
        if Parameters.count != 0
        {
            postString! = try! DictionaryToJSONData(jsonObject: Parameters)!
            
            print("with Body:\n"+postString!)
        }
        
        Request.httpBody = postString?.data(using: .utf8)
        
        if self.hasInternet(){
            requestTimer()
            ExecuteTask(Request: Request)
        }
        else {
            notInternetAlert()
        }
        
    }
    
    //DELETE Method
    func RequestDELETE(Parameters : NSDictionary, URLString : String)
    {
        print("\n")
        print("Request(POST) " + URLString);
        var Request = URLRequest(url: URL(string: URLString)!)
        Request.httpMethod = "DELETE"
        
        Request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postString : String? = "";
        
        if Parameters.count != 0{
            postString! = try! DictionaryToJSONData(jsonObject: Parameters)!
            print("with Body:\n"+postString!)
        }
        
        Request.httpBody = postString?.data(using: .utf8)
        
        if hasInternet(){
            requestTimer()
            ExecuteTask(Request: Request)
        }
        else {
            notInternetAlert()
        }
        
    }
    
    func notInternetAlert(){
        print("No connection available") //ZEP
        self.delegate?.onError(error: "conexion", name : self.currentService!, httpStatus: nil)
    }
    
    func requestTimer(){
        requestDone = false
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func countDown(){
        if timer == nil{
            return
        }
        
        if seconds == nil{
            seconds = -1
        }
        
        seconds = seconds! + 1
        print("Conection time: " + String(describing: seconds))
        
        //if self.currentService != ServiceName.uploadFile {
            
        if seconds == ServiceRequest.SECONDS_TO_SHOW_SLOW_CONNECTION && requestDone == false{
            if (self.controller != nil){
                print("slow connection")
                self.delegate?.slowConnection()
            }
        }
        
        //}
//        else {
//
//            if seconds == 30 && requestDone == false {
//                if (self.controller != nil)
//                {
//                    print("slow connection")
//                }
//            }
//        }
        
        if requestDone == true{
            timer?.invalidate()
            timer = nil
            seconds = nil
        }
        
    }
    
    
    //Request Task
    func ExecuteTask(Request : URLRequest)
    {
        let task = URLSession.shared.dataTask(with: Request) { data, response, error in
            let httpStatus = response as? HTTPURLResponse
            
            if httpStatus != nil {
                print("HTTP STATUS: " + httpStatus!.statusCode.description + "\n\n")
            }
            
            guard let data = data, error == nil else{
                self.requestDone = true
                print("Error (😔😢😭)")
                print("FATAL ERROR:\n\(String(describing: error!))")
                self.delegate?.onError(error: "Strings.serverError", name : self.currentService!, httpStatus: httpStatus!.statusCode)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 404{
                
                //OnSuccess with error
                self.requestDone = true
                print("OK (😯😄😃)")
                let responseString = String(data: data, encoding: .utf8)
                print("Result:\n \(String(describing: responseString!))")
                
                var dataResult : NSDictionary?
                
                if self.JSONDataToDiccionary(text: responseString!) != nil {
                    dataResult = self.JSONDataToDiccionary(text: responseString!)! as NSDictionary
                }
                
                    
                if dataResult != nil {
                    let content : NSDictionary? = dataResult
                    var message : String?
                    if content == nil {
                        message = "Strings.serverError"
                    }
                    message = content?.object(forKey: "error_message") as? String
                    if message == nil {
                        message = "Strings.serverError"
                    }
                    self.delegate?.onError(error: message!, name : self.currentService!, httpStatus: httpStatus.statusCode)
                    return
                } else {
                    print("Error (😔😢😭)")
                    print("FATAL ERROR:\n")
                    self.delegate?.onError(error: "Strings.serverError", name : self.currentService!,
                    httpStatus: httpStatus.statusCode)
                    return
                }
                
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 400
            {
                //OnSuccess with error
                self.requestDone = true
                print("OK (😯😄😃)")
                let responseString = String(data: data, encoding: .utf8)
                print("Result:\n \(String(describing: responseString!))")
                
                self.delegate?.onError(error: String(describing: responseString!), name: self.currentService!,
                httpStatus: httpStatus.statusCode)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 202
            {
                //OnSuccess with error
                self.requestDone = true
                print("OK (😯😄😃)")
                let responseString = String(data: data, encoding: .utf8)
                print("Result:\n \(String(describing: responseString!))")
                
                let dataResult : NSDictionary = self.JSONDataToDiccionary(text: responseString!)! as NSDictionary
                
                let error_description : String? = dataResult.object(forKey: "error") as? String
                if error_description != nil{
                    self.delegate?.onError(error: error_description!, name: self.currentService!,
                    httpStatus: httpStatus.statusCode)
                }
                else{
                    self.delegate?.onError(error: "Strings.serverError", name: self.currentService!,
                    httpStatus: httpStatus.statusCode)
                }
                
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 ||  httpStatus.statusCode == 201
            {
                
                //OnSuccess
                self.requestDone = true
                print("OK (😯😄😃)")
                let responseString = String(data: data, encoding: .utf8)
                
                let result : ResultModel = ResultModel();
                result.success = false
                result.content = ""
                result.api_version = ""
                result.code = httpStatus.statusCode
                
                if self.JSONDataToDiccionary(text: responseString!) != nil
                {
                    print("\nBACKEND JSON RESULT:\n\n" + responseString!)
                    
                    let dataResult : NSDictionary = self.JSONDataToDiccionary(text: responseString!)! as NSDictionary
                    
                    result.success = true
                    result.content = dataResult
                    result.api_version = dataResult.object(forKey: "api_version") as? String
                }
                else
                {
                    
                    result.success = true
                    if responseString != ""
                    {
                        let responseString2 = "{\"data\": " + responseString! + "}"
                        print("\nBACKEND JSONARRAY RESULT:\n\n" + responseString2)
                        
                        if responseString  != "\"\""
                        {
                            if responseString!.contains("doctypehtml") {
                                self.requestDone = true
                                print("Error (😣😖😵)")
                                print("response = \(String(describing: response!))")
                                self.notInternetAlert()
                                self.delegate?.onError(error: "Strings.serverError", name : self.currentService!, httpStatus: httpStatus.statusCode)
                                return
                                
                            }else{
                                let dataResult : NSDictionary = self.JSONDataToDiccionary(text: responseString2)! as NSDictionary
                                let array : [NSDictionary] = dataResult.object(forKey: "data") as! [NSDictionary]
                                result.content = array
                            }
                        } else {
                            result.content = "Ok"
                        }
                        
                    }
                    
                }
                
                if result.success == true
                {
                    self.delegate?.onSucces(result: result, name : self.currentService!,
                    httpStatus: httpStatus.statusCode)
                }
                else
                {
                    let errorString : String = result.content as! String
                    self.delegate?.onError(error: errorString, name: self.currentService!,
                    httpStatus: httpStatus.statusCode)
                }
                
            }
            else
            {
                //OnError
                self.requestDone = true
                print("Error (😣😖😵)")
                //print("Status Code: \(httpStatus.statusCode)")
                //print("\nDescription error:\(String(describing: error!))")
                print("response = \(String(describing: response!))")
                self.delegate?.onError(error: "Strings.serverError", name : self.currentService!,
                                       httpStatus: httpStatus?.statusCode)
            }
            
        }
        
        task.resume()
    }
    
    
    // MARK: Helper functions
    func hasInternet() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func JSONDataToDiccionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func DictionaryToJSONData(jsonObject: AnyObject) throws -> String?{
        let data: NSData? = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
        
        var jsonStr: String?
        if data != nil {
            jsonStr = String(data: data! as Data, encoding: String.Encoding.utf8)
        }
        
        return jsonStr
    }
}
