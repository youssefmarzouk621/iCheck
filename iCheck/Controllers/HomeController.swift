//
//  HomeController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import UIKit

class HomeController: UIViewController {

    @IBOutlet weak var Search: UITextField!
    
    @IBOutlet weak var Category1: UIImageView!
    @IBOutlet weak var categoryName1: UILabel!
    
    @IBOutlet weak var Category2: UIImageView!
    @IBOutlet weak var categoryName2: UILabel!
    
    @IBOutlet weak var Category3: UIImageView!
    @IBOutlet weak var categoryName3: UILabel!
   
    fileprivate let data = [
        Product(id: "1", name: "Nike Air Force", description: "Les Berges du Lac Walkway ,Tunis",Brandlogo:"fashionCategorie",image: "nikeair"),
        Product(id: "2", name: "Adidas Originals WX 2K Boost", description: "Les Berges du Lac Walkway ,Tunis",Brandlogo:"fashionCategorie",image: "adidasOriginalsWX2KBoost"),
        Product(id: "4", name: "New Balance 574", description: "Les Berges du Lac Walkway ,Tunis",Brandlogo:"fashionCategorie",image: "newBalance574"),
        Product(id: "5", name: "Reebok Club C85 LaHaine", description: "Les Berges du Lac Walkway ,Tunis",Brandlogo:"fashionCategorie",image: "reebokClubC85LaHaine"),
    ]
    
    
    
    
    fileprivate let chat = [
        Customer(id: "1", firstName: "Dhia", lastName: "Ben Hamouda", email: "dhia.benhamouda@esprit.tn", password: "1234",phone:"92425910",sexe:"homme", img: "dhia.bh"),
        Customer(id: "2", firstName: "Youssef", lastName: "Marzouk", email: "youssef.marzouk@esprit.tn", password: "1234",phone:"92425910",sexe:"homme", img: "youssef.marzouk"),
        Customer(id: "3", firstName: "Mehdi", lastName: "Behira", email: "mehdi.behira@esprit.tn", password: "1234",phone:"92425910",sexe:"homme", img: "mehdi.behira"),
        Customer(id: "4", firstName: "Ghassen", lastName: "Boughzela", email: "ghassen.boughzela@esprit.tn", password: "1234",phone:"92425910",sexe:"homme", img: "ghassen.bg"),
        Customer(id: "5", firstName: "Eya", lastName: "Loukil", email: "eya.loukil@esprit.tn", password: "1234",phone:"92425910",sexe:"homme", img: "eya.loukil"),
        Customer(id: "6", firstName: "Chekib", lastName: "Hajji", email: "chekib.hajji@esprit.tn", password: "1234",phone:"92425910",sexe:"homme", img: "chekib.hajji"),
        Customer(id: "7", firstName: "Amine", lastName: "Mbarki", email: "amine.mbarki@esprit.tn", password: "1234",phone:"92425910",sexe:"homme", img: "amine.mbarki"),
    ]
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
            return chat.count
        }
        return data.count
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
            imageView.image = UIImage(named: chat[indexPath.row].img)
            
            
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
        
        backgroundImage.image = UIImage(named: data[indexPath.row].image)
        BrandLogo.image = UIImage(named: data[indexPath.row].Brandlogo)
        name.text = data[indexPath.row].name
        description.text = data[indexPath.row].description
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier=="prodDetailSegue" {
            let indexPath = sender as! Int
            let product = data[indexPath]
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
