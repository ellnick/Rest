//
//  AddRestaurantViewController.swift
//  Restaurants
//
//  Created by Елизавета Салтыкова on 04/08/2019.
//  Copyright © 2019 Елизавета Салтыкова. All rights reserved.
//

import UIKit
import Photos
import MapKit
import CoreLocation

protocol AddRestaurantViewControllerDelegate: class {
    func addRestaurantViewControllerDidCancel(_ controller: AddRestaurantViewController)
    func addRestaurantViewController(_ controller: AddRestaurantViewController, didFinishAdding restaurant: Restaurant)
    func addRestaurantViewController(_ controller: AddRestaurantViewController, didFinishEditing restaurant: Restaurant)
}


class AddRestaurantViewController: UIViewController {
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var textFieldAdress: UITextField!
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    weak var delegate: AddRestaurantViewControllerDelegate?
    var restaurantToEdit: Restaurant?
    var annotation = MKPointAnnotation() //булавка
    var placemark: CLPlacemark!
    private var starSet = [UIImageView]()
    private var selectedStar = 0
    private var newPhoto = false
    var geocoder: CLGeocoder! //позволяет преобразовать текст в точку (широта долгота для булавки)
    var newCoordinate = false
    var degree = CGFloat(Double.pi / 180)
    var oldphoto = UIImage()
    var location: CLLocation?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    func setupView() {
        commentsTextView.layer.cornerRadius = 4
        restaurantImageView.layer.cornerRadius = 12
        geocoder = CLGeocoder()
       
        
        
        if let restaurant = restaurantToEdit {
            title = "Редактирование"
            selectedStar = restaurant.rating
            textField.text = restaurant.name
            commentsTextView.text = restaurant.comments
           
        
            //print(Double(restaurant.longitude))
            //print(Double(restaurant.latitude))
            annotation.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude , longitude: restaurant.longitude)
            annotation.title = "Уставновленное местоположение"
            mapKit.showAnnotations([self.annotation], animated: true)
            mapKit.selectAnnotation(self.annotation, animated: true)
            
            DispatchQueue.global(qos: .utility).async {
                
                let photo = RestaurantsDataSource.shared.loadRestaurantPhoto(fileName: restaurant.photoFileName)
            
        DispatchQueue.main.async {
            
            if !restaurant.photoFileName.isEmpty {
                
                    UIView.transition(with: self.restaurantImageView, duration: 2, options: [.curveEaseIn, .transitionFlipFromBottom], animations: {
                    }, completion: nil)
                        self.restaurantImageView.image = photo
                        self.activityIndicator.stopAnimating()
                    }
                        }
            }
            doneBarButton.isEnabled = true
             oldphoto =  restaurantImageView.image!
        }
        
