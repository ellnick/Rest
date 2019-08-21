//
//  RestaurantViewController.swift
//  Restaurants
//
//  Created by Елизавета Салтыкова on 04/08/2019.
//  Copyright © 2019 Елизавета Салтыкова. All rights reserved.
//

import UIKit

class RestaurantViewController: UITableViewController {
    var isAuthenticated = false
    var didReturnFromBackground = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        navigationItem.leftBarButtonItem = editButtonItem
        print(RestaurantsDataSource.shared.documentDirectory().path)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoginView()
        //если авторихация прошло то все ок
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RestaurantsDataSource.shared.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantCell

        let restaurant = RestaurantsDataSource.shared.getRestaurant(index: indexPath.row)
        cell.restaurant = restaurant

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            RestaurantsDataSource.shared.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
        }
        RestaurantsDataSource.shared.saveRestaurants()
    }
  
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        RestaurantsDataSource.shared.moveRowAt(from: fromIndexPath.row, to: to.row)
        RestaurantsDataSource.shared.saveRestaurants()

    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddRestaurant" {
            let controller = segue.destination as! AddRestaurantViewController
            controller.delegate = self
        } else if segue.identifier == "EditRestaurant" {
            let controller = segue.destination as! AddRestaurantViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.restaurantToEdit = RestaurantsDataSource.shared.getRestaurant(index: indexPath.row)
            }
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        isAuthenticated = true
        view.alpha = 1.0
        //при переходе из окна входа в систему мы переходим в оснлвной
    }
    @objc func appWillResignActive(_ notification : Notification) {
        view.alpha = 0
        isAuthenticated = false
        didReturnFromBackground = true
        
        //приложение уходит в фон  - оно висит в фоне
        //чтоьы нельзя было посмотреть что проиходит в приложениеи будет вот так
    }
    
    @objc func appDidBecomeActive(_ notification : Notification) {
        //проверем если из бегграунда то шоу логин вью
        if didReturnFromBackground {
            showLoginView()
        }
    }
    func showLoginView() {
        if !isAuthenticated {
            performSegue(withIdentifier: "LoginView", sender: self)
        }
        
        //проверка авторизации
    }
    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        isAuthenticated = false
        performSegue(withIdentifier: "LoginView", sender: self)
        
    }
    
}

extension RestaurantViewController: AddRestaurantViewControllerDelegate {
    
    func addRestaurantViewControllerDidCancel(_ controller: AddRestaurantViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addRestaurantViewController(_ controller: AddRestaurantViewController, didFinishAdding restaurant: Restaurant) {
        let newRowIndex = RestaurantsDataSource.shared.count
        RestaurantsDataSource.shared.append(restaurant)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        navigationController?.popViewController(animated: true)
        RestaurantsDataSource.shared.saveRestaurants()
    }
    
    func addRestaurantViewController(_ controller: AddRestaurantViewController, didFinishEditing restaurant: Restaurant) {
        if let index = RestaurantsDataSource.shared.firstIndex(of: restaurant) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        navigationController?.popViewController(animated: true)
        RestaurantsDataSource.shared.saveRestaurants()
    }
    
}
