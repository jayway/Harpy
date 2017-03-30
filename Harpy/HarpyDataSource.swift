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
        comments.append(Comment(date: Date(), commentString: "Hey! What do you need help with today?", isServerResponse: true, isBankIdRequest: false))
    }
    
    func addNewComment(message: String){
        comments.append(Comment(date: Date(), commentString: message, isServerResponse: false, isBankIdRequest: false))
    }
    
    func addNewCommentObject(comment: Comment){
        comments.append(comment)
    }
}
