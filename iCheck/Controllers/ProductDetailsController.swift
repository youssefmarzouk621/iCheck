//
//  ProductDetailsController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 21/11/2020.
//

import UIKit


class ProductDetailsController: UIViewController {

    var Prod:Product?
    
    /*var reviewsList = [Review(_id: "idreview", review: "testing", user: Customer(_id: "rrr", firstName: "youssef", lastName: "marzouk", email: "youssef", password: "eee", phone: "eee", sexe: "gggg", avatar: "youssef.marzouk"), rate: "7")]*/
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    @IBOutlet weak var moreImages: UIButton!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    
    @IBOutlet weak var Reviews: UITableView!
    
    
    @IBOutlet weak var productImages: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "productImgCell")
        
        return cv
    }()
    
    
    
    @IBAction func moreImagesAction(_ sender: UIButton) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productImages.delegate = self
        productImages.dataSource = self
        
        Reviews.delegate = self
        Reviews.dataSource = self
        
        moreImages.setTitle("See all("+String(Prod!.image.count)+")", for: .normal)
        
        
        let productUrl = baseURL + "uploads/products/" + Prod!.image[0]
        productImage.downloaded(from: productUrl)
        productImage.contentMode = .scaleAspectFill
        productName.text = Prod!.name
        productDescription.text = Prod!.description
    }
    

}






extension ProductDetailsController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Prod!.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell")
        let contentView = cell?.contentView
        let avatar = contentView?.viewWithTag(1) as! UIImageView
        let userName = contentView?.viewWithTag(2) as! UILabel
        let review = contentView?.viewWithTag(3) as! UILabel
        let rateView = contentView?.viewWithTag(4) as! UIView
        let rating = rateView.viewWithTag(5) as! UILabel
        
        
        
        let avatarUrl = baseURL + "uploads/users/" + Prod!.reviews[indexPath.row].user.avatar
        avatar.downloaded(from: avatarUrl)

        userName.text = Prod!.reviews[indexPath.row].user.firstName+" "+Prod!.reviews[indexPath.row].user.lastName
        review.text = Prod!.reviews[indexPath.row].review
        
        rateView.layer.cornerRadius = 5
        
        rating.text = Prod!.reviews[indexPath.row].rate
        
        return cell!
    }
}








extension ProductDetailsController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 181, height:128)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Prod!.image.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productImgCell", for: indexPath)
        
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 0.4
        cell.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        
        let contentView = cell.contentView
        let backgroundImage = contentView.viewWithTag(1) as! UIImageView
        
       
        let imgUrl = baseURL + "uploads/products/" + Prod!.image[indexPath.row]
        
        backgroundImage.downloaded(from: imgUrl)
        backgroundImage.contentMode = .scaleAspectFill
        
        return cell
    }
    

}
