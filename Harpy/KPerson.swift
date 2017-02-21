//
//  KPerson.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import Foundation

class KPerson{
    
    let name : String?
    let office : String?
    
    init(json: [String:Any]){
        
        name = "\(json["first_name"] ?? "") \(json["last_name"] ?? "")"
        if let company = json["company"] as? [String:Any] {
            office = company["name"] as? String
        } else {
            office = nil
        }
    }
}
