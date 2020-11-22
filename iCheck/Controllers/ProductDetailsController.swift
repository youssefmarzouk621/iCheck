//
//  ProductDetailsController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 21/11/2020.
//

import UIKit

class ProductDetailsController: UIViewController {
    
    var Prod:Product?
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productImage.image = UIImage(named: Prod!.image)
        productName.text = Prod!.name
        productDescription.text = Prod!.description
    }
    

}
