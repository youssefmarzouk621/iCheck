//
//  FriendController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 10/01/2021.
//

import UIKit

class FriendController: UIViewController {

    var comingFrom:String="search"
    
    var friend:Customer=Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    var connectedUser:Customer?
    var connectedUserFriends = [Friendship]()
    var customers = [Friendship]()
    var backResponse:backendResponse=backendResponse(message: "")
    var profileName:String=""
    @IBOutlet weak var profileCover: UIImageView!
    @IBOutlet weak var profileAvatar: UIImageView!
    @IBOutlet weak var profileUsername: UILabel!
    
    var isFound="false"
    @IBOutlet weak var addFriendBtn: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="chatBotSegue" {
            let destination  = segue.destination as! ChatBotController
            destination.friend = self.friend
        }
    }
    @IBAction func addFriendAction(_ sender: UIButton) {
        
        if isFound=="false" {
            addFriendship()
            print("add Friendship")
        }else if isFound=="true"{
            performSegue(withIdentifier: "chatBotSegue", sender: sender)
        }else if isFound=="pending"{
            print("cancel invite")
        }
    }
    @IBOutlet weak var friendsView: UICollectionView!
    
    func addFriendship() -> Void {
        let parameters = ["userId" : connectedUser!._id,"friendId" : friend._id]
        guard let url = URL(string: baseURL+"api/user/addFriendship") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.backResponse = try JSONDecoder().decode(backendResponse.self, from: data!)
                } catch {
                    print("parse addfriend error")
                }
        
                DispatchQueue.main.async {
                    self.isFound="pending"
                    self.addFriendBtn.setImage(UIImage(systemName: "link"), for: .normal)
                    self.addFriendBtn.setTitle("Request sent", for: .normal)
                }
            }
        }.resume()
    }
    
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
        guard let url = URL(string: baseURL+"api/user/getAllFriendship") else { return }
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
                    self.setupButton()
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
    
    func setupButton() -> Void {
        for singleFriend in connectedUserFriends {

            if singleFriend.user._id==self.friend._id {
                if singleFriend.Accepted==0{
                    isFound="pending"
                }else{
                    isFound="true"
                }
            }
        }

        
        if connectedUser!._id==friend._id {
            addFriendBtn.isEnabled=false
            addFriendBtn.alpha=0
        }else{
            if comingFrom=="chat" {
                addFriendBtn.isEnabled=false
                addFriendBtn.alpha=0
            }else{
                if isFound=="true" {
                    addFriendBtn.setImage(UIImage(systemName: "message.fill"), for: .normal)
                    addFriendBtn.setTitle("Message", for: .normal)
                    print("already friends")
                }else if isFound=="false" {
                    addFriendBtn.setImage(UIImage(systemName: "person"), for: .normal)
                    addFriendBtn.setTitle("Add Friend", for: .normal)
                }else if isFound=="pending"{
                    addFriendBtn.setImage(UIImage(systemName: "link"), for: .normal)
                    addFriendBtn.setTitle("Request sent", for: .normal)
                }
            }
        }



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
        let mutual = cv.viewWithTag(3) as! UILabel
        
        let userUrl = baseURL + "uploads/users/" + customers[indexPath.row].user.avatar
        img.sd_setImage(with: URL(string: userUrl), placeholderImage: UIImage(named: "youssef.marzouk"), options: [.continueInBackground, .progressiveLoad])
        
        name.text = customers[indexPath.row].user.firstName+" "+customers[indexPath.row].user.lastName

        var trouv=false
        for friend in connectedUserFriends {
            if friend.user._id==customers[indexPath.row].user._id{
                trouv=true
            }
        }
        if trouv {
            if customers[indexPath.row].user._id==connectedUser!._id {
                mutual.text="mutual friend"
            }
            
        }
        
        
        
        return cell
    }
    
    
}
