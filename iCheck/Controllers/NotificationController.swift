//
//  NotificationController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 09/01/2021.
//

import UIKit
import CoreData

class NotificationController: UIViewController {
    var connectedUser:Customer = Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    var notificationList = [NotificationResponse]()
    
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    @IBOutlet weak var notificationView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getConnectedUser()
        getNotifications()
        notificationView.dataSource=self
        notificationView.delegate=self
        // Do any additional setup after loading the view.
    }
    
    func getNotifications() -> Void {
        let parameters = ["userId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/user/getNotifications") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.notificationList = try JSONDecoder().decode([NotificationResponse].self, from: data!)
                } catch {
                    print("parse favorite error")
                }
        
                DispatchQueue.main.async {
                    self.notificationView.performBatchUpdates(
                      {
                        self.notificationView.reloadSections(NSIndexSet(index: 0) as IndexSet)
                      }, completion: { (finished:Bool) -> Void in
                    })
                }
            }
        }.resume()
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
extension NotificationController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        notificationList.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if notificationList[indexPath.row].type=="filter" {
            return CGSize(width: 365, height: 36)
        }
        if notificationList[indexPath.row].title=="Request accepted"{
            return CGSize(width: 365, height: 77)
        }
        return CGSize(width: 365, height: 106)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if notificationList[indexPath.row].type=="filter" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath)
            let cv = cell.contentView
            let filterText = cv.viewWithTag(1) as! UILabel
            filterText.text = notificationList[indexPath.row].title
            return cell
        }
        if notificationList[indexPath.row].title=="Request accepted" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "acceptCell", for: indexPath)
            let cv = cell.contentView
            let img = cv.viewWithTag(1) as! UIImageView
            let title = cv.viewWithTag(2) as! UILabel
            let description = cv.viewWithTag(3) as! UILabel
            
            let avatarUrl = baseURL + "uploads/users/" + notificationList[indexPath.row].image
            img.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "youssef.marzouk"), options: [.continueInBackground, .progressiveLoad])
            title.text = notificationList[indexPath.row].title
            description.text = notificationList[indexPath.row].description
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.connectedId=self.connectedUser._id
        cell.friendId=notificationList[indexPath.row].link
        cell.notif=notificationList[indexPath.row]
        cell.SetupNotification(notification: notificationList[indexPath.row])
        return cell
    }
    
    
}
//
