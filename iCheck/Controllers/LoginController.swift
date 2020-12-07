//
//  LoginController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import UIKit
import CoreData

class LoginController: UIViewController {
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    public var connectedUser:Customer = Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    public var response:backendResponse = backendResponse(message: "")
    

    
    
    @IBAction func forgetPassword(_ sender: UIButton) {
    }
    
    @IBAction func LoginAction(_ sender: UIButton) {
        
        let emailValue = Email.text
        let passwordValue = Password.text
        
        if emailValue == "" {
            print("email empty")
            let alert = UIAlertController(title: "email field is empty", message: "please fill your inputs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else if passwordValue == "" {
            print("password empty")
            let alert = UIAlertController(title: "password field is empty", message: "please fill your inputs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else{
            let parameters = ["email" : emailValue, "password" : passwordValue]
            guard let url = URL(string: baseURL+"api/user/login") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody = httpBody
            var status = 0
            URLSession.shared.dataTask(with: request) { (data,response,error) in
                if error == nil{
                    do {
                        //self.connectedUser = try JSONDecoder().decode(Customer.self, from: data!)
                        let httpResponse = response as? HTTPURLResponse
                        status = httpResponse!.statusCode
                        if !(status==200) {
                            print("serialize backendresponse")
                            self.response = try JSONDecoder().decode(backendResponse.self, from: data!)
                        }else{
                            self.connectedUser = try JSONDecoder().decode(Customer.self, from: data!)
                            print("serialize user")
                        }
                        /*var json = try JSONSerialization.jsonObject(with: data!, options: [])
                        print(json)*/
                        
                    } catch {
                        print("parse json error")
                    }
            
                    DispatchQueue.main.async {
                        
                        if status == 202 {
                            
                            let alert = UIAlertController(title: "User does not exist", message: "check your inputs", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }else if status == 201 {
                            let alert = UIAlertController(title: "Incorrect password", message: "check your inputs", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }else if status == 200 {
                            print(self.connectedUser)
                            self.saveConnectedUser()
                            self.performSegue(withIdentifier: "toHomeSegue", sender:sender)
                        }
                        
                    }
                }
            }.resume()
            
            
            
        }
        
        
    }
    
    func saveConnectedUser() -> Void {
        
        let appD = UIApplication.shared.delegate as! AppDelegate
        let PC = appD.persistentContainer
        let managedContext = PC.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Connected",in: managedContext)!
        let object = NSManagedObject(entity: entity,insertInto: managedContext)
        
        object.setValue(self.connectedUser._id, forKey: "id")
        object.setValue(self.connectedUser.firstName, forKey: "firstName")
        object.setValue(self.connectedUser.lastName, forKey: "lastName")
        object.setValue(self.connectedUser.email, forKey: "email")
        object.setValue(self.connectedUser.password, forKey: "password")
        object.setValue(self.connectedUser.phone, forKey: "phone")
        object.setValue(self.connectedUser.sexe, forKey: "sexe")
        object.setValue(self.connectedUser.avatar, forKey: "avatar")
                
        
        do {
            try managedContext.save()
            print("saved");
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func toSignin(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginToSignSegue", sender:sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

    }
    
    
}


