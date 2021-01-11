//
//  FriendController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 10/01/2021.
//

import UIKit

class FriendController: UIViewController {

    var friend:Customer=Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    var connectedUser:Customer?
    var connectedUserFriends = [Friendship]()
    var customers = [Friendship]()
    var profileName:String=""
    @IBOutlet weak var profileCover: UIImageView!
    @IBOutlet weak var profileAvatar: UIImageView!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var addFriendBtn: UIButton!
    
    @IBAction func addFriendAction(_ sender: UIButton) {
        
    }
    @IBOutlet weak var friendsView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupProfile()
        getConnectedUserFriends()
        getUserFriends()
        title=profileName

        friendsView.dataSource = self
        friendsView.delegate = self
        
    }
    
    func SetupProfile() -> Void {
        let userUrl = baseURL + "uploads/users/" + friend.avatar
        profileCover.sd_setImage(with: URL(string: userUrl), placeholderImage: UIImage(named: "youssef.marzouk"), options: [.continueInBackground, .progressiveLoad])
        profileAvatar.sd_setImage(with: URL(string: userUrl), placeholderImage: UIImage(named: "youssef.marzouk"), options: [.continueInBackground, .progressiveLoad])
        profileAvatar.layer.cornerRadius = profileAvatar.bounds.height/2
        profileUsername.text = profileName
    }
    
    func getConnectedUserFriends() -> Void {
        let parameters = ["userId" : connectedUser!._id]
        guard let url = URL(string: baseURL+"api/user/getFriendship") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.connectedUserFriends = try JSONDecoder().decode([Friendship].self, from: data!)
                } catch {
                    print("parse backend error")
                }
        
                DispatchQueue.main.async {
                    self.friendsView.performBatchUpdates(
                      {
                        self.friendsView.reloadSections(NSIndexSet(index: 0) as IndexSet)
                      }, completion: { (finished:Bool) -> Void in
                    })
                }
            }
        }.resume()
    }
    
    func getUserFriends() -> Void {
        let parameters = ["userId" : friend._id]
        guard let url = URL(string: baseURL+"api/user/getFriendship") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.customers = try JSONDecoder().decode([Friendship].self, from: data!)
                   
                } catch {
                    print("parse second backend error")
                }
        
                DispatchQueue.main.async {
                    self.friendsView.reloadData()
                }
            }
        }.resume()
    }
    
}

extension FriendController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        customers.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 113, height: 145)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fCell", for: indexPath)
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 0.4
        cell.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        let cv = cell.contentView
        let img = cv.viewWithTag(1) as! UIImageView
        let name = cv.viewWithTag(2) as! UILabel
        
        let userUrl = baseURL + "uploads/users/" + customers[indexPath.row].user.avatar
        img.sd_setImage(with: URL(string: userUrl), placeholderImage: UIImage(named: "youssef.marzouk"), options: [.continueInBackground, .progressiveLoad])
        
        name.text = customers[indexPath.row].user.firstName+" "+customers[indexPath.row].user.lastName
        
        return cell
    }
    
    
}
