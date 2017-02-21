//
//  KPersonService.swift
//  Harpy
//
//  Created by Erik Underbjerg on 21/02/2017.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import Foundation

class KPersonService {
    
    
    static let endpoint = "http://e3456c5e.ngrok.io/find_person"
    
    
    static func findPersonBy(name: String, office: String, successHandler: @escaping ([KPerson]) -> Void)  {
        let requestURL = URL(string: "\(endpoint)?name=\(name)&\(office)")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        
        let session = URLSession.shared
        let task = session.dataTask(with: requestURL) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
                    if let array = json as? [Any] {
                        print("Received response with \(array.count) persons")
                        
                        var resultPersons = [KPerson]()
                        
                        for entry in array {
                            if let personDictionary = entry as? [String:Any] {
                                let person = KPerson(json: personDictionary)
                                resultPersons.append(person)
                            }
                        }
                        
                        successHandler(resultPersons)
                    }
                }catch {
                    print("Error with Json: \(error)")
                }
                
            } else {
                print("Received error from backend: \(statusCode)")
            }
        }
        
        task.resume()
    }
    
}
