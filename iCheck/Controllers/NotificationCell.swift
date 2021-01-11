//
//  NotificationCell.swift
//  iCheck
//
//  Created by Youssef Marzouk on 09/01/2021.
//

import UIKit

class NotificationCell: UICollectionViewCell {
    var connectedId:String?
    var friendId:String?
    var notif:NotificationResponse?
    var Backresponse:backendResponse=backendResponse(message:"")
    @IBOutlet weak var titleNotification: UILabel!
    @IBOutlet weak var descriptionNotification: UILabel!
    @IBOutlet weak var avatarNotification: UIImageView!
    
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    
    @IBAction func followAction(_ sender: UIButton) {

        let parameters = ["userId" : connectedId!,"friendId" : friendId!,"notifId" : notif!._id]
        guard let url = URL(string: baseURL+"api/user/acceptFriendship") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.Backresponse = try JSONDecoder().decode(backendResponse.self, from: data!)
                } catch {
                    print("parse backend error")
                }
        
                DispatchQueue.main.async {
                    sender.alpha=0
                    self.declineBtn.alpha=0
                    self.titleNotification.text="Request accepted"
                    self.descriptionNotification.text="You can chat now"
                }
            }
        }.resume()
    }
    @IBAction func declineAction(_ sender: UIButton) {
        let parameters = ["userId" : connectedId!,"friendId" : friendId!,"notifId" : notif!._id]
        guard let url = URL(string: baseURL+"api/user/declineFriendship") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.Backresponse = try JSONDecoder().decode(backendResponse.self, from: data!)
                } catch {
                    print("parse backend error")
                }
        
                DispatchQueue.main.async {
                    sender.alpha=0
                    self.followBtn.alpha=0
                }
            }
        }.resume()
    }
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    func SetupNotification(notification:NotificationResponse) -> Void {
        titleNotification.text=notification.title
        descriptionNotification.text=notification.description
        
        let avatarUrl = baseURL + "uploads/users/" + notification.image
        //imageView.sd_setImage(with: URL(string: avatarUrl) )
        avatarNotification.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "youssef.marzouk"), options: [.continueInBackground, .progressiveLoad])
        
        if notification.title=="Request accepted" {
            followBtn.alpha=0
        }
    }
    
}
