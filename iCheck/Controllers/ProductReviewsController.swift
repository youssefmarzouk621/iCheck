//
//  ProductReviewsController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 05/12/2020.
//

import UIKit

class ProductReviewsController: UIViewController {
    var Prod:Product?
    //outlets
    @IBOutlet weak var Reviews: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "reviewCell")
        return cv
    }()
    
    //variables
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        
        Reviews.delegate = self
        Reviews.dataSource = self
        
        let parameters = ["prodId" : Prod?._id]
        guard let url = URL(string: baseURL+"api/products/getProductReviews") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.Prod?.reviews = try JSONDecoder().decode([Review].self, from: data!)
                    /*let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("before parse")
                    print(json)*/
                } catch {
                    print("parse reviews json error")
                }
        
                DispatchQueue.main.async {
                    self.Reviews.reloadData()
                }
            }
        }.resume()
    }

}


extension ProductReviewsController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 373, height:81)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Prod!.reviews!.count
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath)
        let contentView = cell.contentView
        let avatar = contentView.viewWithTag(1) as! UIImageView
        let userName = contentView.viewWithTag(2) as! UILabel
        let review = contentView.viewWithTag(3) as! UILabel
        let rateView = contentView.viewWithTag(4) as! UIView
        let rating = rateView.viewWithTag(5) as! UILabel
        
        
        
        let avatarUrl = baseURL + "uploads/users/" + Prod!.reviews![indexPath.row].user.avatar
        avatar.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])

        userName.text = Prod!.reviews![indexPath.row].user.firstName+" "+Prod!.reviews![indexPath.row].user.lastName
        review.text = Prod!.reviews![indexPath.row].review
        
        rateView.layer.cornerRadius = 5
        
        rating.text = String(format: "%.1f", Prod!.reviews![indexPath.row].rate)
        
        return cell
    }
    
    
}
