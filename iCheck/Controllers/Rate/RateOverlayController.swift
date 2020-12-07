//
//  RateOverlayController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 05/12/2020.
//

import Foundation

import UIKit
import Cosmos
import CoreData
class RateOverlayController: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var Prod:Product?
    var rateValue:Double=3
    var connectedUser:Customer = Customer(_id: "notyet", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    
    public var backResponse:backendResponse = backendResponse(message: "")
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    @IBOutlet weak var slideIdicator: UIView!
    
    @IBOutlet weak var cosmosRating: CosmosView!
    @IBOutlet weak var rateDescription: UILabel!
    @IBOutlet weak var reviewField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        super.hideKeyboardWhenTappedAround()
        
        slideIdicator.roundCorners(.allCorners, radius: 10)
        getConnectedUser()
        setupRate()
        
        
    }
    
    
    func getConnectedUser() {
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
    }
    
    func setupRate() {
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
                            let brandNew = Review(_id: "", review: reviewDescription!, user: self.connectedUser, rate: self.rateValue)
                            self.Prod!.reviews!.append(brandNew)
                            
                            
                            
                            //let ProductDetails:ProductDetailsController?
                            /*ProductDetails!.Prod = self.Prod
                            ProductDetails!.Reviews.reloadData()*/
                            
                            self.dismiss(animated: true, completion: nil)
                            
                            self.rateDescription.text = "Good"
                            self.reviewField.text = ""
                            self.cosmosRating.rating = 3
                        }
                    }
                }
            }.resume()
            
                
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
