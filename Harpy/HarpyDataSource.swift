//
//  HarpyDataSource.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import Foundation
import AVFoundation

class HarpyDataSource{
    var comments = [Comment]()
    
    
    init(){
        comments.append(Comment(date: Date(), commentString: "Hi! I’m Ingvar. I’m actually a robot, but I’ll help you with any questions you may have!", isServerResponse: true, isBankIdRequest: false, isDefaultFallback: false, replies: nil))
        
        comments.append(Comment(date: Date(), commentString: "Do you need help with one of the following? Login, pin code, loans, phishing, cards, fund transfer", isServerResponse: true, isBankIdRequest: false, isDefaultFallback: false, replies: nil))
    }
    
    func addNewComment(message: String){
        comments.append(Comment(date: Date(), commentString: message, isServerResponse: false, isBankIdRequest: false, isDefaultFallback: false, replies: nil))
    }
    
    func addNewCommentObject(comment: Comment){
        comments.append(comment)
    }
    
    func removeAllBankRequest() {
        comments.forEach { comment in
            comment.isBankIdRequest = false
        }
    }
    
}
