//
//  LoginController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import UIKit

class LoginController: UIViewController {
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    @IBAction func forgetPassword(_ sender: UIButton) {
    }
    
    @IBAction func LoginAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toHomeSegue", sender:sender)
    }
    
    @IBAction func toSignin(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginToSignSegue", sender:sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}
