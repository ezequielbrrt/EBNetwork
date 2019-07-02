//
//  ViewController.swift
//  EBNetwork
//
//  Created by ezequielbrrt on 06/21/2019.
//  Copyright (c) 2019 ezequielbrrt. All rights reserved.
//

import UIKit
import EBNetwork

enum CompassPoint {
    case north
    case south
    case east
    case west
}

class ViewController: UIViewController, ResponseServicesProtocol {
    func onSucces(result: Any, name: Any, httpStatus: Int?) {
        print("onSucces")
        print(name)
    }
    
    func onError(error: String, name: Any, httpStatus: Int?) {
        print("onError")
        print(name)
        if name as! CompassPoint == CompassPoint.east{
            print("is the same")
        }
        
    }
    
    
    func slowConnection() {
        print("slowConnection")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        let client = ServiceRequest.init(delegate: self, service: CompassPoint.east)
        //client.RequestGET(URLString: "https://polls.apiblueprint.org/questions")
        
        let data = NSDictionary.init(objects: ["",
                                               "password",
                                               "token",
                                               "IOS"],
                                     forKeys: ["username" as NSCopying,
                                               "password" as NSCopying,
                                               "token" as NSCopying,
                                               "device" as NSCopying])
        
        client.RequestPOST(Parameters: data, URLString: "https://polls.apiblueprint.org/questions")
    }
    

}

