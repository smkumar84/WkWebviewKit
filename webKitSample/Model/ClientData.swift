//
//  UserData.swift
//  webKitSample
//
//  Created by Mahesh on 03/02/21.
//  Copyright © 2021 Mahesh. All rights reserved.
//

import Foundation


class ClientData {
    var companyID : String = ""
    var userID : String = ""
    var accessToken : String = ""
    
    
    init(_ companyID:String , _ userID:String , _ accessToken : String) {
        self.companyID = companyID
        self.userID = userID
        self.accessToken = accessToken
    }
}
