//
//  RestaurantsDataSource.swift
//  Restaurants
//
//  Created by Елизавета Салтыкова on 04/08/2019.
//  Copyright © 2019 Елизавета Салтыкова. All rights reserved.
//

import UIKit

class RestaurantsDataSource {
    
    private var restaurants: [Restaurant]
    
    var count: Int {
        return restaurants.count
    }
    
    static let shared = RestaurantsDataSource()
    private init() {
        restaurants = [Restaurant]()
        loadRestaurants()
    }
    
    func getRestaurant(index: Int) -> Restaurant {
        return restaurants[index]
    }
    
    func append(_ restaurant: Restaurant) {
        restaurants.append(restaurant)
    }
    
    func insert(_ restaurant: Restaurant, at: Int) {
        restaurants.insert(restaurant, at: at)
    }
    
    @discardableResult
    func remove(at: Int) -> Restaurant {
        let fileName = restaurants[at].photoFileName
        if !fileName.isEmpty {
            deleteRestaurantPhoto(fileName: fileName)
        }
        return restaurants.remove(at: at)
    }
    
    func moveRowAt(from: Int, to: Int) {
        let restaurant = restaurants.remove(at: from)
        restaurants.insert(restaurant, at: to)
    }
    
    func firstIndex(of: Restaurant) -> Int? {
        return restaurants.firstIndex(of: of)
    }
    
    // MARK: - Support Methods
    
    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentDirectory().appendingPathComponent("Restaurants.plist")
    }
    
    private func loadRestaurants() {
        let path = dataFilePath()
        if FileManager.default.fileExists(atPath: path.path) {
            do {
                restaurants = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(contentsOf: path)) as! [Restaurant]
            } catch {
                print("Ошибка загрузки: \(error.localizedDescription)")
            }
        }
    }
    
    func saveRestaurants() {
        let path = dataFilePath()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: restaurants, requiringSecureCoding: false)
            try data.write(to: path)
        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    
    func loadRestaurantPhoto(fileName: String) -> UIImage? {
        
       
            let path = documentDirectory().appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        
        
        
        do {
            let data = try Data(contentsOf: path)
    
            return UIImage(data: data)
        } catch {
            print("Ошибка загрузки фотографии: \(error.localizedDescription)")
        }
        return nil
        
    }
    
    func saveRestaurantPhoto(image: UIImage, fileName: String) {
        let path = documentDirectory().appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        do {
            try data.write(to: path)
        } catch {
            print("Ошибка сохранения фотографии: \(error.localizedDescription)")
        }
    }
    
    func deleteRestaurantPhoto(fileName: String) {
        let path = documentDirectory().appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: path.path) else { return }
        
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            print("Ошибка удаления фотографии: \(error.localizedDescription)")
        }
    }
}
