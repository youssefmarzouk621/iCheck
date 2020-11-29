//
//  HomeController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import UIKit
import CoreData

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


class HomeController: UIViewController {

    @IBOutlet weak var Search: UITextField!
    
    @IBOutlet weak var Category1: UIImageView!
    @IBOutlet weak var categoryName1: UILabel!
    
    @IBOutlet weak var Category2: UIImageView!
    @IBOutlet weak var categoryName2: UILabel!
    
    @IBOutlet weak var Category3: UIImageView!
    @IBOutlet weak var categoryName3: UILabel!
   
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"

    var connected:Customer? = nil
    var customers = [Customer]()
    var products = [Product]()
    

    @IBOutlet weak var trendingProducts: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "trendingCell")
        
        return cv
    }()
    
    @IBOutlet weak var Friends: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "friendCell")
        
        return cv
    }()
    
 
    
    @IBAction func seeAllProduct(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
        let managedContext = appDelegate.persistentContainer.viewContext
            
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Connected")
            
        do {
            let result = try managedContext.fetch(fetchRequest)
            for obj in result {
                managedContext.delete(obj)
            }
            try managedContext.save()
            print("deleted connected user")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        performSegue(withIdentifier: "logoutSegue", sender: sender)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        trendingProducts.delegate = self
        trendingProducts.dataSource = self
        
        Friends.delegate = self
        Friends.dataSource = self
        
        Search.layer.masksToBounds = true
        Search.layer.borderWidth = 1
        Search.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        Search.layer.cornerRadius = 5
        
        
        
        let productsUrl = URL(string: baseURL+"api/products/")
        URLSession.shared.dataTask(with: productsUrl!) { (data,response,error) in
            if error == nil{

                do {
                    self.products = try JSONDecoder().decode([Product].self, from: data!)
                    /*let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("before parse")
                    print(json)*/
                } catch {
                    print("parse json error")
                }
                
                DispatchQueue.main.async {
                    self.trendingProducts.reloadData()
                    
                }
            }
        }.resume()
        
        
        
        let friendsUrl = URL(string: baseURL+"api/user/")
        URLSession.shared.dataTask(with: friendsUrl!) { (data,response,error) in
            if error == nil{
                do {
                    self.customers = try JSONDecoder().decode([Customer].self, from: data!)
                } catch {
                    print("parse json error")
                }
                
                DispatchQueue.main.async {
                    self.Friends.reloadData()
                    
                }
            }
        }.resume()
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
















extension HomeController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView==Friends){
            
            return CGSize(width: 55, height:55)
        }
        return CGSize(width: 310, height:237)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView==Friends) {
            return customers.count
        }
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView==Friends) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCell", for: indexPath)
            let contentView = cell.contentView
            
            contentView.layer.cornerRadius = cell.bounds.width/2
            let borderView = contentView.viewWithTag(2) as! UIView
            borderView.layer.cornerRadius = borderView.bounds.width/2
            let imageView = contentView.viewWithTag(1) as! UIImageView
            imageView.layer.cornerRadius = imageView.bounds.width/2

            let avatarUrl = baseURL + "uploads/users/" + customers[indexPath.row].avatar
            imageView.downloaded(from: avatarUrl)
            
            
            
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath)
        
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 0.4
        cell.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        
        let contentView = cell.contentView
        let backgroundImage = contentView.viewWithTag(1) as! UIImageView
        let BrandLogo = contentView.viewWithTag(2) as! UIImageView
        let name = contentView.viewWithTag(3) as! UILabel
        let description = contentView.viewWithTag(4) as! UILabel
        
       
        let imgUrl = baseURL + "uploads/products/" + products[indexPath.row].image[0]
        
        backgroundImage.downloaded(from: imgUrl)
        backgroundImage.contentMode = .scaleAspectFill
        BrandLogo.downloaded(from: imgUrl)
        BrandLogo.contentMode = .scaleAspectFill
        name.text = products[indexPath.row].name
        description.text = products[indexPath.row].description
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier=="prodDetailSegue" {
            let indexPath = sender as! Int
            let product = products[indexPath]
            let destination = segue.destination as! ProductDetailsController
            
            destination.Prod = product
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView==trendingProducts {
            performSegue(withIdentifier: "prodDetailSegue", sender: indexPath.row)
        }
        
    }
}
