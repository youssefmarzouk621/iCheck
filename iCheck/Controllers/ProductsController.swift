//
//  ProductsController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 03/12/2020.
//

import UIKit
import Cosmos
class ProductsController: UIViewController {

    @IBOutlet weak var searchProducts: UISearchBar!
    
    @IBOutlet weak var filterProducts: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "filterCell")
        
        return cv
    }()
    @IBOutlet weak var Products: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "productCell")
        return cv
    }()
    
    //variables
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    var fetchedProducts = [Product]()
    var productList = [Product]()
    var categories = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        filterProducts.delegate = self
        filterProducts.dataSource = self

        Products.delegate = self
        Products.dataSource = self
        // Do any additional setup after loading the view.
        
        //get products
        let productsUrl = URL(string: baseURL+"api/products/")
        URLSession.shared.dataTask(with: productsUrl!) { (data,response,error) in
            if error == nil{

                do {
                    self.productList = try JSONDecoder().decode([Product].self, from: data!)
                } catch {
                    print("parse json error")
                }
                
                DispatchQueue.main.async {
                    for product in self.productList {
                        if self.categories.isEmpty {
                            self.categories.append(product.category)
                        }else{
                            for category in self.categories {
                                if !(product.category==category) {
                                    self.categories.append(product.category)
                                }
                            }
                        }
                    }
                    self.fetchedProducts = self.productList
                    
                    self.filterProducts.performBatchUpdates(
                      {
                        self.filterProducts.reloadSections(NSIndexSet(index: 0) as IndexSet)
                      }, completion: { (finished:Bool) -> Void in
                    })
                    
                    self.Products.performBatchUpdates(
                      {
                        self.Products.reloadSections(NSIndexSet(index: 0) as IndexSet)
                      }, completion: { (finished:Bool) -> Void in
                    })
                    
                    //self.filterProducts.reloadData()
                    //self.Products.reloadData()
                }
            }
        }.resume()
    }


}


extension ProductsController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            if collectionView == Products {
                return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
                    // Create an action for sharing
                    let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                        // Show share sheet
                    }

                    // Create an action for copy
                    let rename = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { action in
                        // Perform copy
                    }

                    // Create an action for delete with destructive attributes (highligh in red)
                    let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                        // Perform delete
                    }

                    // Create a UIMenu with all the actions as children
                    return UIMenu(title: "", children: [share, rename, delete])
                }
            }else{
                return nil
            }
        }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView==filterProducts){
            
            return CGSize(width: 128, height:42)
        }
    
        return CGSize(width: (Products.frame.width - 2)/2, height:311)//collection width - (item spacing)/number of items in row
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView==filterProducts){
            return self.categories.count
        }
        return self.productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView==filterProducts){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath)
            
            cell.layer.masksToBounds = true
            cell.layer.borderWidth = 0.4
            cell.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
            
            let contentView = cell.contentView
            let filter = contentView.viewWithTag(1) as! UILabel
            filter.text = categories[indexPath.row]
            

            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath)
        
        let contentView = cell.contentView
        let productImg = contentView.viewWithTag(1) as! UIImageView
        let brandLogo = contentView.viewWithTag(3) as! UIImageView
        let cosmosView = contentView.viewWithTag(4) as! CosmosView
        let productName = contentView.viewWithTag(5) as! UILabel
        let productBrand = contentView.viewWithTag(6) as! UILabel
        
        let productUrl = baseURL + "uploads/products/" + productList[indexPath.row].image[0]
        
        productImg.sd_setImage(with: URL(string: productUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        productImg.contentMode = .scaleAspectFill
        
        let brandUrl = baseURL + "uploads/brands/" + productList[indexPath.row].brand + ".jpg"
        
        brandLogo.sd_setImage(with: URL(string: brandUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        brandLogo.contentMode = .scaleAspectFill
        
        cosmosView.settings.fillMode = .precise
        cosmosView.rating = productList[indexPath.row].rate
        
        productName.text = productList[indexPath.row].name
        productBrand.text = productList[indexPath.row].brand

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier=="prodDetailSegue" {
            let indexPath = sender as! Int
            let product = productList[indexPath]
            let destination = segue.destination as! ProductDetailsController
            
            destination.Prod = product
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView==Products {
            performSegue(withIdentifier: "prodDetailSegue", sender: indexPath.row)
        }
        if collectionView==filterProducts {
            let filter = categories[indexPath.row]
            
            let filtered = self.fetchedProducts.filter { product in
                return product.category==filter
            }
            self.productList = filtered
            
            self.Products.performBatchUpdates(
              {
                self.Products.reloadSections(NSIndexSet(index: 0) as IndexSet)
              }, completion: { (finished:Bool) -> Void in
            })
            
            //self.Products.reloadData()
        }
    }
    
    
}
