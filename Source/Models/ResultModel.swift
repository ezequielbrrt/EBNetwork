//
//  ResultModel.swift
//  EBNetwork
//
//  Created by Ezequiel Barreto on 6/21/19.
//

class ResultModel: NSObject
{
    var success : Bool?
    var content : Any?
    var api_version : String?
    var code : Int?
    
    func toString() -> String
    {
        let SSucces : String = "success :" + String(success!) + "\n"
        let SContent : String = "content :" + String(describing: content!)
        let SApi : String =  "api_version :" + api_version!  + "\n"
        let all : String = SSucces + SApi + SContent
        return all;
    }
}
