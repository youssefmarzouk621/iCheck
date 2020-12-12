//
//  ProfileController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 07/12/2020.
//

import UIKit
import CoreData
class ProfileController: UIViewController {

    @IBOutlet weak var ProfilePic: UIImageView!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var Email: UILabel!
    
    
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBAction func logoutAction(_ sender: UIButton) {
        //logout
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
        let managedContext = appDelegate.persistentContainer.viewContext
            
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Connected")
            
        do {
            let result = try managedContext.fetch(fetchRequest)
            for obj in result {
                managedContext.delete(obj)
            }
            try managedContext.save()
            print("deleted connected user")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        performSegue(withIdentifier: "logoutSegue", sender: sender)
    }
    
    
    @IBOutlet weak var seeAllBtn: UIButton!
    @IBAction func seeAllFavorites(_ sender: UIButton) {
        
    }
    
    
    @IBOutlet weak var productContainer: UIView!
    
    //variables
    var connectedUser:Customer = Customer(_id: "notyet", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.seeAllBtn.alpha=0
        getConnectedUser()
        setupUser()
        getFavorites()
        
        productContainer.layer.masksToBounds = true
        productContainer.layer.borderWidth = 0.4
        productContainer.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        
        logoutBtn.layer.masksToBounds = true
        logoutBtn.layer.borderWidth = 0.3
        logoutBtn.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        logoutBtn.layer.cornerRadius = 5
        
        ProfilePic.layer.cornerRadius = ProfilePic.bounds.width/2
        ProfilePic.contentMode = .scaleAspectFill
    }
    func getFavorites() {
        
        let parameters = ["userId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/user/getFavorite") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.connectedUser = try JSONDecoder().decode(Customer.self, from: data!)
                } catch {
                    print("parse profile customer error")
                }
        
                DispatchQueue.main.async {
                    if !(self.connectedUser.favorites!.count==0){
                        let container = self.productContainer
                        let productImg = container!.viewWithTag(1) as! UIImageView
                        let productName = container!.viewWithTag(2) as! UILabel
                        let productDescription = container!.viewWithTag(3) as! UILabel
                        let rateView = container!.viewWithTag(4)
                        let rateValue = rateView!.viewWithTag(5) as! UILabel
                        let brandLogo = container!.viewWithTag(6) as! UIImageView
                        
                        let productUrl = self.baseURL + "uploads/products/" + self.connectedUser.favorites![0].product.image[0]
                        let brandUrl = self.baseURL + "uploads/brands/" + self.connectedUser.favorites![0].product.brand + ".jpg"
                        productImg.sd_setImage(with: URL(string: productUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
                        productName.text = self.connectedUser.favorites![0].product.name
                        productDescription.text = self.connectedUser.favorites![0].product.description
                        rateValue.text = String(format: "%.1f", self.connectedUser.favorites![0].product.rate)
                        brandLogo.sd_setImage(with: URL(string: brandUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
                        
                        self.productContainer = container
                    }
                    
                    if (self.connectedUser.favorites!.count==0){
                        self.seeAllBtn.alpha=0
                    }else{
                        self.seeAllBtn.alpha=1
                        self.seeAllBtn.setTitle("See all("+String(self.connectedUser.favorites!.count)+")", for: .normal)
                    }
                    
                }
            }
        }.resume()
    }
    
    func setupUser() {
        let avatarUrl = baseURL + "uploads/users/" + connectedUser.avatar
        ProfilePic.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        Username.text = connectedUser.firstName+" "+connectedUser.lastName
        Email.text = connectedUser.email
    }
    func getConnectedUser() {
        
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
    }
    

}




