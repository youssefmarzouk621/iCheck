//
//  ProductDetailsController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 21/11/2020.
//

import UIKit
import CoreData
import Cosmos


struct productDetails:Decodable {
    var product:Product
    var isLiked:String
}
class ProductDetailsController: UIViewController {

    var Prod:Product?
    var ProdDetails:productDetails?
    var FavoritebackResponse:backendResponse = backendResponse(message: "")
    var rateValue:Double=3
    var isLiked:String="0"
    var connectedUser:Customer = Customer(_id: "notyet", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    public var backResponse:backendResponse = backendResponse(message: "")
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"

    @IBOutlet weak var seeAllReviews: UIButton!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    
    @IBOutlet weak var Reviews: UITableView!
    
    @IBOutlet weak var favoriteBtn: UIButton!
    
    
    @IBOutlet weak var productImages: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "productImgCell")
        
        return cv
    }()
    
    @IBAction func favoriteAction(_ sender: UIButton) {

        if isLiked=="0" {//add favorite
            isLiked="1"
            favoriteBtn.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            addToFavorite()
        }else{//delete favorite
            isLiked="0"
            favoriteBtn.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
            deleteFavorite()
        }
        
    }
    
    func addToFavorite() {
        let parameters = ["prodId" : Prod?._id,"userId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/user/addFavorite") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.FavoritebackResponse = try JSONDecoder().decode(backendResponse.self, from: data!)
                } catch {
                    print("parse backend response json error")
                }
        
                DispatchQueue.main.async {
                }
            }
        }.resume()
    }
    
    func deleteFavorite() {
        let parameters = ["prodId" : Prod?._id,"userId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/user/removeFavorite") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.FavoritebackResponse = try JSONDecoder().decode(backendResponse.self, from: data!)
                } catch {
                    print("parse backend response json error")
                }
        
                DispatchQueue.main.async {
                }
            }
        }.resume()
    }
    
    

    @objc func showMiracle() {
            let slideVC = RateOverlayController()
            slideVC.Prod = Prod
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            self.present(slideVC, animated: true, completion: nil)
        }
    
    
    @IBAction func rateAction(_ sender: UIButton) {
        showMiracle()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier=="productReviewsSegue" {
            let product = Prod
            let destination = segue.destination as! ProductReviewsController
            destination.Prod = product
        }
    }
    
    @IBAction func seeAllReviews(_ sender: UIButton) {
        performSegue(withIdentifier: "productReviewsSegue", sender: sender)
    }
    
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        
        Prod?.reviews = []
        
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
        
        let parameters = ["prodId" : Prod?._id,"userId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/products/detail") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.ProdDetails = try JSONDecoder().decode(productDetails.self, from: data!)
                    /*let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("before parse")
                    print(json)*/
                } catch {
                    print("parse reviews json error")
                }
        
                DispatchQueue.main.async {
                    self.Prod = self.ProdDetails?.product
                    self.isLiked = self.ProdDetails!.isLiked
                    if(self.isLiked=="1"){
                        self.favoriteBtn.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                    }
                    self.Reviews.reloadData()
                    self.seeAllReviews.setTitle("See all("+String(self.Prod!.reviews!.count)+")", for: .normal)
                }
            }
        }.resume()
        
        
        
        
        
        let productUrl = baseURL + "uploads/products/" + Prod!.image[0]
        
        productImage.sd_setImage(with: URL(string: productUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        productImage.contentMode = .scaleAspectFill
        productName.text = Prod!.name
        productDescription.text = Prod!.description
        
    }//end viewDidLoad
    
    
    


    


    

}




extension ProductDetailsController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Prod!.reviews!.count<3 {
            return Prod!.reviews!.count
        }else{
            return 3
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell")
        let contentView = cell?.contentView
        let avatar = contentView?.viewWithTag(1) as! UIImageView
        let userName = contentView?.viewWithTag(2) as! UILabel
        let review = contentView?.viewWithTag(3) as! UILabel
        let rateView = contentView?.viewWithTag(4) as! UIView
        let rating = rateView.viewWithTag(5) as! UILabel
        
        
        
        let avatarUrl = baseURL + "uploads/users/" + Prod!.reviews![indexPath.row].user.avatar
        avatar.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])

        userName.text = Prod!.reviews![indexPath.row].user.firstName+" "+Prod!.reviews![indexPath.row].user.lastName
        review.text = Prod!.reviews![indexPath.row].review
        
        rateView.layer.cornerRadius = 5
        
        rating.text = String(format: "%.1f", Prod!.reviews![indexPath.row].rate)
        
        
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

//extension for bottom sheet
extension ProductDetailsController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        RatePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

