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
    
    func performTextRequest(message: String, success: () -> (), failure: () -> ()){
        let textRequest =  (UIApplication.shared.delegate as! AppDelegate).apiAI?.textRequest()
        textRequest?.query = message
        
        textRequest?.setCompletionBlockSuccess({ (request, response) in
            print(response ?? "No response")
        }, failure: { (request, error) in
            print(error ?? "No error")
        })
        (UIApplication.shared.delegate as! AppDelegate).apiAI?.enqueue(textRequest)
        
    }
    
}
