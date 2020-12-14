//
//  HomeController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import UIKit
import CoreData



class HomeController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var Search: UISearchBar!
    
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
        performSegue(withIdentifier: "toPostsSegue", sender: sender)
    }
    
    
    @IBAction func seeAllCategories(_ sender: UIButton) {
        
    }
    
    
    @IBAction func seeAllFriends(_ sender: UIButton) {
        performSegue(withIdentifier: "chatBotSegue", sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Search.endEditing(true)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Search.endEditing(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar==Search {
            self.tabBarController?.selectedIndex = 2
        }
        
        //self.present(UINavigationController(rootViewController: SearchViewController()), animated: false, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        Search.delegate = self
        
        
        
        trendingProducts.delegate = self
        trendingProducts.dataSource = self
        
        
        
        
        Friends.delegate = self
        Friends.dataSource = self
        
        /*Search.layer.masksToBounds = true
        Search.layer.borderWidth = 1
        Search.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        Search.layer.cornerRadius = 5*/
        
        
        
        let productsUrl = URL(string: baseURL+"api/products/trending")
        URLSession.shared.dataTask(with: productsUrl!) { (data,response,error) in
            if error == nil{

                do {
                    self.products = try JSONDecoder().decode([Product].self, from: data!)
                    /*let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("before parse")
                    print(json)*/
                } catch {
                    print("parse product json error")
                }
                
                DispatchQueue.main.async {
                    self.trendingProducts.reloadData()
                }
            }
        }.resume()
        
        
        
        let friendsUrl = URL(string: baseURL+"api/user/friends")
        URLSession.shared.dataTask(with: friendsUrl!) { (data,response,error) in
            if error == nil{
                do {
                    self.customers = try JSONDecoder().decode([Customer].self, from: data!)
                } catch {
                    print("parse friends error")
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            if collectionView == trendingProducts {
                return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
                    
                    let share = UIAction(title: "Check it", image: UIImage(systemName: "sparkles")) { action in
                        // Show share sheet
                    }

                    let rename = UIAction(title: "Details", image: UIImage(systemName: "arrowshape.turn.up.right")) { action in
                        self.performSegue(withIdentifier: "prodDetailSegue", sender: indexPath.row)
                    }

                    let delete = UIAction(title: "Reviews", image: UIImage(systemName: "star")) { action in
                        self.performSegue(withIdentifier: "homeToReviewsSegue", sender: indexPath.row)
                    }

                    // Create a UIMenu with all the actions as children
                    return UIMenu(title: "", children: [share, rename, delete])
                }
            }else{
                return nil
            }
        }
    
    
    
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
            //imageView.sd_setImage(with: URL(string: avatarUrl) )
            imageView.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
            //imageView.downloaded(from: avatarUrl)
            
            
            
            
            
            
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
        
        
        backgroundImage.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        backgroundImage.contentMode = .scaleAspectFill
        
        BrandLogo.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        
        
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
        if segue.identifier=="homeToReviewsSegue" {
            let indexPath = sender as! Int
            let product = products[indexPath]
            let destination = segue.destination as! ProductReviewsController
            
            destination.Prod = product
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView==trendingProducts {
            performSegue(withIdentifier: "prodDetailSegue", sender: indexPath.row)
        }
    }
}

