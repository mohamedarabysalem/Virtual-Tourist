//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Mohamad El Araby on 4/16/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class TouristViewController: UIViewController , UIGestureRecognizerDelegate,MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteLabel: UILabel!
    var isEdidting = false
    var pin = Pin(context: DataController.shared.viewContext)

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        fetchAllPins()
        deleteLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    func setAnnotaion(coor : CLLocationCoordinate2D? = nil, pins : [Pin]? = nil){
        if coor != nil {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coor!
            mapView.addAnnotation(annotation)
        }
        if pins != nil {
            
            for pin in pins! {
                let annotaion = MKPointAnnotation()
                annotaion.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                mapView.addAnnotation(annotaion)
            }
        }
    }
    
    @IBAction func getCoordinate (sender: UILongPressGestureRecognizer){
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

        if sender.state == .began{
            setAnnotaion(coor: coordinate)
            
        }
        else if sender.state == .ended{
            let pin = Pin(context: DataController.shared.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            try? DataController.shared.viewContext.save()
        }
    }
    private func searchForPin(latitude: String, longitude: String) -> Pin? {
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        fetchRequest.predicate = predicate
        pin = (try! DataController.shared.viewContext.fetch(fetchRequest) as! [Pin]).first
        return pin
    }
    func fetchAllPins(){
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        var pins = [Pin]()
        pins = try! DataController.shared.viewContext.fetch(fetchRequest) as! [Pin]
        setAnnotaion(pins: pins)
        //print(pins.count)
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
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let anno = view.annotation
        let lat = "\((anno?.coordinate.latitude)!)"
        let lon = "\((anno?.coordinate.longitude)!)"
        mapView.deselectAnnotation(anno, animated: true)
        let pin = searchForPin(latitude: lat, longitude: lon)
        if isEdidting{
            mapView.removeAnnotation(anno!)
            DataController.shared.viewContext.delete(pin!)
            if DataController.shared.viewContext.hasChanges {
                do {
                    try DataController.shared.viewContext.save()
                } catch {
                    print("Error while saving main context: \(error)")
                }
            }
            return
        }else{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToPhotoAlbum", sender: pin)
                
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhotoAlbum"{
            guard let pin = sender as? Pin else {
                return
            }
            let vc = segue.destination as! PhotosViewController
            
            vc.pin = pin
        }
    }
    
    
    @IBAction func editButton(_ sender: Any) {
        if isEdidting{
            editButton.title = "Edit"
            isEdidting = false
            deleteLabel.isHidden = true
            
        }else{
            editButton.title = "Done"
            isEdidting = true
            deleteLabel.isHidden = false
        }
        
    }
    
}

