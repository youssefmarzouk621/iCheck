//
//  Friendship.swift
//  iCheck
//
//  Created by Youssef Marzouk on 10/01/2021.
//

import Foundation


struct Friendship:Decodable {
    var _id:String
    var Accepted:Int
    var user:Customer
}