        starSet = makeStarSet()
        starSet.forEach { (imageView) in
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap))
            imageView.addGestureRecognizer(tapGR)
        }
        configureStars(tag: selectedStar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.addRestaurantViewControllerDidCancel(self)
    }
    
    
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        if let restaurant = restaurantToEdit {
            restaurant.name = textField.text!
            restaurant.rating = selectedStar
            restaurant.comments = commentsTextView.text

            if newCoordinate {
                
                restaurant.latitude = annotation.coordinate.latitude
                restaurant.longitude = annotation.coordinate.longitude
            }

            if newPhoto {
                activityIndicator.isHidden = true
                if restaurant.photoFileName.isEmpty {
                    restaurant.photoFileName = UUID().description + ".jpg"
                }
                RestaurantsDataSource.shared.saveRestaurantPhoto(image: restaurantImageView.image!,
                                                                 fileName: restaurant.photoFileName)
            }
            
            delegate?.addRestaurantViewController(self, didFinishEditing: restaurant)
        } else {
            let restaurant = Restaurant()
            restaurant.name = textField.text!
            restaurant.rating = selectedStar
            restaurant.comments = commentsTextView.text
            activityIndicator.isHidden = true
            if newCoordinate {
                restaurant.latitude = annotation.coordinate.latitude
                restaurant.longitude = annotation.coordinate.longitude
            }
            if newPhoto {
                activityIndicator.isHidden = true
                restaurant.photoFileName = UUID().description + ".jpg"
                RestaurantsDataSource.shared.saveRestaurantPhoto(image: restaurantImageView.image!,
                                                                 fileName: restaurant.photoFileName)
            }
            delegate?.addRestaurantViewController(self, didFinishAdding: restaurant)
        }
        
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
        
        
        
        
    }
    
    // MARKS: - Методы для работы со звездами
    
    // Формирует массив со звездами (UIImageView)
    func makeStarSet() -> [UIImageView] {
        var stars = [UIImageView]()
        for i in 1...5 {
            let imageView = view.viewWithTag(i) as! UIImageView
            stars.append(imageView)
        }
        return stars
    }
    
    // Обработчик для распознователя жестов для всех звезд
    @objc func didTap(tapGR: UITapGestureRecognizer) {
        if let tag = tapGR.view?.tag {
            configureStars(tag: tag)
            selectedStar = tag
        }
    }
    
    // Конфигурирование всех звезд
    func configureStars(tag: Int) {
        starSet.forEach { (imageView) in
            if imageView.tag <= tag {
                // Золотая звезда
                imageView.image = UIImage(named: "GoldStar")
            } else {
                // Серая звезда
                imageView.image = UIImage(named: "GreyStar")
            }
        }
    }

    func makeImageView(image: UIImage ) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }
    
    func fade(toImage: UIImage) {
        // Анимация затухания
        let overlayView = UIImageView(frame: restaurantImageView.frame)
        overlayView.image = toImage
        overlayView.alpha = 0
        overlayView.center.y += +20
        overlayView.bounds.size.width = restaurantImageView.bounds.width * 1.3
        
        restaurantImageView.superview?.insertSubview(overlayView, aboveSubview: restaurantImageView)
        
        UIView.animate(withDuration: 0.5, animations: {
            overlayView.alpha = 1
            overlayView.center.y -= 20
            overlayView.bounds.size = self.restaurantImageView.bounds.size
        }, completion: { _ in
            self.restaurantImageView.image = toImage
            overlayView.removeFromSuperview()
        })
    }
    
    
    
    func moveImage(imageView: UIImageView, offset: CGPoint) {
        let overlayView = imageView
        
        
        overlayView.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
        overlayView.alpha = 0
        view.addSubview(overlayView)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.restaurantImageView.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
            self.restaurantImageView.alpha = 0
        }, completion: nil)
        
        // Появление вспомогательной метки
        UIView.animate(withDuration: 0.25, delay: 0.2, options: .curveEaseIn, animations: {
            overlayView.transform = .identity
            overlayView.alpha = 1
        }) { (_) in
            overlayView.image = self.restaurantImageView.image
            self.restaurantImageView.alpha = 1
            self.restaurantImageView.transform = .identity
    
            overlayView.removeFromSuperview()
        }
        
    }
    
    
}


extension AddRestaurantViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newText.length > 0)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textFieldAdress.text, text != "" else {
            print("Ошибка текста")
            return false
        }
        
        geocoder.geocodeAddressString(text) { (placemark: [CLPlacemark]?, error: Error?) in
            //произошел запрос на сервер карты - получили итог
            //в случае ошибки:
            if let addrError = error {
                print("MapKit error: \(addrError.localizedDescription)")
            }
            
            //
            if let pmList = placemark {
                if let placemark = pmList.first {
        
                    self.annotation.title = textField.text
                    self.annotation.subtitle = "Новое Местоположение ресторана"
                    self.annotation.coordinate = placemark.location!.coordinate // получили координаты для булавки
                    
                    self.mapKit.showAnnotations([self.annotation], animated: true)
                    self.mapKit.selectAnnotation(self.annotation, animated: true)
                    self.textFieldAdress.resignFirstResponder()
                    self.newCoordinate = true
                    
                }
            }
        }
        
        return true
    }
        
        
        
        
        
        
}

extension AddRestaurantViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] {
           
            restaurantImageView.image = self.oldphoto
            
           
            //fade(toImage: image as! UIImage)
            
            //let imageView = makeImageView(image: oldphoto)
            //view.addSubview(imageView)
            //imageView.layer.cornerRadius = 12
            //imageView.layer.masksToBounds = true
            //imageView.translatesAutoresizingMaskIntoConstraints = false
            //let conX = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            //let conBottom = imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: imageView.frame.height)
            //let conWidth = imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33, constant: -50)
            //let conHeight = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
            //NSLayoutConstraint.activate([conX, conBottom, conWidth, conHeight])
            
            //view.layoutIfNeeded()
            
            newPhoto = true
            //picker.dismiss(animated: true, completion: nil)
            picker.dismiss(animated: true) {
                self.fade(toImage: image as! UIImage)
            }
        }
    }
}
