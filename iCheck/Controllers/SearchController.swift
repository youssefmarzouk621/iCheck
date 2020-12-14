//
//  SearchController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 13/12/2020.
//

import UIKit

struct SearchModel : Decodable {
    var name:String
    var description:String
    var photo:String
    var type:String
}

class SearchController: UIViewController,UISearchBarDelegate {

    
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var searchList: UICollectionView!
    
    var searchResult:[SearchModel]=[
        SearchModel(name: "Mehdi Behira", description: "mehdi.behira@esprit.tn", photo: "38405318_1949051928449621_1034999664211918848_o.jpg", type: "user"),
        SearchModel(name: "Reebok Club C85 LaHaine", description: "Les Berges du Lac Walkway ,Tunis", photo: "reebokClubC85LaHaine.jpg", type: "product")
    ]
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        searchList.delegate = self
        searchList.dataSource = self
        SearchBar.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SearchBar.becomeFirstResponder()
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

    }
    

}
