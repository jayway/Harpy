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
    var kPersons: [KPerson]?
    var isServerResponse = false
    init(date: Date, commentString: String, kPersons: [KPerson]?, isServerResponse: Bool){
        super.init()
        self.date = date
        self.commentString = commentString
        self.kPersons = kPersons
        self.isServerResponse = isServerResponse
    }
    
}
