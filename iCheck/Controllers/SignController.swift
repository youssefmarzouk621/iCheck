//
//  SignController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import UIKit
import CoreData



class SignController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var Lastname: UITextField!
    @IBOutlet weak var Firstname: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Confirm: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    var networkService = NetworkService()
    
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    public var backResponse:backendResponse = backendResponse(message: "")
    
    @IBAction func UploadAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func uploadImage(with image: UIImage?, completion: (() -> Void)? = nil) {
        
        guard let pickedImage = image else {
            completion?()
            return
        }

        networkService.uploadImage(with: pickedImage) {
            print("success")
            completion?()
        } onError: { error in
            print(error)
            completion?()
        }
        
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        profileImageView.image = pickedImage
    }
    
    @IBAction func RegisterAction(_ sender: UIButton) {
        if Firstname.text == "" {
            let alert = UIAlertController(title: "Firstname field is empty", message: "please fill your inputs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else if Lastname.text == ""{
            let alert = UIAlertController(title: "Lastname field is empty", message: "please fill your inputs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else if Email.text == "" {
            let alert = UIAlertController(title: "Email field is empty", message: "please fill your inputs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else if Password.text == "" {
            let alert = UIAlertController(title: "Password field is empty", message: "please fill your inputs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else if Confirm.text == "" {
            let alert = UIAlertController(title: "Confirm password field is empty", message: "please fill your inputs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else if !(Confirm.text == Password.text) {
            let alert = UIAlertController(title: "password does not match", message: "please fill your inputs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else {
            let parameters = ["firstName" : Firstname.text, "lastName" : Lastname.text, "email" : Email.text, "password" : Password.text]
            guard let url = URL(string: baseURL+"api/user/register") else { return }
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
                        if status == 201 {
                            let alert = UIAlertController(title: "Account exist", message: "Account exist with the given email", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }else if status == 200 {
                            print(self.backResponse)
                            self.saveConnectedUser()
                            self.uploadImage(with: self.profileImageView.image) {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "registerToHomeSegue", sender:sender)
                                }
                            }
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
        
        
        object.setValue(self.Firstname.text, forKey: "firstName")
        object.setValue(self.Lastname.text, forKey: "lastName")
        object.setValue(self.Email.text, forKey: "email")
                
        
        do {
            try managedContext.save()
            print("saved");
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
    }
    

}


