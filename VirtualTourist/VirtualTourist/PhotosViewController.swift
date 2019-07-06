//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Mohamad El Araby on 4/19/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class PhotosViewController: UIViewController,MKMapViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource{
    
    
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    let activityIndecator = UIActivityIndicatorView()
    var pin : Pin?
    var photos = [Photo]()
    var page = 0
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        mapview.delegate = self
        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layOut = UICollectionViewFlowLayout()
        layOut.sectionInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 10, right: 0)
        layOut.itemSize = CGSize(width: itemSize, height: itemSize)
        layOut.minimumInteritemSpacing = 3
        layOut.minimumLineSpacing = 3
        collectionView.collectionViewLayout = layOut
        //collectionView.reloadData()
        setAnnotaion()
        if (pin?.photos?.count)! <= 0 {
            getPhotos()
        } else {
            fetchPhotos()
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    func getPhotos(){
        self.activityIndicator()
        FlickerAPI.shared.getImageFromFlicker(lat: pin!.latitude, lon: pin!.longitude,page:page) { (photosArray) in
            DispatchQueue.main.async {
                self.activityIndecator.stopAnimating()

                print("Download")
            }

            if photosArray.count == 0 {
                print("No Photos Found")
            }else{
                for url in photosArray{
                    guard let urlString = url["url_m"] as? String else {
                        print("Cannot find key url_m in \(photosArray)")
                        return
                    }
                    let photo = Photo(context: DataController.shared.viewContext)
                    photo.url = urlString
                    photo.pin = self.pin
                    self.photos.append(photo)
                    self.count = self.photos.count
                    try? DataController.shared.viewContext.save()
                    
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    func setAnnotaion(){
        let annotaion = MKPointAnnotation()
        annotaion.coordinate.latitude = pin!.latitude
        annotaion.coordinate.longitude = pin!.longitude
        mapview.addAnnotation(annotaion)

    }
    func fetchPhotos (){
        print("fetch")
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        photos = try! DataController.shared.viewContext.fetch(fetchRequest)
        count = photos.count
        print(count)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cache = NSCache<AnyObject, AnyObject>()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgCell", for: indexPath) as! ImgCell
        //print(photos[indexPath.row].url)
        let photo = photos[indexPath.row]
        
        cell.img.image = UIImage(named: "placeholder.jpg")
        cell.activityIndicator()
        if photo.imgData == nil {
            DispatchQueue.global(qos: .default).async {
                let urlString = self.photos[indexPath.row].url
                let imageUrl = URL(string: urlString!)
                let imgData = try? Data(contentsOf: imageUrl!)
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: imgData!)
                    cache.setObject(imageToCache!, forKey: urlString as AnyObject)
                    cell.img.image = imageToCache
                    cell.activityIndecator.stopAnimating()
                    photo.imgData = imgData
                    try! DataController.shared.viewContext.save()
                }
            }
            
        }else{
            cell.activityIndecator.stopAnimating()
            cell.img.image = UIImage(data: self.photos[indexPath.row].imgData!)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        count -= 1
        photos.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        DataController.shared.viewContext.delete(photo)
        try! DataController.shared.viewContext.save()
        
    }
    func DeletePhotos(){
        for photo in photos {
            DataController.shared.viewContext.delete(photo)
            try! DataController.shared.viewContext.save()
        }
    }
    func activityIndicator(){
        activityIndecator.style = UIActivityIndicatorView.Style.gray
        activityIndecator.center = self.view.center
        activityIndecator.hidesWhenStopped = true
        activityIndecator.startAnimating()
        self.view.addSubview(activityIndecator)
        self.activityIndecator.startAnimating()
    }
    
    @IBAction func newCollecionButton(_ sender: Any) {
        page += 1
        photos = [Photo] ()
        DeletePhotos()
        count = 0
        collectionView.reloadData()
        getPhotos()
    }
}
