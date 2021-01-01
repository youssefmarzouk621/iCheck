//
//  VerificationController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 11/12/2020.
//

import UIKit
import CoreData

class VerificationController: UIViewController {

    @IBOutlet weak var codeField: OneTimeCodeTextField!
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    var generatedCode:Int=0
    public var backResponse:backendResponse = backendResponse(message: "")
    public var connectedUser:Customer = Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    var userMail:String=""
    var userName:String=""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        
        sendVerificationCode()
        //setup loading
        loadingSpinner.alpha = 0
        loadingSpinner.hidesWhenStopped = true
        
        //setup verification field
        codeField.becomeFirstResponder()
        codeField.defaultCharacter = "-"
        codeField.configure()
        
        codeField.didEnterLastDigit = { [weak self] code in
            print(code) //typed code
            
            self?.loadingSpinner.alpha = 1
            self?.loadingSpinner.startAnimating()
            
            if code==String(self!.generatedCode) {
                self!.verifyAccount()
                print("code shih")
            }else{
                print("code ghalet")
                self!.loadingSpinner.stopAnimating()
                let alert = UIAlertController(title: "Wrong code", message: "Wrong verification code ,please check your email", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self!.present(alert, animated: true)
            }
            
        }
    }
    
    
    
    func verifyAccount() -> Void {
        let parameters = ["email" : self.userMail]
        guard let url = URL(string: baseURL+"api/user/verifyAccount") else { return }
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
                    print("parse account verification json error")
                }
                
                DispatchQueue.main.async {
                    if !(self.connectedUser._id==""){
                        self.saveConnectedUser()
                        self.loadingSpinner.stopAnimating()
                        
                        self.performSegue(withIdentifier: "verifiedToHome", sender: "")
                    }
                }
            }
        }.resume()
    }
    
    
    
    func sendVerificationCode() {
        let randomPattern = Int.random(in: 100000...999999)
        self.generatedCode = randomPattern
        let parameters = ["email" : self.userMail,"name" : self.userName,"verificationCode" : String(randomPattern)]
        guard let url = URL(string: baseURL+"api/user/sendVerificationCode") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.backResponse = try JSONDecoder().decode(backendResponse.self, from: data!)
                    /*let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("json :")
                    print(json)*/
                } catch {
                    print("parse verification code json error")
                }
                
                DispatchQueue.main.async {
                    print(self.backResponse.message)
                    let alert = UIAlertController(title: "verification code", message: String(self.generatedCode), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }.resume()
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
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    


}
