//
//  ProductDetailsController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 21/11/2020.
//

import UIKit
import CoreData
import Cosmos
class ProductDetailsController: UIViewController {

    var Prod:Product?
    var rateValue:Double=3
    var connectedUser:Customer = Customer(_id: "notyet", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "")
    public var backResponse:backendResponse = backendResponse(message: "")
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
    
    
    
    @IBOutlet weak var cosmosRating: CosmosView!
    @IBOutlet weak var rateDescription: UILabel!
    @IBOutlet weak var reviewField: UITextField!
    @IBAction func submitReview(_ sender: UIButton) {
        let reviewDescription = reviewField.text
        if reviewDescription == "" {
            let alert = UIAlertController(title: "review field is empty", message: "please fill your input", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else{
   
            print("prodId :"+self.Prod!._id)
            print("review :"+reviewDescription!)
            print("userId :"+connectedUser._id)
            print("rate :"+String(self.rateValue))
            
            
            
            
            
            let parameters = ["prodId" : self.Prod!._id, "review" : reviewDescription!, "userId" : connectedUser._id, "rate" : String(self.rateValue)]
            guard let url = URL(string: baseURL+"api/products/addReview") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody = httpBody
            var status = 0
            URLSession.shared.dataTask(with: request) { (data,response,error) in
                if error == nil{
                    do {
                        self.backResponse = try JSONDecoder().decode(backendResponse.self, from: data!)
                        let httpResponse = response as? HTTPURLResponse
                        status = httpResponse!.statusCode
                    } catch {
                        print("parse json error")
                    }
                    DispatchQueue.main.async {
                        if status == 200 {
                            print(self.backResponse)
                            let brandNew = Review(_id: "", review: reviewDescription!, user: self.connectedUser, rate: self.rateValue)
                            self.Prod!.reviews.append(brandNew)
                            self.Reviews.reloadData()
                            
                            self.rateDescription.text = "Good"
                            self.reviewField.text = ""
                            self.cosmosRating.rating = 3
                        }
                    }
                }
            }.resume()
            
            
            
        }
    }
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        productImages.delegate = self
        productImages.dataSource = self
        
        Reviews.delegate = self
        Reviews.dataSource = self
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Connected")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for obj in result {
                print("getting info from core data")
                self.connectedUser._id=(obj.value(forKey: "id") as! String)
                self.connectedUser.firstName=(obj.value(forKey: "firstName") as! String)
                self.connectedUser.lastName=(obj.value(forKey: "lastName") as! String)
                self.connectedUser.email=(obj.value(forKey: "email") as! String)
                self.connectedUser.password=(obj.value(forKey: "password") as! String)
                self.connectedUser.phone=(obj.value(forKey: "phone") as! String)
                self.connectedUser.sexe=(obj.value(forKey: "sexe") as! String)
                self.connectedUser.avatar=(obj.value(forKey: "avatar") as! String)
            }
            
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        moreImages.setTitle("See all("+String(Prod!.image.count)+")", for: .normal)
        
        let productUrl = baseURL + "uploads/products/" + Prod!.image[0]
        
        productImage.sd_setImage(with: URL(string: productUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        productImage.contentMode = .scaleAspectFill
        productName.text = Prod!.name
        productDescription.text = Prod!.description
        
        cosmosRating.didTouchCosmos = { rating in
            switch rating {
            case 1:
                self.rateDescription.text = "Bad"
            case 2:
                self.rateDescription.text = "Okay"
            case 3:
                self.rateDescription.text = "Good"
            case 4:
                self.rateDescription.text = "Great"
            case 5:
                self.rateDescription.text = "Amazing"
            default:
                self.rateDescription.text = "Good"
            }
            self.rateValue = rating
        }
        cosmosRating.didFinishTouchingCosmos = { rating in
            self.rateValue = rating
        }
        
        
        
        
        
        
        
        
        
        
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
        avatar.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])

        userName.text = Prod!.reviews[indexPath.row].user.firstName+" "+Prod!.reviews[indexPath.row].user.lastName
        review.text = Prod!.reviews[indexPath.row].review
        
        rateView.layer.cornerRadius = 5
        
        rating.text = String(Prod!.reviews[indexPath.row].rate)
        
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
        
        
        backgroundImage.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        backgroundImage.contentMode = .scaleAspectFill
        
        return cell
    }
    

}
