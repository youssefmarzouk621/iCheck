//
//  NotificationResponse.swift
//  iCheck
//
//  Created by Youssef Marzouk on 09/01/2021.
//

import Foundation








struct NotificationResponse:Decodable {
    var _id:String
    var receiver:Customer
    var title:String
    var description:String
    var image:String
    var type:String
    var link:String
}
