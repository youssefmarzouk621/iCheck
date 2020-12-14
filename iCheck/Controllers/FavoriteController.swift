//
//  FavoriteController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 13/12/2020.
//

import UIKit
import CoreData
class FavoriteController: UIViewController {
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    var connectedUser:Customer = Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    var FavoritebackResponse:backendResponse = backendResponse(message: "")
    
    @IBOutlet weak var favoriteProducts: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "favoriteCell")
        
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteProducts.delegate = self
        favoriteProducts.dataSource = self
        getConnectedUser()
        getFavorites()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getFavorites()
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
                    print("parse favorite error")
                }
        
                DispatchQueue.main.async {
                    self.favoriteProducts.performBatchUpdates(
                      {
                        self.favoriteProducts.reloadSections(NSIndexSet(index: 0) as IndexSet)
                      }, completion: { (finished:Bool) -> Void in
                    })
                }
            }
        }.resume()
    }
    
    
    func deleteFavorite(index:Int) {
        let parameters = ["prodId" : connectedUser.favorites![index].product._id,"userId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/user/removeFavorite") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.FavoritebackResponse = try JSONDecoder().decode(backendResponse.self, from: data!)
                } catch {
                    print("parse backend favorite response json error")
                }
        
                DispatchQueue.main.async {
                    self.connectedUser.favorites!.remove(at: index)
                    self.favoriteProducts.performBatchUpdates(
                      {
                        self.favoriteProducts.reloadSections(NSIndexSet(index: 0) as IndexSet)
                      }, completion: { (finished:Bool) -> Void in
                    })
                }
            }
        }.resume()
    }

    
    


}

extension FavoriteController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 355, height:300)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.connectedUser.favorites!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath)

        
        
        let contentView = cell.contentView
        let backgroundImage = contentView.viewWithTag(1) as! UIImageView
        let backgroundFilter = contentView.viewWithTag(2) as! UIImageView
        let brandImg = contentView.viewWithTag(3) as! UIImageView
        let brandName = contentView.viewWithTag(4) as! UILabel
        let productName = contentView.viewWithTag(5) as! UILabel
        let productDescription = contentView.viewWithTag(6) as! UILabel
        let rateView = contentView.viewWithTag(7) as! UIView
        let rating = rateView.viewWithTag(8) as! UILabel
        let favoriteBtn = contentView.viewWithTag(9) as! UIButton
        
        let imgUrl = baseURL + "uploads/products/" + self.connectedUser.favorites![indexPath.row].product.image[0]
        let BrandUrl = baseURL + "uploads/brands/" + self.connectedUser.favorites![indexPath.row].product.brand + ".jpg"
        
        backgroundImage.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.layer.cornerRadius = 10
        
        
        backgroundFilter.contentMode = .scaleAspectFill
        backgroundFilter.layer.cornerRadius = 10
        
        brandImg.sd_setImage(with: URL(string: BrandUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        brandImg.layer.cornerRadius = brandImg.bounds.height/2
        brandImg.contentMode = .scaleAspectFill
        
        brandName.text = self.connectedUser.favorites![indexPath.row].product.brand
        productName.text = self.connectedUser.favorites![indexPath.row].product.name
        productDescription.text = self.connectedUser.favorites![indexPath.row].product.description
        rateView.layer.cornerRadius = 3
        rating.text = String(self.connectedUser.favorites![indexPath.row].product.rate)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let optionMenu = UIAlertController(title: "Option", message: "Please choose an Option", preferredStyle: .actionSheet)
                
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                self.deleteFavorite(index: indexPath.row)
                })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)

            self.present(optionMenu, animated: true, completion: nil)
    }
    

}
