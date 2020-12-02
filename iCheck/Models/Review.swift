//
//  Review.swift
//  iCheck
//
//  Created by Youssef Marzouk on 29/11/2020.
//

import Foundation

struct Review:Decodable {
    var _id:String
    var review:String
    var user:Customer
    var rate:Double
}
