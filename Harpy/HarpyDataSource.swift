//
//  HarpyDataSource.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import Foundation

class HarpyDataSource{
    var comments = [Comment]()
    
    init(){
        comments.append(Comment(date: Date(), commentString: "Hi! I’m Ingvar. I’m actually a robot, but I’ll help you with any questions you may have!", isServerResponse: true, isBankIdRequest: false, replies: nil))
        comments.append(Comment(date: Date(), commentString: "What can I do for you?", isServerResponse: true, isBankIdRequest: false, replies: nil))
    }
    
    func addNewComment(message: String){
        comments.append(Comment(date: Date(), commentString: message, isServerResponse: false, isBankIdRequest: false, replies: nil))
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
