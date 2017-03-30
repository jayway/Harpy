//
//  APIAIService.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import Foundation
import ApiAI

class APIAIService{
    
    init(){
        
    }
    
    func performTextRequest(message: String, success: @escaping (Comment) -> Void, failure: () -> ()){
        let textRequest =  (UIApplication.shared.delegate as! AppDelegate).apiAI?.textRequest()
        textRequest?.query = message
        
        textRequest?.setCompletionBlockSuccess({ (request, response) in
            print(response ?? "No response")
            if let json = response as? [String:Any]{
                let params = self.getParamsFromJSON(json: json)
                print(params)
                var commentString = ""
                if let message = params.message{
                    commentString = message
                }
                DispatchQueue.main.async {
                    success(Comment(date: Date(), commentString: commentString, isServerResponse: true))
                }
            }
        }, failure: { (request, error) in
            print(error ?? "No error")
        })
        (UIApplication.shared.delegate as! AppDelegate).apiAI?.enqueue(textRequest)
        
    }
    
    private func getParamsFromJSON(json: [String:Any]) -> (name: String?, office: String?, message: String?){
        var message: String?
        //TODO: get office
        var office: String?
        var name: String?
        if let result = json["result"] as? [String:Any]{
            if let fulfillment = result["fulfillment"] as? [String:Any]{
                if let speech = fulfillment["speech"] as? String{
                    message = speech
                }
            }
            if let parameters = result["parameters"] as? [String:Any]{
                if let n = parameters["name"] as? String{
                    name = n
                }
                if let c = parameters["city"] as? String{
                    office = c
                }
            }
        }
        return (name: name, office: office, message: message)
    }
    
}
