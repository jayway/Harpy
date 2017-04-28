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
                    commentArray.append(Comment(date: Date(), commentString: commentString, isServerResponse: true, isBankIdRequest: params.isBankIdRequest, isDefaultFallback: params.isDefaultFallback, replies: params.replies))
                    
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
    
    private func getParamsFromJSON(json: [String:Any]) -> [(message: String?, isBankIdRequest: Bool?, isDefaultFallback: Bool?, replies: [String]?)]{
        var message: String?
        //TODO: get office
        var isBankIdRequest: Bool?
        var isDefaultFallback: Bool?
        
        if let result = json["result"] as? [String:Any]{
            if let action = result["action"] as? String? {
                isDefaultFallback = action == "input.unknown"
            }
            if let fulfillment = result["fulfillment"] as? [String:Any]{
                if let messagesArray = fulfillment["messages"] as? [[String:Any]], messagesArray.count > 1{
                    var returnArray = [(message: String?, isBankIdRequest: Bool?, isDefaultFallback:Bool?, replies: [String]?)]()
                    for m in messagesArray{
                        var messageString = "Unknown comment"
                        var repliesArray: [String]?
                        if let speech = m["speech"] as? String{
                            messageString = speech
                        }
                        if let replies = m["replies"] as? [String]{
                            repliesArray = replies
                        }
                        returnArray.append((message: messageString, isBankIdRequest: false, isDefaultFallback: isDefaultFallback, replies: repliesArray))
                    }
                    return returnArray
                }else if let speech = fulfillment["speech"] as? String{
                    message = speech
                }
            }
            if let action = result["action"] as? String{
                if action == "bankid_block" || action == "disable-payments-abroad"  || action == "enable_payments_abroad" {
                    isBankIdRequest = true
                }
            }

        }
        return [(message: message, isBankIdRequest: isBankIdRequest, isDefaultFallback:isDefaultFallback, replies: nil)]
    }
    
    private func getMessageAndAction(json: [String:Any]){
        
    }
    
    func speakText(text:String) {
        if (!speak) {
            return
        }
        let types: NSTextCheckingResult.CheckingType = .link
        
        let detector = try? NSDataDetector(types: types.rawValue)
        
        guard let detect = detector else { return }
        
        let matches = detect.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.characters.count))
        var textToSpeak = text
        matches.forEach { (match) in
            if  let url = match.url {
                textToSpeak = textToSpeak.replacingOccurrences(of: url.absoluteString, with: "")
            }
        }
        
        debugPrint("About to speak text...")
            debugPrint("text: \(textToSpeak)")
        
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            let utterance = AVSpeechUtterance(string: textToSpeak)
            synth.speak(utterance)
        
    }
}
