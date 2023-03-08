//
//  ViewController.swift
//  GetDirection
//
//  Created by Mahmudul Hasan on 8/3/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.delegate = self
    }


    @IBAction func btnTapped(_ sender: Any) {
        getLocation()
    }
    
    func getLocation() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(txtField.text!) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("No location Found")
                
                return
            }
            
            print(location)
            self.mapThis(destinationCord: location.coordinate)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    func mapThis(destinationCord: CLLocationCoordinate2D) {
        guard let sourceCoordinate = (locationManager.location?.coordinate) else {
            return
        }
        
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let desPlaceMark = MKPlacemark(coordinate: destinationCord)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let desItem = MKMapItem(placemark: desPlaceMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.source = desItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: destinationRequest)
        direction.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Something went wrong")
                }
                return
            }
            let route = response.routes[0]
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor  = .red
        return render
    }
}

