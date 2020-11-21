//
//  HomeController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import UIKit

class HomeController: UIViewController {

    fileprivate let data = [
        Product(id: "1", name: "Nike Air Force", description: "Les Berges du Lac Walkway ,Tunis",Brandlogo:"fashionCategorie",image: "nikeair"),
        Product(id: "2", name: "Adidas Originals WX 2K Boost", description: "Les Berges du Lac Walkway ,Tunis",Brandlogo:"fashionCategorie",image: "adidasOriginalsWX2KBoost"),
        Product(id: "4", name: "New Balance 574", description: "Les Berges du Lac Walkway ,Tunis",Brandlogo:"fashionCategorie",image: "newBalance574"),
        Product(id: "5", name: "Reebok Club C85 LaHaine", description: "Les Berges du Lac Walkway ,Tunis",Brandlogo:"fashionCategorie",image: "reebokClubC85LaHaine"),
    ]
    
    @IBOutlet weak var trendingProducts: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "trendingCell")
        
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trendingProducts.delegate = self
        trendingProducts.dataSource = self

    }
    

}

extension HomeController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 292, height:192)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath)
        
        
        let contentView = cell.contentView
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        contentView.layer.shadowRadius = 20
        contentView.layer.shadowPath = UIBezierPath(rect: contentView.bounds).cgPath
        contentView.layer.shouldRasterize = true
        
        
        
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
}
