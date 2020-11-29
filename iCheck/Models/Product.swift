//
//  Product.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import Foundation

struct Product :Decodable{
    var _id:String
    var name:String
    var description:String
    var image:[String]
    var brand:String
    var category:String
    var address:String
    var available:String
    var rate:String
    var reviews:[Review]
}
