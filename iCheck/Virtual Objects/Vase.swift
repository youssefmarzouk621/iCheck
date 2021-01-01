//
//  Vase.swift
//  iCheck
//
//  Created by Youssef Marzouk on 29/12/2020.
//

import Foundation

class Vase: VirtualObject {

    override init() {
        super.init(modelName: "vase", fileExtension: "scn", thumbImageFilename: "vase", title: "Vase")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

