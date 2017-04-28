//
//  APIAIService.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import Foundation
import ApiAI
import Speech
import AVKit

class APIAIService{
    
    let synth = AVSpeechSynthesizer()
    var speak = false
    
    init(){
        
    }
    
    func performTextRequest(message: String, success: @escaping ([Comment]) -> Void, failure: () -> ()){
        let textRequest =  (UIApplication.shared.delegate as! AppDelegate).apiAI?.textRequest()
        textRequest?.query = message
        
        textRequest?.setCompletionBlockSuccess({ (request, response) in
            print(response ?? "No response")
            if let json = response as? [String:Any]{
                let paramsArray = self.getParamsFromJSON(json: json)
                print(paramsArray)
                var commentArray = [Comment]()
                for params in paramsArray{
                    var commentString = ""
                    if let message = params.message{
                        commentString = message
                        if (commentString != "Unknown comment") {
                            self.speakText(text: commentString)
                        }
                    }
                    commentArray.append(Comment(date: Date(), commentString: commentString, isServerResponse: true, isBankIdRequest: params.isBankIdRequest, replies: params.replies))
                    
                }
                DispatchQueue.main.async {
                    success(commentArray)
                }
            }
        }, failure: { (request, error) in
            print(error ?? "No error")
        })
        (UIApplication.shared.delegate as! AppDelegate).apiAI?.enqueue(textRequest)
        
    }
    
    private func getParamsFromJSON(json: [String:Any]) -> [(message: String?, isBankIdRequest: Bool?, replies: [String]?)]{
        var message: String?
        //TODO: get office
        var isBankIdRequest: Bool?
        
        if let result = json["result"] as? [String:Any]{
            if let fulfillment = result["fulfillment"] as? [String:Any]{
                if let messagesArray = fulfillment["messages"] as? [[String:Any]], messagesArray.count > 1{
                    var returnArray = [(message: String?, isBankIdRequest: Bool?, replies: [String]?)]()
                    for m in messagesArray{
                        var messageString = "Unknown comment"
                        var repliesArray: [String]?
                        if let speech = m["speech"] as? String{
                            messageString = speech
                        }
                        if let replies = m["replies"] as? [String]{
                            repliesArray = replies
                        }
                        returnArray.append((message: messageString, isBankIdRequest: false, replies: repliesArray))
                    }
                    return returnArray
                }else if let speech = fulfillment["speech"] as? String{
                    message = speech
                }
            }
            if let action = result["action"] as? String{
                if action == "bankid_block" {
                    isBankIdRequest = true
                }
            }

        }
        return [(message: message, isBankIdRequest: isBankIdRequest, replies: nil)]
    }
    
    private func getMessageAndAction(json: [String:Any]){
        
    }
    
    func speakText(text:String) {
        if (!speak) {
            return
        }
        debugPrint("About to speak text...")
            debugPrint("text: \(text)")
            //            if !synth.isSpeaking {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            let utterance = AVSpeechUtterance(string: text)
            synth.speak(utterance)
        
    }
}
