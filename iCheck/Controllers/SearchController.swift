//
//  SearchController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 13/12/2020.
//

import UIKit
import CoreData
struct SearchModel : Decodable {
    var searchId:String
    var name:String
    var description:String
    var photo:String
    var type:String
}

class SearchController: UIViewController,UISearchBarDelegate {

    
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var searchList: UICollectionView!
    
    var searchResult:[SearchModel]=[
        /*SearchModel(name: "Mehdi Behira", description: "mehdi.behira@esprit.tn", photo: "38405318_1949051928449621_1034999664211918848_o.jpg", type: "user"),
        SearchModel(name: "Reebok Club C85 LaHaine", description: "Les Berges du Lac Walkway ,Tunis", photo: "reebokClubC85LaHaine.jpg", type: "product")*/
    ]
    var connectedUser:Customer = Customer(_id: "notyet", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    var ProdDetails:productDetails?
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        getConnectedUser()
        
        getSearchHistory(connectedId:connectedUser._id)
        
        searchList.delegate = self
        searchList.dataSource = self
        SearchBar.delegate = self
        
        
    }
    
    func getSearchHistory(connectedId:String) -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SearchHistory")
        do {
            let result = try managedContext.fetch(fetchRequest)
            if !(result.count==0) {
                
                for obj in result {
                    //print(obj.value(forKey: "id") as! String)
                    let userId = obj.value(forKey: "userId") as! String
                    if userId==connectedId {
                        self.searchResult.append(SearchModel(searchId: obj.value(forKey: "searchId") as! String,
                                                             name: obj.value(forKey: "name") as! String,
                                                             description: obj.value(forKey: "details") as! String,
                                                             photo: obj.value(forKey: "photo") as! String,
                                                             type: obj.value(forKey: "type") as! String))
                    }
                }
                self.searchList.performBatchUpdates(
                  {
                    self.searchList.reloadSections(NSIndexSet(index: 0) as IndexSet)
                  }, completion: { (finished:Bool) -> Void in
                })
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String){
        if searchBar==SearchBar {
            if searchText.isEmpty {
                print("empty search")
            }else{
                getSearchResults(searchString: searchText)
            }
        }
    }
    
    func getSearchResults(searchString:String) -> Void {
        let parameters = ["searchString" : searchString]
        guard let url = URL(string: baseURL+"api/products/search") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.searchResult = try JSONDecoder().decode([SearchModel].self, from: data!)
                } catch {
                    print("parse search result error")
                }
        
                DispatchQueue.main.async {
                    self.searchList.reloadData()
                }
            }
        }.resume()
    }
    


}

extension SearchController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if searchResult.isEmpty {
            return CGSize(width: 0, height:0)
        }else{
            if searchResult[indexPath.row].type=="user" {
                return CGSize(width: 355, height:78)
            }else if searchResult[indexPath.row].type=="product" {
                return CGSize(width: 355, height:178)
            }else if searchResult[indexPath.row].type=="filter" {
                return CGSize(width: 355, height:35)
            }
        }
        return CGSize(width: 0, height:0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if searchResult[indexPath.row].type=="user" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath)
            
            
            
            cell.layer.cornerRadius = 10
            cell.layer.cornerRadius = 10
            
            let contentView = cell.contentView
            let userImage = contentView.viewWithTag(1) as! UIImageView
            let userName = contentView.viewWithTag(2) as! UILabel
            let userMail = contentView.viewWithTag(3) as! UILabel
  
            let userUrl = baseURL + "uploads/users/" + self.searchResult[indexPath.row].photo
            userImage.sd_setImage(with: URL(string: userUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
            userImage.layer.cornerRadius = userImage.bounds.height/2
            userName.text = self.searchResult[indexPath.row].name
            userMail.text = self.searchResult[indexPath.row].description
            
            return cell
            
            
            
        } else if searchResult[indexPath.row].type=="product"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath)
            let contentView = cell.contentView
            let backgroundImage = contentView.viewWithTag(1) as! UIImageView
            let backgroundFilter = contentView.viewWithTag(2) as! UIImageView
            let productName = contentView.viewWithTag(3) as! UILabel
            let productDescription = contentView.viewWithTag(4) as! UILabel
            
            let productUrl = baseURL + "uploads/products/" + self.searchResult[indexPath.row].photo
            backgroundImage.sd_setImage(with: URL(string: productUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
            backgroundImage.contentMode = .scaleAspectFill
            backgroundImage.layer.cornerRadius = 10
            backgroundFilter.layer.cornerRadius = 10
            
            productName.text = self.searchResult[indexPath.row].name
            productDescription.text = self.searchResult[indexPath.row].description
            
            return cell
        }else if searchResult[indexPath.row].type=="filter"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath)
            let contentView = cell.contentView
            let filterName = contentView.viewWithTag(1) as! UILabel
            filterName.text = self.searchResult[indexPath.row].name
            return cell
        }
        

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !(self.searchResult[indexPath.row].type=="filter") {
            saveSearchHistory(index: indexPath.row)
            
        }
    }
    
    func getConnectedUser() -> Void {
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
    func saveSearchHistory(index:Int) -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SearchHistory")
        do {
            let result = try managedContext.fetch(fetchRequest)
            if !(result.count==0) {
                var found:Int=0
                for obj in result {
                    //print(obj.value(forKey: "id") as! String)
                    let searchId = obj.value(forKey: "searchId") as! String
                    if searchId==self.searchResult[index].searchId {
                        print("found in coredata")
                        //redirectToSearchItem(index:index)
                        found=1
                    }
                }
                if found==0 {
                    print("didnt find search so appending")
                    let entity = NSEntityDescription.entity(forEntityName: "SearchHistory",in: managedContext)!
                    let object = NSManagedObject(entity: entity,insertInto: managedContext)
                    
                    object.setValue(self.searchResult[index].searchId, forKey: "searchId")
                    object.setValue(self.searchResult[index].name, forKey: "name")
                    object.setValue(self.searchResult[index].description, forKey: "details")
                    object.setValue(self.searchResult[index].photo, forKey: "photo")
                    object.setValue(self.searchResult[index].type, forKey: "type")
                    object.setValue(self.connectedUser._id, forKey: "userId")
                    
                    do {
                        try managedContext.save()
                        print(self.searchResult[index].type+" saved")
                        //redirectToSearchItem(index:index)
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="openSearchProduct" {
            let product = self.ProdDetails
            let destination = segue.destination as! ProductDetailsController
            destination.ProdDetails = product
            destination.Prod = product?.product
        }
    }
    
    
    func redirectToSearchItem(index:Int) -> Void {
        
        let searchResult=self.searchResult[index]
        if searchResult.type=="product" {
            let parameters = ["prodId" : searchResult.searchId,"userId" : connectedUser._id]
            guard let url = URL(string: baseURL+"api/products/detail") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody = httpBody
            URLSession.shared.dataTask(with: request) { (data,response,error) in
                if error == nil{
                    do {
                        self.ProdDetails = try JSONDecoder().decode(productDetails.self, from: data!)
                    } catch {
                        print("parse reviews json error")
                    }
            
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "openSearchProduct", sender: "")
                        print("redirect product")
                    }
                }
            }.resume()
            
            
            
            
        } else if searchResult.type=="user"{
            print("redirect user")
        }
    }
    

}
