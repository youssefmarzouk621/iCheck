//
//  Lamp.swift
//  iCheck
//
//  Created by Youssef Marzouk on 29/12/2020.
//

import Foundation
import ARKit

class Lamp: VirtualObject {

    override init() {
        super.init(modelName: "lamp", fileExtension: "scn", thumbImageFilename: "lamp", title: "Lamp")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
