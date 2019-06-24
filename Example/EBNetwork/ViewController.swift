//
//  ViewController.swift
//  EBNetwork
//
//  Created by ezequielbtc on 06/21/2019.
//  Copyright (c) 2019 ezequielbtc. All rights reserved.
//

import UIKit
import EBNetwork

class ViewController: UIViewController, ResponseServicesProtocol {
    func onSucces(result: Any, name: String, httpStatus: Int?) {
        print("onSucces")
    }
    
    func onError(error: String, name: String, httpStatus: Int?) {
        print("onError")
    }
    
    func slowConnection() {
        print("slowConnection")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let client = ServiceRequest.init(delegate: self, service: "login")
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

