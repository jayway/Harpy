//
//  Comment.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import Foundation

class Comment: NSObject{
    var date: Date!
    var commentString: String!
    var isServerResponse = false
    var isBankIdRequest = false
    var isDefaultFallback = false
    var replies: [String]?
    init(date: Date, commentString: String, isServerResponse: Bool, isBankIdRequest: Bool?, isDefaultFallback: Bool?, replies: [String]?){
        super.init()
        self.date = date
        self.commentString = commentString
        self.isServerResponse = isServerResponse
        self.isBankIdRequest = isBankIdRequest ?? false
        self.isDefaultFallback = isDefaultFallback ?? false
        self.replies = replies
    }
    
}
