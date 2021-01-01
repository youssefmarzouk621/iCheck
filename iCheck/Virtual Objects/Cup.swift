//
//  Cup.swift
//  iCheck
//
//  Created by Youssef Marzouk on 29/12/2020.
//

import Foundation

class Cup: VirtualObject {

    override init() {
        super.init(modelName: "cup", fileExtension: "scn", thumbImageFilename: "cup", title: "Cup")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
