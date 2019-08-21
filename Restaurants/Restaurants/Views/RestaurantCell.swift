//
//  RestaurantCell.swift
//  Restaurants
//
//  Created by Елизавета Салтыкова on 04/08/2019.
//  Copyright © 2019 Елизавета Салтыкова. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {

    @IBOutlet weak var raitingImageView: UIImageView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantComments: UILabel!
    
    var restaurant: Restaurant? {
        didSet {
            if let restaurant = restaurant {
                restaurantNameLabel.text = restaurant.name
                restaurantComments.text = restaurant.comments
                raitingImageView.image = UIImage(named: "Stars\(restaurant.rating)")
            } else {
                restaurantNameLabel.text = ""
                restaurantComments.text = ""
                raitingImageView.image = nil
            }
        }
    }
    
    
    
//это нужный файл
}
